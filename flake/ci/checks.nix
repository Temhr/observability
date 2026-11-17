{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    formatter = pkgs.alejandra;
    checks.pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
      src = ./../..;
      hooks = {
        alejandra.enable = true;
        deadnix.enable = true;
        check-merge-conflicts.enable = true;
        forbid-new-submodules.enable = true;
        check-added-large-files.enable = true;
      };
    };
    devShells.default = pkgs.mkShell {
      packages = [pkgs.prometheus.cli pkgs.prometheus-alertmanager pkgs.remarshal pkgs.gettext pkgs.jq pkgs.shellcheck pkgs.alejandra pkgs.deadnix];
    };
  };
}
