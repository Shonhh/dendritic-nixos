{ ... }:

{
  flake.nixosModules.tuigreet =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.tuigreet;

      waylandSessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";

      tuigreetArgs = [
        # Display the current date and time.
        "--time"

        # Select users through a menu instead of typing the username.
        "--user-menu"

        # Remember the last successfully authenticated username.
        "--remember"

        # Remember the last successfully launched session, allowing the
        # default selection to alternate between Hyprland, Steam, and any
        # other registered session.
        "--remember-session"

        # Display password-entry feedback.
        "--asterisks"

        # Read every Wayland session registered with the NixOS display
        # manager integration.
        "--sessions"
        waylandSessions
      ];
    in
    {
      options.mySystem.system.tuigreet.enable = lib.mkEnableOption "tuigreet Login Manager";

      config = lib.mkIf cfg.enable {
        # Unlock the user's GNOME keyring with the login password.
        security.pam.services.greetd.enableGnomeKeyring = true;

        services.greetd = {
          enable = true;

          # Connect greetd directly to tty1 and prevent service output from
          # interfering with tuigreet's terminal interface.
          useTextGreeter = true;

          settings.default_session = {
            command = lib.escapeShellArgs (
              [
                "${pkgs.tuigreet}/bin/tuigreet"
              ]
              ++ tuigreetArgs
            );

            user = "greeter";
          };
        };
      };
    };
}
