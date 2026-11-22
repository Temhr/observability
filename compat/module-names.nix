# Deprecated pre-0.3 module names. Removed in 0.4.0 — migrate to the names in docs/architecture/public-api.md.
{self, ...}: {
  flake.nixosModules = {
    servc--prometheus-nixlab = {imports = [self.nixosModules.servc--observability-prometheus self.nixosModules.compat-options];};
    servc--alertmanager-nixlab = {imports = [self.nixosModules.servc--observability-alertmanager self.nixosModules.compat-options];};
    servc--ntfy-nixlab = {imports = [self.nixosModules.servc--observability-ntfy self.nixosModules.compat-options];};
    servc--loki-nixlab = {imports = [self.nixosModules.servc--observability-loki self.nixosModules.compat-options];};
    servc--alloy-nixlab = {imports = [self.nixosModules.servc--observability-alloy self.nixosModules.compat-options];};
    servc--grafana-nixlab = {imports = [self.nixosModules.servc--observability-grafana self.nixosModules.compat-options];};
    systm--host-exporters-nixlab = {imports = [self.nixosModules.systm--observability-host-exporters self.nixosModules.compat-options];};
    systm--maintenance-log-nixlab = {imports = [self.nixosModules.systm--observability-maintenance-log self.nixosModules.compat-options];};
    systm--observability-backup-nixlab = {imports = [self.nixosModules.systm--observability-backup self.nixosModules.compat-options];};
    nsops--alertmanager = {imports = [self.nixosModules.nsops--observability-alertmanager self.nixosModules.compat-options self.nixosModules.compat-sops-options];};
    nsops--grafana = {imports = [self.nixosModules.nsops--observability-grafana self.nixosModules.compat-options self.nixosModules.compat-sops-options];};
  };
}
