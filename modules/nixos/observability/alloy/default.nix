{self, ...}: {
  flake.lib.alloyRendered = {config, ...}: let
    cfg = config.services.observability-alloy;
  in
    (import ./_internals/rendered.nix {
      inherit cfg;
      hostName = config.networking.hostName;
    })
    + cfg.extraConfig;

  flake.nixosModules.servc--observability-alloy = self.lib.obsLib.keyed "observability:alloy" ({
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.observability-alloy;
    obsLib = self.lib.obsLib;

    baseAlloyConfig = import ./_internals/rendered.nix {
      inherit cfg;
      hostName = config.networking.hostName;
    };

    alloyConfig = baseAlloyConfig + cfg.extraConfig;
    configFile = pkgs.writeText "alloy-config.alloy" alloyConfig;
  in {
    options.services.observability-alloy = {
      enable = lib.mkEnableOption "Grafana Alloy log collector";

      port = lib.mkOption {
        type = lib.types.port;
        default = 12345;
        description = "Port of Alloy's HTTP server (UI, /metrics). Bound to loopback.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.grafana-alloy;
        defaultText = lib.literalExpression "pkgs.grafana-alloy";
        description = "The Grafana Alloy package to use.";
      };

      lokiUrl = lib.mkOption {
        type = lib.types.str;
        default = "http://127.0.0.1:3100/loki/api/v1/push";
        description = "Loki push endpoint.";
      };

      afterLocalLoki = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Order Alloy after the local loki.service. Set false when Loki does not run on this host.";
      };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "River configuration appended to the base pipelines (journal and /var/log/*.log).";
      };

      uid = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Pinned uid for the alloy user.";
      };

      gid = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Pinned gid for the alloy group.";
      };

      extraUsers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["alice"];
        description = "Extra users to add to the alloy group (the main user is added automatically).";
      };
    };

    config = lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/alloy 0750 alloy alloy -"
        "d /var/lib/alloy/data 0750 alloy alloy -"
      ];

      users.users = lib.mkMerge (
        [
          {
            alloy = {
              isSystemUser = true;
              group = "alloy";
              description = "Grafana Alloy service user";
              uid = cfg.uid;
              extraGroups = ["systemd-journal"];
            };
          }
        ]
        ++ map (u: {${u} = {extraGroups = ["alloy"];};}) cfg.extraUsers
      );

      users.groups.alloy = {gid = cfg.gid;};

      systemd.services.alloy-permissions = obsLib.mkDataDirPermissionsService {
        inherit pkgs;
        dataDir = "/var/lib/alloy";
        user = "alloy";
        group = "alloy";
        requiredBy = ["alloy.service"];
      };

      systemd.services.alloy = {
        description = "Grafana Alloy Telemetry Collector";
        wantedBy = ["multi-user.target"];
        after = ["network.target"] ++ lib.optional cfg.afterLocalLoki "loki.service" ++ ["alloy-permissions.service" "time-sync.target"];
        wants = ["time-sync.target"];

        serviceConfig =
          obsLib.mkServiceHardening {
            writablePaths = ["/var/lib/alloy"];
            allowJIT = true;
            extraHardening = true;
          }
          // {
            Type = "simple";
            User = "alloy";
            Group = "alloy";
            # Alloy reads process and journal metadata; keep /proc fully visible.
            ProtectProc = "default";
            ProcSubset = "all";
            ExecStart = "${cfg.package}/bin/alloy run --disable-reporting --server.http.listen-addr=127.0.0.1:${toString cfg.port} --storage.path=/var/lib/alloy/data /var/lib/alloy/config.alloy";
            Restart = "on-failure";
            RestartSec = "10s";
          };

        preStart = ''
          # Copy Alloy configuration
          install -m 640 -o alloy -g alloy ${configFile} /var/lib/alloy/config.alloy

          # Ensure data directory exists
          mkdir -p /var/lib/alloy/data
          chown -R alloy:alloy /var/lib/alloy
        '';
      };
    };
  });
}
