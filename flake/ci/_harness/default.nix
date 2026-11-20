# flake/ci/_harness/default.nix
{
  inputs,
  self,
}: let
  base = {...}: {
    networking.hostName = "testhost";
    system.stateVersion = "24.11";
    boot.loader.grub.enable = false;
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
    };
  };
in {
  # NOTE: no specialArgs at all. A module that needs one fails here.
  mkTestHost = {
    nixpkgs ? inputs.nixpkgs,
    modules ? [],
  }:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [self.nixosModules.stack--observability base] ++ modules;
    };

  # Consumer who uses sops-nix + the optional nsops modules (nixlab's situation).
  withSops = {pkgs, ...}: {
    imports = [
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.nsops--observability-alertmanager
      self.nixosModules.nsops--observability-grafana
    ];
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.validateSopsFiles = false;
    services.observability-alertmanager.secretsFile = pkgs.writeText "alertmanager.env" "";
    services.observability-grafana.secretsFile = pkgs.writeText "grafana.yaml" "";
  };

  # A stranger with some other secret manager: no sops-nix in the module set at all.
  withoutSops = {
    services.observability-alertmanager.environmentFile = "/run/secrets/alertmanager.env";
    services.observability-grafana.credentialsFile = "/run/secrets/grafana-admin";
    services.observability-grafana.secretKeyFile = "/run/secrets/grafana-secret-key";
  };

  fullStack = {
    users.users.testuser.isNormalUser = true;
    services.observability-loki.extraUsers = ["testuser"];
    services.observability-grafana.extraUsers = ["testuser"];
    services.observability-alloy.extraUsers = ["testuser"];
    services.observability-ntfy.extraUsers = ["testuser"];
    services.observability-prometheus.extraUsers = ["testuser"];

    services.observability = {
      enable = true;
      publicHost = "192.0.2.10";
      probes.gateway = "192.0.2.1";
      probes.icmpTargets = ["192.0.2.20"];
      probes.tcpTargets = ["127.0.0.1:8080"];
      access.interfaces = ["eth0"];
      notifications.ntfyAuth.enable = true;
      notifications.topics.storage.matchers = ["category=~\"storage|backup\""];
      loki.maintenance.enable = true;
      prometheus.maintenance.enable = true;
      prometheus.maintenance.exporters.systemd = true;
      integrations.traefik.enable = true;
      integrations.cadvisor.enable = true;
      integrations.postgres.enable = true;
    };
  };

  minimalStack = {services.observability.enable = true;};
}
