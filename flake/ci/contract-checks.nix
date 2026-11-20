{
  self,
  inputs,
  lib,
  ...
}: {
  perSystem = {system, ...}: let
    harness = import ./_harness {inherit inputs self;};
  in {
    checks = lib.optionalAttrs (system == "x86_64-linux") {
      # Importing individual modules on top of the stack must be harmless.
      double-import =
        (harness.mkTestHost {
          modules = [
            harness.minimalStack
            self.nixosModules.servc--loki-nixlab
            self.nixosModules.servc--grafana-nixlab
            self.nixosModules.servc--prometheus-nixlab
          ];
        }).config.system.build.toplevel;
    };
  };
}
