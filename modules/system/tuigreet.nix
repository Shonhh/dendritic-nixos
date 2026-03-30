{ ... }:

{
  flake.nixosModules.login-manager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.tuigreet;
    in
    {
      options.mySystem.system.tuigreet.enable = lib.mkEnableOption "TuiGreetd Login Manager";

      config = lib.mkIf cfg.enable {
        security.pam.services.greetd.enableGnomeKeyring = true;

        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet -t --user-menu -r --remember-session --asterisks --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
              user = "greeter";
            };
          };
        };
      };
    };
}
