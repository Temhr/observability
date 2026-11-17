# Test harness for the extraction milestone. Supplies, as nixlab does, the
# special args the modules still expect (M2-REMOVE: S1, S2, S6).
{
  inputs,
  self,
}: {
  mkTestHost = {
    nixpkgs ? inputs.nixpkgs,
    modules ? [],
  }:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # NOTE: `self` and `inputs` are deliberately NOT passed. If any module still
      # needs them, evaluation fails here — that is the S3 regression test.
      specialArgs = {
        nixlabLib = self.lib.nixlabLib; # S1
        hostMeta = {
          address = "192.0.2.10";
          gateway = "192.0.2.1";
          ethIface = "eth0";
          wifiIface = "";
        }; # S2
        allHosts = {}; # S2
      };
      modules =
        [
          inputs.sops-nix.nixosModules.sops
          self.nixosModules.stack--observability
          ({
            lib,
            pkgs,
            ...
          }: {
            # S6: stand-in for nixlab's real option. Empty string means "no main user".
            options.nixlab.mainUser = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
            config = {
              networking.hostName = "testhost";
              system.stateVersion = "24.11";
              boot.loader.grub.enable = false;
              fileSystems."/" = {
                device = "none";
                fsType = "tmpfs";
              };
              # sops-nix needs a key source and (without this) a valid encrypted file at eval time.
              sops.age.keyFile = "/var/lib/sops-nix/key.txt";
              sops.validateSopsFiles = false;
              services.alertmanager-nixlab.secretsFile = pkgs.writeText "alertmanager.env" "";
              services.grafana-nixlab.secretsFile = pkgs.writeText "grafana.yaml" "";
            };
          })
        ]
        ++ modules;
    };

  # Everything on. Exercises every optional branch the stack has.
  fullStack = {
    services.nixlab-observability = {
      enable = true;
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

  minimalStack = {
    services.nixlab-observability.enable = true;
  };
}
