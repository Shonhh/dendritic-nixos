{ ... }:

{
  flake.nixosModules.qbittorrent =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.qbittorrent;
    in
    {
      options.mySystem.apps.qbittorrent.enable = lib.mkEnableOption "Enable Qbittorrent for Torrenting";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          qbittorrent
        ];
      };
    };
}
