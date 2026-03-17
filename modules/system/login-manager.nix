{ ... }:

{
  flake.nixosModules.login-manager = { config, lib, pkgs, ... }:
  let
    cfg = config.mySystem.system.login-manager;
  in {
    options.mySystem.system.login-manager.enable = lib.mkEnableOption "TuiGreetd Login Manager";

    config = lib.mkIf cfg.enable {
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
