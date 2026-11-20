{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages = {
      helium = pkgs.callPackage ../packages/helium.nix { };
      eden = pkgs.callPackage ../packages/eden.nix { };
      lichii = pkgs.callPackage ../packages/lichii.nix { };
      mkw-recomp = pkgs.callPackage ../packages/mkw-recomp.nix { };
    };
  };
}
