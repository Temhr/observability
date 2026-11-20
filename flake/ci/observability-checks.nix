# Build-time validation of the observability stack's generated configuration.
{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    inherit (self.lib) prometheusMaintenanceAlerts;
    toJson = name: value: pkgs.writeText name (builtins.toJSON value);
    tools = [pkgs.prometheus.cli pkgs.prometheus-alertmanager pkgs.remarshal pkgs.gettext];
    allFeatures = {
      traefik = true;
      containers = true;
      postgres = true;
      backup = true;
      dns = true;
      blackboxProbes = true;
      alertmanagerWired = true;
    };

    # Fake machines. Names become check names: prom-config-<name>, toplevel-<name>, ...
    harness = import ./_harness {inherit inputs self;};
    hosts = {
      # a nixlab-like consumer (uses sops-nix + nsops modules), stable nixpkgs
      stable = harness.mkTestHost {modules = [harness.fullStack harness.withSops];};
      # same, on unstable nixpkgs
      unstable = harness.mkTestHost {
        nixpkgs = inputs.nixpkgs-unstable;
        modules = [harness.fullStack harness.withSops];
      };
      # a stranger: no sops-nix at all
      external = harness.mkTestHost {modules = [harness.fullStack harness.withoutSops];};
      # smallest possible: only `enable = true`
      minimal = harness.mkTestHost {modules = [harness.minimalStack];};
      # >>> SPOT B: a new host entry goes here (after `minimal`, or after `alias`)
      domain = harness.mkTestHost {
        modules = [
          harness.minimalStack
          {
            # All five service modules declare `domain`. openFirewall = true makes the golden capture the 80/443 rules too.
            services.nixlab-observability.openFirewall = true;
            services.loki-nixlab.domain = "loki.example.test";
            services.prometheus-nixlab.domain = "prometheus.example.test";
            services.alertmanager-nixlab.domain = "alertmanager.example.test";
            services.grafana-nixlab.domain = "grafana.example.test";
            services.ntfy-nixlab.domain = "ntfy.example.test";
          }
        ];
      };
    };
    # >>> SPOT A: a new `let` binding goes here (after `hosts = {…};`, before `in`)
    domainEffects = let
      c = hosts.domain.config;
    in {
      nginxEnabled = c.services.nginx.enable;
      vhosts = builtins.attrNames c.services.nginx.virtualHosts;
      firewallTcp = c.networking.firewall.allowedTCPPorts;
      failingAssertions = map (a: a.message) (lib.filter (a: !a.assertion) c.assertions);
    };
  in {
    # >>> SPOT C: a new top-level attribute goes here (packages.* …), above `checks =`
    packages.fingerprint = let
      c = hosts.stable.config;
      pick = names: set: lib.filterAttrs (n: _: builtins.elem n names) set;
      unitNames = ["prometheus" "loki" "alloy" "grafana" "alertmanager" "ntfy" "prometheus-node-exporter" "loki-permissions" "grafana-permissions" "alloy-permissions" "ntfy-permissions" "prometheus-permissions" "loki-wal-recover" "prometheus-wal-recover" "ntfy-provision" "observability-backup" "maintenance-log-metrics"];
      dump = name: value:
        pkgs.writeText name (builtins.unsafeDiscardStringContext (builtins.toJSON value));
    in
      pkgs.linkFarm "fingerprint" [
        {
          name = "units.json";
          path = dump "units.json" (lib.mapAttrs (_: s: {
            inherit (s) serviceConfig;
            after = s.after or [];
            wants = s.wants or [];
            requires = s.requires or [];
            preStart = s.preStart or "";
            script = s.script or "";
          }) (pick unitNames c.systemd.services));
        }
        {
          name = "users.json";
          path = dump "users.json" (lib.mapAttrs (_: u: {inherit (u) uid group extraGroups;}) (pick ["loki" "prometheus" "grafana" "ntfy" "alloy"] c.users.users));
        }
        {
          name = "firewall.json";
          path = dump "firewall.json" {inherit (c.networking.firewall) allowedTCPPorts interfaces;};
        }
        {
          name = "tmpfiles.json";
          path = dump "tmpfiles.json" c.systemd.tmpfiles.rules;
        }
        {
          name = "prometheus.json";
          path = dump "prometheus.json" (self.lib.prometheusRendered {
            config = c;
            lib = pkgs.lib;
          });
        }
        {
          name = "alertmanager.json";
          path = dump "alertmanager.json" c.services.prometheus.alertmanager.configuration;
        }
        {
          name = "loki-ruler.json";
          path = dump "loki-ruler.json" c.services.loki-nixlab.ruler.groups;
        }
        {
          name = "datasources.json";
          path = dump "datasources.json" c.services.grafana-nixlab.provisioning.datasources;
        }
        {
          name = "loki.json";
          path = dump "loki.json" (self.lib.lokiRendered {
            config = c;
            lib = pkgs.lib;
          });
        }
        {
          name = "alloy.alloy";
          path = dump "alloy.alloy" (self.lib.alloyRendered {
            config = c;
            lib = pkgs.lib;
          });
        }
        {
          name = "sops.json";
          path = dump "sops.json" (lib.mapAttrs (_: s: {inherit (s) owner restartUnits;}) c.sops.secrets);
        }
      ];

    packages.goldens = pkgs.linkFarm "goldens" [
      {
        name = "domain-effects.json";
        path = toJson "domain-effects.json" domainEffects;
      }
    ];
    checks = lib.optionalAttrs (system == "x86_64-linux") (
      # prom-config-<h>, prom-rules-<h>, alertmanager-config-<h> for each of these three
      (lib.foldl' (acc: name:
        acc
        // self.lib.observabilityHostChecks {
          inherit pkgs name;
          hostConfig = hosts.${name}.config;
        }) {} ["stable" "unstable" "external"])
      // {
        # >>> SPOT D: a new check goes here, directly under this `// {` line
        golden-domain-effects = pkgs.runCommand "golden-domain-effects" {nativeBuildInputs = [pkgs.jq pkgs.diffutils];} ''
          jq -S . ${toJson "got.json" domainEffects} > got.json
          jq -S . ${./_golden}/domain-effects.json > want.json
          diff -u want.json got.json || { echo "side effects changed; if intended: nix build .#goldens -o /tmp/g && cp -L /tmp/g/*.json flake/ci/_golden/"; exit 1; }
          touch $out
        '';

        loki-config = pkgs.runCommand "loki-config" {nativeBuildInputs = [pkgs.grafana-loki pkgs.remarshal];} ''
          remarshal -i ${toJson "loki.json" (self.lib.lokiRendered {
            config = hosts.stable.config;
            lib = pkgs.lib;
          })} -if json -of yaml -o loki.yml
          loki -config.file=loki.yml -verify-config
          touch $out
        '';
        alloy-config = pkgs.runCommand "alloy-config" {nativeBuildInputs = [pkgs.grafana-alloy];} ''
          cp ${pkgs.writeText "config.alloy" (self.lib.alloyRendered {
            config = hosts.stable.config;
            lib = pkgs.lib;
          })} config.alloy
          alloy fmt config.alloy > /dev/null      # parses the file; non-zero exit on a syntax error
          touch $out
        '';

        loki-runbook-coverage = pkgs.runCommand "loki-runbook-coverage" {nativeBuildInputs = [pkgs.jq];} ''
          jq -r '[.. | objects | .alert? // empty] | unique[]' \
            ${toJson "loki-groups.json" hosts.stable.config.services.loki-nixlab.ruler.groups} > alerts.txt
          [ -s alerts.txt ] || { echo "found no Loki alerts: did the structure change?"; exit 1; }
          missing=0
          for a in $(cat alerts.txt); do
            if [ ! -f ${self}/docs/runbooks/$a.md ] && ! grep -qx "$a" ${self}/docs/runbooks/_todo.txt; then
              echo "no runbook for Loki alert $a"; missing=1
            fi
          done
          [ $missing = 0 ]
          touch $out
        '';

        port-defaults = let
          s = hosts.minimal.config.services;
          got = {
            ntfy = s.ntfy-nixlab.port;
            loki = s.loki-nixlab.port;
            lokiGrpc = s.loki-nixlab.grpcPort;
            grafana = s.grafana-nixlab.port;
            prometheus = s.prometheus-nixlab.port;
            blackbox = s.prometheus-nixlab.blackboxPort;
            smartctl = s.prometheus-nixlab.smartctlPort;
            systemdExporter = s.prometheus-nixlab.systemdExporterPort;
            alertmanager = s.alertmanager-nixlab.port;
            alertmanagerCluster = s.alertmanager-nixlab.clusterPort;
            alloy = s.alloy-nixlab.port;
          };
          want = {
            ntfy = 2586;
            loki = 3100;
            lokiGrpc = 9096;
            grafana = 3101;
            prometheus = 9090;
            blackbox = 9115;
            smartctl = 9633;
            systemdExporter = 9558;
            alertmanager = 9093;
            alertmanagerCluster = 9094;
            alloy = 12345;
          };
        in
          pkgs.runCommand "port-defaults" {} ''
            if [ '${builtins.toJSON got}' != '${builtins.toJSON want}' ]; then
              echo "port defaults changed"
              echo 'got:  ${builtins.toJSON got}'
              echo 'want: ${builtins.toJSON want}'
              exit 1
            fi
            touch $out
          '';

        runbook-url-consistent = pkgs.runCommand "runbook-url-consistent" {} ''
          test "${hosts.minimal.config.services.prometheus-nixlab.runbookBaseUrl}" = "${(prometheusMaintenanceAlerts {features = allFeatures;}).runbookBase or hosts.minimal.config.services.prometheus-nixlab.runbookBaseUrl}"
          touch $out
        '';

        # Whole-system build of three fake machines.
        toplevel-stable = hosts.stable.config.system.build.toplevel;
        toplevel-external = hosts.external.config.system.build.toplevel;
        toplevel-minimal = hosts.minimal.config.system.build.toplevel;

        # Fails while ANY nixlab-internal dependency remains in this repository.
        no-nixlab-coupling = pkgs.runCommand "no-nixlab-coupling" {nativeBuildInputs = [pkgs.gnugrep];} ''
          cd ${self}
          if grep -rEn --exclude=observability-checks.nix \
              'nixlabLib|hostMeta|allHosts|hostsMeta|serviceRegistry|config\.nixlab|M2-REMOVE|self\.nixosConfigurations' \
              modules stacks sops flake; then
            echo "nixlab-internal coupling found (see matches above)" >&2
            exit 1
          fi
          touch $out
        '';

        # Every alert needs docs/runbooks/<Alert>.md, unless it is listed in docs/runbooks/_todo.txt.
        runbook-coverage = pkgs.runCommand "runbook-coverage" {nativeBuildInputs = [pkgs.jq];} ''
          jq -r '.groups[].rules[] | select(.alert) | .alert' ${toJson "rules-all-names.json" {
            groups =
              (prometheusMaintenanceAlerts {
                features = allFeatures;
                expectedMounts = ["/data"];
              }).groups;
          }} | sort -u > alerts.txt
          missing=0
          for a in $(cat alerts.txt); do
            if [ ! -f ${self}/docs/runbooks/$a.md ] && ! grep -qx "$a" ${self}/docs/runbooks/_todo.txt; then
              echo "no runbook for $a"; missing=1
            fi
          done
          [ $missing = 0 ]
          touch $out
        '';

        # Dashboards must carry a uid and schemaVersion, use valid units and thresholds, and not clash.
        dashboard-lint = pkgs.runCommand "dashboard-lint" {nativeBuildInputs = [pkgs.jq];} ''
          cd ${self.lib.grafanaDashboards}
          for f in *.json; do
            jq -e '.uid and .title and .schemaVersion' "$f" >/dev/null || { echo "$f: needs uid, title and schemaVersion"; exit 1; }
            jq -e '[.. | objects | select(has("steps")) | .steps[0].value] | all(. == null)' "$f" >/dev/null || { echo "$f: the first threshold step must be null"; exit 1; }
            jq -e '[.. | objects | .unit? // empty] | index("days") | not' "$f" >/dev/null || { echo "$f: unit days is invalid (use d)"; exit 1; }
          done
          jq -s -e '[.[].uid] | length == (unique | length)' *.json >/dev/null || { echo "duplicate dashboard uids"; exit 1; }
          touch $out
        '';

        # The maintenance helper script must pass shellcheck.
        maintenance-log-shellcheck = pkgs.runCommand "maintenance-log-shellcheck" {nativeBuildInputs = [pkgs.shellcheck];} ''
          shellcheck -s bash ${self.lib.maintenanceLoggerScript}
          touch $out
        '';

        # Validates every rule, including the ones gated behind feature flags.
        prom-rules-all-features = pkgs.runCommand "prom-rules-all-features" {nativeBuildInputs = tools;} ''
          remarshal -i ${toJson "rules-all.json" {groups = (prometheusMaintenanceAlerts {features = allFeatures;}).groups;}} -if json -of yaml -o rules.yml
          promtool check rules rules.yml
          touch $out
        '';

        # Runs the unit tests in ./_tests/prometheus against the rules (without the condition label).
        prom-rule-tests = pkgs.runCommand "prom-rule-tests" {nativeBuildInputs = tools;} ''
          mkdir work && cd work
          remarshal -i ${toJson "rules-no-condition.json" {
            groups =
              (prometheusMaintenanceAlerts {
                features = allFeatures;
                conditionLabel = false;
                expectedMounts = ["/data"];
              }).groups;
          }} -if json -of yaml -o alerts.yml
          cp ${./_tests/prometheus}/*.test.yml .
          promtool test rules *.test.yml
          touch $out
        '';
      }
    );
  };
}
