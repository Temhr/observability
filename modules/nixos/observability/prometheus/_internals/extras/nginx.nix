{
  config,
  lib,
  obsLib,
}: let
  cfg = config.services.observability-prometheus;
in {
  enable = lib.mkIf (cfg.domain != null) true;
  virtualHosts = obsLib.mkNginxVirtualHost {
    inherit (cfg) domain listenAddress port enableSSL;
  };
}
