{ ... }:
{
  flake.nixosModules.screen-rotation =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.hardware.screen-rotation;
    in
    {
      options.mySystem.hardware.screen-rotation.enable =
        lib.mkEnableOption "Automatic Screen Rotation Support";

      config = lib.mkIf cfg.enable {
        hardware.sensor.iio.enable = true;
        environment.systemPackages = [ pkgs.iio-hyprland ];

        systemd.user.services.iio-hyprland = {
          description = "IIO Sensor Bridge for Hyprland Auto-Rotation";

          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];

          path = with pkgs; [
            jq
            hyprland
          ];

          # The Service block becomes serviceConfig
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.uwsm}/bin/uwsm app -- ${pkgs.iio-hyprland}/bin/iio-hyprland eDP-1";
            Restart = "always";
            RestartSec = 2;
          };
        };
      };
    };
}
