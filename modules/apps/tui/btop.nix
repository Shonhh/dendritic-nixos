{ ... }:

{
  flake.nixosModules.btop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.btop;
    in
    {
      options.mySystem.apps.btop.enable = lib.mkEnableOption "System resource monitor";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.programs.btop.enable = true;
      };
    };
}
