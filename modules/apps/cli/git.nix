{ ... }:

{
  flake.nixosModules.git =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.git;
    in
    {
      options.mySystem.apps.git.enable = lib.mkEnableOption "Git";

      config = lib.mkIf cfg.enable {
        programs.git.enable = true;

        home-manager.users.shonh.programs.git = {
          enable = true;

          settings.user = {
            name = "Shonhh";
            email = "endinja.versitile@gmail.com";
          };
        };
      };
    };
}
