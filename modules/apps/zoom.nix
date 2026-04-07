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
      options.mySystem.apps.zoom = {
        enable = lib.mkEnableOption "Zoom-US Application";
        scaleFactor = lib.mkOption {
          type = lib.types.int;
          default = 1;
          description = "Adjustment to the X11 Zoom Scaling";
        };
      };

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home = {
          packages = with pkgs; [
            zoom-us
          ];

          file.".config/zoomus.conf".text = ''
            [General]
            ScaleFactor=${toString cfg.scaleFactor}
          '';
        };
      };
    };
}
