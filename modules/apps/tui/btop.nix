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
      options.mySystem.apps.btop.enable = lib.mkEnableOption "Neovim Editor";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.btop ];
        home-manager.users.shonh.programs.btop.enable = true;
      };
    };
}
