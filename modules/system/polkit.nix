{ ... }:

{
  flake.nixosModules.polkit =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.polkit;
    in
    {
      options.mySystem.system.polkit.enable = lib.mkEnableOption "Enabling Polkit";

      config = lib.mkIf cfg.enable {
        security.polkit.enable = true;

        home-manager.users.shonh = {
          home.packages = with pkgs; [
            hyprpolkitagent
          ];

          systemd.user.services.hyprpolkitagent = {
            Unit = {
              Description = "Hyprland Polkit Authentication Agent";
              ConditionEnvironment = "WAYLAND_DISPLAY";
              After = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
              Restart = "on-failure";
              RestartSec = 1;
              TimeoutStopSec = 10;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };
        };
      };
    };
}
