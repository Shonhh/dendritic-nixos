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
      options.mySystem.apps.zoom.enable = lib.mkEnableOption "Zoom-US Application";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          zoom-us
        ];
      };
    };
}
