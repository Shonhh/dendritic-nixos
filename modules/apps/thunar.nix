{ ... }:

{
  flake.nixosModules.thunar =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.thunar;
    in
    {
      options.mySystem.apps.thunar.enable = lib.mkEnableOption "Thunar File Manager";

      config = lib.mkIf cfg.enable {

        programs.thunar = {
          enable = true;
          plugins = with pkgs; [
            thunar-archive-plugin
            thunar-volman
          ];
        };

        services.gvfs.enable = true; # Enables Trash, USB mounting, and network drives
        services.tumbler.enable = true; # Enables image and video thumbnails

        # Thunar's archive plugin needs an actual archiving tool to execute the commands
        environment.systemPackages = with pkgs; [
          file-roller
        ];

      };
    };
}
