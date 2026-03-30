{ ... }:

{
  flake.nixosModules.development =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.development;
    in
    {
      options.mySystem.system.development.enable = lib.mkEnableOption "Starship Configuration";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.programs.starship = {
          enable = true;
          enableZshIntegration = true;
        };
      };
    };
}
