# Observability port defaults (mkDefault). Moved from nixlab/modules/ports.nix.
{...}: {
  flake.nixosModules.systm--ports-ntfy = {lib, ...}: {
    services.ntfy-nixlab.port = lib.mkDefault 2586;
  };
  flake.nixosModules.systm--ports-loki = {lib, ...}: {
    services.loki-nixlab.port = lib.mkDefault 3100;
    services.loki-nixlab.grpcPort = lib.mkDefault 9096;
    services.loki-nixlab.alloyPort = lib.mkDefault 12345;
  };
  flake.nixosModules.systm--ports-grafana = {lib, ...}: {
    services.grafana-nixlab.port = lib.mkDefault 3101;
  };
  flake.nixosModules.systm--ports-prometheus = {lib, ...}: {
    services.prometheus-nixlab.port = lib.mkDefault 9090;
    services.prometheus-nixlab.blackboxPort = lib.mkDefault 9115;
    services.prometheus-nixlab.smartctlPort = lib.mkDefault 9633;
    services.prometheus-nixlab.systemdExporterPort = lib.mkDefault 9558;
  };
  flake.nixosModules.systm--ports-alertmanager = {lib, ...}: {
    services.alertmanager-nixlab.port = lib.mkDefault 9093;
    services.alertmanager-nixlab.clusterPort = lib.mkDefault 9094;
  };
}
