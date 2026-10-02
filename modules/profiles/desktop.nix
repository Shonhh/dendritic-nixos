{ ... }:
{
  flake.nixosModules.profile-desktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.profiles.desktop = {
        enable = lib.mkEnableOption "Personal graphical desktop";
      };

      config = lib.mkIf config.mySystem.profiles.desktop.enable {
        mySystem = {
          profiles.base.enable = lib.mkDefault true;
          system = {
            desktop-services.enable = lib.mkDefault true;
            tuigreet.enable = lib.mkDefault true;
            power-management.enable = lib.mkDefault true;
          };
          hardware.bluetooth.enable = lib.mkDefault true;
          apps = {
            foot.enable = lib.mkDefault true;
            yazi.enable = lib.mkDefault true;
          };
          desktop = {
            hyprland.enable = lib.mkDefault true;
            noctalia.enable = lib.mkDefault true;
            stylix.enable = lib.mkDefault true;
          };
        };
        home-manager.users.shonh.home.packages = with pkgs; [
          sl
          cmatrix
          cbonsai
          vlc
          kdePackages.filelight
        ];
      };
    };
}
