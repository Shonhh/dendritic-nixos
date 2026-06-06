{ ... }:

{
  flake.nixosModules.regreet =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.regreet;
    in
    {
      options.mySystem.system.regreet.enable = lib.mkEnableOption "ReGreet Login Manager";

      config = lib.mkIf cfg.enable {
        security.pam.services.greetd.enableGnomeKeyring = true;
        programs.regreet = {
          enable = true;
          cageArgs = [
            "-s"
            "-m"
            "last"
          ];
        };

        systemd.services.greetd.serviceConfig = {
          StandardOutput = "journal";
          StandrdError = "journal";
        };
      };
    };
}
