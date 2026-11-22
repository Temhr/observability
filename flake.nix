{
  description = "Observability stack (Prometheus, Loki, Alloy, Grafana, Alertmanager, ntfy) as composable NixOS modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        (inputs.import-tree ./flake)
        (inputs.import-tree ./modules)
        (inputs.import-tree ./sops)
        (inputs.import-tree ./stacks)
        (inputs.import-tree ./compat)
      ];
    };
}
