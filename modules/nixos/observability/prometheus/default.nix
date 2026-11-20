{self, ...}: {
  flake.nixosModules.servc--observability-prometheus = self.lib.obsLib.keyed "observability:prometheus" ({
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.observability-prometheus;
    obsLib = self.lib.obsLib;

    options = import ./_internals/options.nix {inherit lib pkgs;};
    prometheusConfig = import ./_internals/config.nix {inherit config lib pkgs obsLib;};
  in {
    imports = [
      self.nixosModules.systm--observability-host-exporters
    ];

    options.services.observability-prometheus = options;

    config = lib.mkIf cfg.enable (lib.mkMerge [
      prometheusConfig
      # Automatic recovery when Prometheus crashes on a corrupt WAL.
      (obsLib.mkWalSelfHeal {
        inherit pkgs;
        unit = "prometheus";
        walDir = "${cfg.dataDir}/data/wal";
        user = "prometheus";
        group = "prometheus";
      })
    ]);
  });

  # Exposed for flake/ci/observability-checks.nix, which consumes them by name.
  flake.lib.prometheusRendered = import ./_internals/rendered.nix;
  flake.lib.prometheusMaintenanceAlerts = import ./_internals/maintenance-alerts.nix;
}
