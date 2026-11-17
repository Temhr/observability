{...}: {
  perSystem = {pkgs, ...}: let
    mk = name: file: {
      type = "app";
      meta.description = "Observability ${name}";
      program = toString (pkgs.writeShellScript name (builtins.readFile file));
    };
  in {
    apps.mon-check = mk "mon-check" ../../bin/mon-check.sh;
    apps.mon-snapshot = mk "mon-snapshot" ../../bin/mon-snapshot.sh;
    apps.mon-unitdiff = mk "mon-unitdiff" ../../bin/mon-unitdiff.sh;
  };
}
