{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages = {
      helium = pkgs.callPackage ../packages/helium.nix { };
      ryubing = pkgs.callPackage ../packages/ryubing.nix { };
    };
  };
}
