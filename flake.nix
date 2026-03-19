{
  description = "Dendritic NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # flake-parts requires you to define systems
      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            name = "dendritic-dev-shell";

            # tools that will ONLY be available when you run 'nix develop'
            packages = with pkgs; [
              nixd # The Nix Language Server (for Zed)
              nixfmt # The official Nix code formatter
              statix # Lints your Nix code to find anti-patterns
              deadnix # Finds unused variables in your Nix files
            ];

            shellHook = ''
              echo "========================================="
              echo "Dendritic Master Development Shell Active"
              echo "========================================="
            '';
          };
        };

      imports = [
        (import-tree ./modules) # Auto-loads your features
        ./hosts/nixovm/nixovm.nix # Explicitly loads your grouped host
        ./hosts/omenixos/omenixos.nix
      ];
    };
}
