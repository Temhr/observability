{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    harness = import ./_harness {inherit inputs self;};
    host = harness.mkTestHost {modules = [harness.fullStack harness.withSops];};
    ours = opt: lib.hasPrefix "services.observability" (lib.showOption opt.loc);
    doc = pkgs.nixosOptionsDoc {
      options = lib.filterAttrs (n: _: n == "services") host.options;
      warningsAreErrors = false; # flip to true in Part 13
      transformOptions = opt:
        opt
        // {
          visible = opt.visible && ours opt;
          declarations = map (d: lib.removePrefix "${toString self}/" (toString d)) opt.declarations;
        };
    };
  in {
    packages.options-doc = doc.optionsCommonMark;
    checks = lib.optionalAttrs (system == "x86_64-linux") {
      options-doc-fresh = pkgs.runCommand "options-doc-fresh" {nativeBuildInputs = [pkgs.diffutils];} ''
        diff -u ${self}/docs/reference/options.md ${doc.optionsCommonMark} \
          || { echo "stale: nix build .#options-doc -o /tmp/o && cp -L /tmp/o docs/reference/options.md"; exit 1; }
        touch $out
      '';
    };
  };
}
