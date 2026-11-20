{self, ...}: {
  flake.lib.lokiRendered = {
    config,
    lib,
  }:
    import ./_internals/rendered.nix {
      cfg = config.services.loki-nixlab;
      inherit lib;
    };

  flake.nixosModules.servc--loki-nixlab = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.loki-nixlab;
    obsLib = self.lib.obsLib;
  in {
    imports = [
    ];
    # ============================================================================
    # OPTIONS - Define what can be configured
    # ============================================================================
    options = {
      services.loki-nixlab = {
        # REQUIRED: Enable the service
        enable = lib.mkEnableOption "Loki log aggregation system";

        # OPTIONAL: Port to listen on (default: 3100)
        port = lib.mkOption {
          type = lib.types.port;
          default = 3100;
          description = "Port for Loki to listen on";
        };

        # OPTIONAL: IP to bind to (default: 127.0.0.1 = localhost only)
        listenAddress = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "IP address to bind to (use 0.0.0.0 for all interfaces)";
        };

        # OPTIONAL: Domain for nginx reverse proxy (default: null = no proxy)
        domain = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "loki.example.com";
          description = "Domain name for nginx reverse proxy (optional)";
        };

        # OPTIONAL: Enable SSL/HTTPS with Let's Encrypt (default: false)
        enableSSL = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable HTTPS with Let's Encrypt (requires domain)";
        };

        # OPTIONAL: Where to store Loki data (default: /var/lib/loki)
        dataDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/loki";
          example = "/data/loki";
          description = "Directory for Loki data storage";
        };

        # OPTIONAL: Log retention period (default: 744h = 31 days)
        retention = lib.mkOption {
          type = lib.types.str;
          default = "744h";
          example = "2160h";
          description = "How long to retain log data (in hours)";
        };

        # OPTIONAL: Loki package to use (default: pkgs.grafana-loki)
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.grafana-loki;
          defaultText = lib.literalExpression "pkgs.grafana-loki";
          description = "The Loki package to use";
        };

        # OPTIONAL: Auto-open firewall ports (default: true)
        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Open firewall ports";
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "loki";
          description = "User to run Loki as";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "loki";
          description = "Group to run Loki as";
        };

        uid = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "Pinned uid for the loki user (null = allocate dynamically).";
        };

        gid = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "Pinned gid for the loki group.";
        };

        # OPTIONAL: Extra users added to the service's group (for example, to read its data).
        extraUsers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["alice"];
          description = "Extra users to add to the groups";
        };

        ruler = {
          enable = lib.mkEnableOption "Loki ruler (LogQL alert rules evaluated inside Loki)";

          alertmanagerUrl = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "http://127.0.0.1:9093";
            description = "Alertmanager that receives the ruler's alerts. Required when the ruler is enabled.";
          };

          groups = lib.mkOption {
            type = lib.types.listOf lib.types.attrs;
            default = [];
            description = "Rule groups (name, interval, rules) written to the ruler's local rule directory.";
          };
        };

        grpcPort = lib.mkOption {
          type = lib.types.port;
          default = 9096;
          description = "gRPC port for Loki internal communication. Only relevant for multi-instance deployments.";
        };

        openGrpcFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Open the gRPC port in the firewall. Only needed for multi-instance Loki deployments.";
        };

        retentionStreams = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options = {
              selector = lib.mkOption {type = lib.types.str; example = ''{job="audit"}'';};
              period = lib.mkOption {type = lib.types.str; example = "17520h";};
              priority = lib.mkOption {type = lib.types.int; default = 1;};
            };
          });
          default = [];
          description = "Per-stream retention overrides (rendered into limits_config.retention_stream).";
        };
      };
    };

    # ============================================================================
    # CONFIG - What happens when the service is enabled
    # ============================================================================
    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        # ============================================================================
        # ASSERTIONS - Catch invalid option combinations at eval time
        # ============================================================================
        assertions = [
          (obsLib.mkSslAssertion {
            inherit (cfg) enableSSL domain;
            moduleName = "services.loki-nixlab";
          })
          {
            assertion = !cfg.ruler.enable || cfg.ruler.alertmanagerUrl != null;
            message = "services.loki-nixlab.ruler.enable needs services.loki-nixlab.ruler.alertmanagerUrl.";
          }
        ];

        # ----------------------------------------------------------------------------
        # DIRECTORY SETUP - Create necessary directories with proper permissions
        # ----------------------------------------------------------------------------
        systemd.tmpfiles.rules = [
          "d ${cfg.dataDir} 0770 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/chunks 0770 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/index 0770 ${cfg.user} ${cfg.group} -"
          "d ${cfg.dataDir}/wal 0770 ${cfg.user} ${cfg.group} -"
        ];

        # ----------------------------------------------------------------------------
        # USER SETUP - Create dedicated system users
        # ----------------------------------------------------------------------------
        users.users = lib.mkMerge (
          [
            {
              ${cfg.user} = {
                isSystemUser = true;
                group = cfg.group;
                home = cfg.dataDir;
                description = "Loki service user";
                uid = cfg.uid;
              };
            }
          ]
          ++ map (u: {${u} = {extraGroups = [cfg.group];};}) cfg.extraUsers
        );

        users.groups.${cfg.group} = {};

        # ----------------------------------------------------------------------------
        # PERMISSIONS - fix ownership every boot, after dataDir is actually mounted
        #
        # tmpfiles' "d" rules above only create these directories if missing — they
        # never fix ownership on an already-existing one, and a separate-mount
        # dataDir can race tmpfiles at boot before the mount exists. This oneshot
        # waits for the real mount and then recursively chowns, fixing both that
        # race and any UID/GID drift from a rebuild.
        # ----------------------------------------------------------------------------
        systemd.services.loki-permissions = obsLib.mkDataDirPermissionsService {
          inherit pkgs;
          dataDir = cfg.dataDir;
          user = cfg.user;
          group = cfg.group;
          requiredBy = ["loki.service"];
        };

        # ----------------------------------------------------------------------------
        # LOKI SERVICE - Configure the systemd service
        # ----------------------------------------------------------------------------
        systemd.services.loki = {
          description = "Loki Log Aggregation System";
          wantedBy = ["multi-user.target"];
          after = ["network.target" "loki-permissions.service" "time-sync.target"];
          wants = ["time-sync.target"];

          serviceConfig =
            obsLib.mkServiceHardening {
              writablePaths = [cfg.dataDir];
              extraHardening = true;
            }
            // {
              Type = "simple";
              User = cfg.user;
              Group = cfg.group;
              ExecStart = "${cfg.package}/bin/loki --config.file=${cfg.dataDir}/loki.yaml";
              Restart = "on-failure";
              RestartSec = "10s";
              # Loki flushes in-memory data to chunks on stop; the default 90s
              # timeout can SIGKILL it mid-flush and leave a damaged WAL.
              TimeoutStopSec = "5min";
            };

          preStart = let
            lokiConfig = import ./_internals/rendered.nix {inherit cfg lib;};

            jsonFile =
              builtins.toFile "loki.json"
              (builtins.toJSON lokiConfig);

            yamlTmp = "${cfg.dataDir}/loki.yaml.tmp";

            rulesJson =
              builtins.toFile "loki-rules.json"
              (builtins.toJSON {groups = cfg.ruler.groups;});
          in ''
            ${pkgs.remarshal}/bin/remarshal \
              -i ${jsonFile} \
              -o ${yamlTmp} \
              -if json \
              -of yaml

            install -m 660 -o ${cfg.user} -g ${cfg.group} ${yamlTmp} ${cfg.dataDir}/loki.yaml

            mkdir -p ${cfg.dataDir}/data ${cfg.dataDir}/chunks ${cfg.dataDir}/wal ${cfg.dataDir}/compactor
            ${lib.optionalString cfg.ruler.enable ''
              # "fake" is the tenant name Loki uses when auth_enabled = false.
              mkdir -p ${cfg.dataDir}/rules/fake ${cfg.dataDir}/rules-tmp
              ${pkgs.remarshal}/bin/remarshal -i ${rulesJson} -o ${cfg.dataDir}/rules/fake/journal.yaml -if json -of yaml
            ''}
            chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
          '';
        };

        # ----------------------------------------------------------------------------
        # NGINX REVERSE PROXY - Only configured if domain is set
        # ----------------------------------------------------------------------------
        services.nginx.enable = lib.mkIf (cfg.domain != null) true;
        services.nginx.virtualHosts = obsLib.mkNginxVirtualHost {
          inherit (cfg) domain listenAddress port enableSSL;
        };

        # ----------------------------------------------------------------------------
        # FIREWALL - Open necessary ports if requested
        # ----------------------------------------------------------------------------
        networking.firewall.allowedTCPPorts =
          lib.mkIf cfg.openFirewall
          (obsLib.mkFirewallPorts {
            inherit (cfg) domain listenAddress;
            servicePort = cfg.port;
            extraPorts = lib.optionals cfg.openGrpcFirewall [cfg.grpcPort];
          });
      }
      # Automatic recovery from a corrupt write-ahead log.
      (obsLib.mkWalSelfHeal {
        inherit pkgs;
        unit = "loki";
        walDir = "${cfg.dataDir}/wal";
        user = cfg.user;
        group = cfg.group;
      })
    ]);
  };
}
