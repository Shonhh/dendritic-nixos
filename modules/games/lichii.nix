{ ... }:

{
  flake.nixosModules.lichii =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.games.lichii;
      lichii = pkgs.callPackage ../../packages/lichii.nix { };
    in
    {
      options.mySystem.games.lichii.enable = lib.mkEnableOption "Lichii Switch 2 emulator";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = [
          lichii
        ];
      };
    };
}
