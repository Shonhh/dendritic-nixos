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

        # Enable iio-sensor-proxy and install iio-hyprland
        programs.iio-hyprland.enable = true;

        # Start screen rotation with the graphical session
        systemd.user.services.iio-hyprland = {
          description = "Automatic Screen Rotation for Hyprland";

          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];

          # iio-hyprland invokes hyprctl and jq internally
          path = with pkgs; [
            hyprland
            jq
          ];

          serviceConfig = {
            Type = "exec";
            ExecStart = "${pkgs.iio-hyprland}/bin/iio-hyprland eDP-1";

            Restart = "on-failure";
            RestartSec = "2s";

            # Match how UWSM places background graphical services
            Slice = "background-graphical.slice";
          };
        };
      };
    };
}
