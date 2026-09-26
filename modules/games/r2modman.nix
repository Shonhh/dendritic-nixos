{ ... }:

{
  flake.nixosModules.r2modman =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.games.r2modman;
    in
    {
      options.mySystem.games.r2modman.enable = lib.mkEnableOption "Unofficial Thunderstore Mod Manager";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          r2modman
        ];
      };
    };
}
