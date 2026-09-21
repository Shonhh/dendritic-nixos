{ ... }:

{
  flake.nixosModules.anki =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.libreoffice;
    in
    {
      options.mySystem.apps.libreoffice.enable = lib.mkEnableOption "Linux Office Suite";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          libreoffice
        ];
      };
    };
}
