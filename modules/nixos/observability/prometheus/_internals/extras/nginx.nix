{
  config,
  lib,
  obsLib,
}: let
  cfg = config.services.prometheus-nixlab;
in {
  enable = lib.mkIf (cfg.domain != null) true;
  virtualHosts = obsLib.mkNginxVirtualHost {
    inherit (cfg) domain listenAddress port enableSSL;
  };
}
