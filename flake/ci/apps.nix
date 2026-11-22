{...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    common = with pkgs; [bash coreutils gnugrep gnused gawk curl jq iproute2 findutils];
    mk = {
      name,
      file,
      extra ? [],
      exclude ? [],
    }:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = common ++ extra;
        excludeShellChecks = exclude;
        text = builtins.readFile file;
      };
    scripts = {
      mon-check = mk {
        name = "mon-check";
        file = ../../bin/mon-check.sh;
        exclude = ["SC2015"];
      };
      mon-snapshot = mk {
        name = "mon-snapshot";
        file = ../../bin/mon-snapshot.sh;
      };
      mon-unitdiff = mk {
        name = "mon-unitdiff";
        file = ../../bin/mon-unitdiff.sh;
        extra = [pkgs.diffutils];
        exclude = ["SC2035"];
      };
    };
  in {
    packages = scripts;
    apps =
      lib.mapAttrs (n: p: {
        type = "app";
        program = lib.getExe p;
        meta.description = "Observability ${n}";
      })
      scripts;
  };
}
