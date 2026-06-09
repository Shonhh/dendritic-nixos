{ ... }:

{
  flake.nixosModules.obs-studio =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.obs-studio;
    in
    {
      options.mySystem.apps.obs-studio.enable = lib.mkEnableOption "OBS-Studio";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          obs-studio
        ];
      };
    };
}
