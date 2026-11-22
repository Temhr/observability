{
  self,
  lib,
  ...
}: let
  aliases = builtins.fromJSON (builtins.readFile ./option-aliases.json);
  # Options declared only by the optional sops modules (nsops--observability-*).
  isSops = a: lib.last a.new == "secretsFile";
  mkAliases = as: map (a: lib.mkRenamedOptionModule a.old a.new) as;
in {
  # Imported by the stack, so every consumer of the stack gets these.
  flake.nixosModules.compat-options = self.lib.obsLib.keyed "observability:compat-options" {
    imports = mkAliases (lib.filter (a: !(isSops a)) aliases);
  };

  # Imported only by the OLD nsops--alertmanager / nsops--grafana names.
  flake.nixosModules.compat-sops-options = self.lib.obsLib.keyed "observability:compat-sops-options" {
    imports = mkAliases (lib.filter isSops aliases);
  };
}
