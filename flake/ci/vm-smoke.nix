{self, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # A package, not a check: `nix flake check` should not need KVM. CI runs it explicitly (Part 9).
    packages = pkgs.lib.optionalAttrs (system == "x86_64-linux") {
      vm-smoke = pkgs.testers.runNixOSTest {
        name = "observability-smoke";
        nodes.machine = {...}: {
          imports = [self.nixosModules.stack--observability];
          services.nixlab-observability.enable = true;
          virtualisation.memorySize = 4096;
          virtualisation.diskSize = 4096;
        };
        testScript = ''
          machine.start()
          machine.wait_for_unit("multi-user.target")
          for unit in ["prometheus", "loki", "grafana", "alertmanager", "ntfy", "alloy"]:
              machine.wait_for_unit(unit + ".service")
          machine.wait_until_succeeds("curl -sf http://127.0.0.1:9090/-/ready")
          machine.wait_until_succeeds("curl -sf http://127.0.0.1:3100/ready")
          machine.wait_until_succeeds("curl -sf http://127.0.0.1:3101/api/health")
          machine.wait_until_succeeds("curl -sf http://127.0.0.1:9093/-/ready")
          machine.wait_until_succeeds("curl -sf http://127.0.0.1:2586/v1/health")
          machine.wait_until_succeeds("curl -sf http://127.0.0.1:12345/-/ready")
          # at least one target scraped, and none down
          machine.wait_until_succeeds("curl -sf 'http://127.0.0.1:9090/api/v1/query?query=count(up)' | grep -q '\"value\"'")
          machine.wait_until_succeeds("curl -sf 'http://127.0.0.1:9090/api/v1/query?query=count(up==0)' | grep -q '\"result\":\\[\\]'")
          machine.succeed("test $(systemctl --failed --no-legend | wc -l) -eq 0")
        '';
      };
    };
  };
}
