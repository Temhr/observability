{self, inputs, lib, ...}: {
  perSystem = {pkgs, system, ...}: let
    harness = import ../flake/ci/_harness {inherit inputs self;};
    nm = self.nixosModules;
    newNames = ["default" "servc--observability-prometheus" "servc--observability-alertmanager" "servc--observability-ntfy" "servc--observability-loki" "servc--observability-alloy" "servc--observability-grafana" "systm--observability-host-exporters" "systm--observability-maintenance-log" "systm--observability-backup" "nsops--observability-alertmanager" "nsops--observability-grafana"];
    oldNames = ["servc--prometheus-nixlab" "servc--alertmanager-nixlab" "servc--ntfy-nixlab" "servc--loki-nixlab" "servc--alloy-nixlab" "servc--grafana-nixlab" "systm--host-exporters-nixlab" "systm--maintenance-log-nixlab" "systm--observability-backup-nixlab" "nsops--alertmanager" "nsops--grafana"];
    missing = lib.filter (n: !(nm ? ${n})) (newNames ++ oldNames);
    aliases = builtins.fromJSON (builtins.readFile ./option-aliases.json);
    deadTargets = lib.filter (a: !(lib.hasAttrByPath a.new (hosts.stable.options))) aliases;
    hosts.stable = harness.mkTestHost {modules = [harness.fullStack harness.withSops];};
  in {
    checks = lib.optionalAttrs (system == "x86_64-linux") {
      compat-names = pkgs.runCommand "compat-names" {} ''
        ${lib.optionalString (missing != []) ''echo "missing module names: ${toString missing}"; exit 1''}
        touch $out
      '';
      compat-alias-targets = pkgs.runCommand "compat-alias-targets" {} ''
        ${lib.optionalString (deadTargets != []) ''echo "alias targets that do not exist: ${builtins.toJSON deadTargets}"; exit 1''}
        touch $out
      '';
      # An old-style setting at a LOWER priority must lose to a new-style plain setting.
      # (If the alias dropped the priority, both would be equal and the list would concatenate.)
      alias-priority = let
        h = harness.mkTestHost {
          modules = [
            harness.minimalStack
            {
              services.nixlab-observability.access.interfaces = lib.mkDefault ["eth0"];
              services.observability.access.interfaces = ["eth1"];
            }
          ];
        };
      in
        pkgs.runCommand "alias-priority" {} ''
          test '${builtins.toJSON h.config.services.observability.access.interfaces}' = '["eth1"]'
          touch $out
        '';
      # A consumer written against 0.2: old module names AND old option names.
      old-style-consumer =
        (harness.mkTestHost {
          modules = [
            nm.servc--loki-nixlab
            nm.systm--maintenance-log-nixlab
            {services.maintenance-log-nixlab.enable = true;}
          ];
        }).config.system.build.toplevel;
    };
  };
}
