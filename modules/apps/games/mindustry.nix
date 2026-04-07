{ ... }:

{
  flake.nixosModules.mindustry =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.games.mindustry;
    in
    {
      options.mySystem.games.mindustry.enable = lib.mkEnableOption "Mindustry Game";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          mindustry-wayland
        ];
      };
    };
}
