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
    harness = import ./_harness {inherit inputs self;};
    hosts = {
      stable = harness.mkTestHost {modules = [harness.fullStack];};
      unstable = harness.mkTestHost {
        nixpkgs = inputs.nixpkgs-unstable;
        modules = [harness.fullStack];
      };
      minimal = harness.mkTestHost {modules = [harness.minimalStack];};
    };
  in {
    checks = lib.optionalAttrs (system == "x86_64-linux") (
      (lib.foldl' (acc: name:
        acc
        // self.lib.observabilityHostChecks {
          inherit pkgs name;
          hostConfig = hosts.${name}.config;
        }) {} ["stable" "unstable"])
      // {
        # Whole-system evaluation + build of each harness host.
        toplevel-stable = hosts.stable.config.system.build.toplevel;
        toplevel-minimal = hosts.minimal.config.system.build.toplevel;
      }
      // {
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
