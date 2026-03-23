{ ... }:

{
  flake.nixosModules.obsidian =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.obsidian;
    in
    {
      options.mySystem.apps.obsidian.enable = lib.mkEnableOption "Obsidian Note-taking App";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          obsidian
        ];
      };
    };
}
