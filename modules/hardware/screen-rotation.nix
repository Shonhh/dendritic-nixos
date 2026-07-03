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

        environment.systemPackages = with pkgs; [
          iio-hyprland
        ];

        # Native NixOS User Service (Bypasses Home Manager entirely)
        systemd.user.services.iio-hyprland = {
          description = "IIO Sensor Bridge for Hyprland";
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];

          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.uwsm}/bin/uwsm app -- ${pkgs.iio-hyprland}/bin/iio-hyprland eDP-1";
            Restart = "always";
            RestartSec = "2";
          };
        };
      };
    };
}
