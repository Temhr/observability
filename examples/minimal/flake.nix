{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    observability.url = "github:Temhr/observability";
    observability.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    nixpkgs,
    observability,
    ...
  }: {
    nixosConfigurations.demo = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        observability.nixosModules.stack--observability
        {
          services.nixlab-observability.enable = true;
          services.alertmanager-nixlab.environmentFile = "/run/secrets/alertmanager.env";
          services.grafana-nixlab.credentialsFile = "/run/secrets/grafana-admin";
          services.grafana-nixlab.secretKeyFile = "/run/secrets/grafana-secret-key";
          # A real machine also needs hardware/boot configuration.
          system.stateVersion = "24.11";
          boot.loader.grub.enable = false;
          fileSystems."/" = {
            device = "none";
            fsType = "tmpfs";
          };
        }
      ];
    };
  };
}
