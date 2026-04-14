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
      cfg = config.mySystem.apps.anki;
    in
    {
      options.mySystem.apps.anki.enable = lib.mkEnableOption "Anki";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          anki
        ];
      };
    };
}
