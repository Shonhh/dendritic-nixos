{ ... }:

{
  flake.nixosModules.zoom =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.zoom;
    in
    {
      options.mySystem.apps.zoom.enable = lib.mkEnableOption "Minecraft and its Launchers";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          zoom-us
        ];
      };
    };
}
