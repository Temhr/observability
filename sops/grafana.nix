{self, ...}: {
  flake.nixosModules.nsops--observability-grafana = self.lib.obsLib.keyed "observability:sops-grafana" ({
    config,
    lib,
    ...
  }: let
    cfg = config.services.observability-grafana;
  in {
    imports = [];

    options.services.observability-grafana.secretsFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the sops-encrypted grafana secrets file.
        Required when the service is enabled; supplied by the consumer (the encrypted file is not part of this repository).
        Override per-host if needed.
      '';
    };

    config = lib.mkIf cfg.enable {
      sops.secrets = let
        common = {
          sopsFile = cfg.secretsFile;
          owner = cfg.user;
          group = cfg.group;
          restartUnits = ["grafana.service"];
        };
      in {
        GRAFANA_ADMIN_PASSWORD = common;
        GRAFANA_SECRET_KEY = common;
      };

      # Wire the decrypted files into the service module.
      services.observability-grafana = {
        credentialsFile = lib.mkDefault config.sops.secrets.GRAFANA_ADMIN_PASSWORD.path;
        secretKeyFile = lib.mkDefault config.sops.secrets.GRAFANA_SECRET_KEY.path;
      };
    };
  });
}
