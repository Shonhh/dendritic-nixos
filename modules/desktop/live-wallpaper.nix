{ ... }:

{
  flake.nixosModules.live-wallpaper =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.desktop.liveWallpaper;

      toggle = pkgs.writeShellApplication {
        name = "toggle-live-wallpaper";
        runtimeInputs = [ pkgs.systemd ];
        text = builtins.readFile ./scripts/toggle-live-wallpaper.sh;
      };
    in
    {
      options.mySystem.desktop.liveWallpaper = {
        enable = lib.mkEnableOption "toggleable animated wallpaper";

        fps = lib.mkOption {
          type = lib.types.ints.positive;
          default = 30;
          description = "Frame-rate limit for animated wallpaper.";
        };

        assetsPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Absolute path to Wallpaper Engine's assets directory.";
        };

        scenes = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Workshop ID or scene directory, keyed by monitor name.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.scenes != { };
            message = "Set at least one mySystem.desktop.liveWallpaper.scenes entry.";
          }
        ];

        home-manager.users.shonh = {
          home.packages = [ toggle ];

          services.linux-wallpaperengine = {
            enable = true;
            inherit (cfg) fps assetsPath;

            audio = {
              silent = true;
              processing = true;
            };

            wallpapers = lib.mapAttrsToList (monitor: wallpaper: {
              inherit monitor wallpaper;
              scaling = "fill";
            }) cfg.scenes;
          };

          # Keep Hyprpaper as the default at login.
          systemd.user.services.linux-wallpaperengine.Install.WantedBy = lib.mkForce [ ];
        };
      };
    };
}
