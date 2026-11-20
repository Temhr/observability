{self, ...}: {
  flake.nixosModules.servc--prometheus-nixlab = self.lib.obsLib.keyed "observability:prometheus" ({
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.prometheus-nixlab;
    obsLib = self.lib.obsLib;

    options = import ./_internals/options.nix {inherit lib pkgs;};
    prometheusConfig = import ./_internals/config.nix {inherit config lib pkgs obsLib;};
  in {
    imports = [
      self.nixosModules.systm--host-exporters-nixlab
    ];

    options.services.prometheus-nixlab = options;

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
