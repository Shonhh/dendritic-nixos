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

        # Install both tools globally
        environment.systemPackages = with pkgs; [
          iio-hyprland
          rot8
        ];

        home-manager.users.shonh = {
          # Service 1: Only runs if Hyprland is active
          systemd.user.services.iio-hyprland = {
            Unit = {
              Description = "IIO Sensor Bridge for Hyprland";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
              # SYSTEMD MAGIC: Only start if this variable exists in the session
              ConditionEnvironment = "HYPRLAND_INSTANCE_SIGNATURE";
            };
            Service = {
              Type = "simple";
              ExecStart = "${pkgs.uwsm}/bin/uwsm app -- ${pkgs.iio-hyprland}/bin/iio-hyprland eDP-1";
              Restart = "always";
              RestartSec = 2;
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };

          # Service 2: Only runs if Niri is active
          systemd.user.services.rot8-niri = {
            Unit = {
              Description = "Automatic Screen Rotation for Niri";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
              ConditionEnvironment = "NIRI_SOCKET";
            };
            Service = {
              Type = "simple";
              ExecStart = "${pkgs.uwsm}/bin/uwsm app -- ${pkgs.rot8}/bin/rot8";
              Restart = "always";
              RestartSec = 2;
            };
            Install.WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };
}
