{ ... }:

{
  flake.nixosModules.eden =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.games.eden;
      eden-nightly = pkgs.callPackage ../../packages/eden.nix { };
    in
    {
      options.mySystem.games.eden.enable = lib.mkEnableOption "Eden Nightly Switch emulator";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = [
          eden-nightly
        ];
      };
    };
}
