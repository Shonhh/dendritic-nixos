{ ... }:
{
  flake.nixosModules.profile-workstation =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.profiles.workstation = {
        enable = lib.mkEnableOption "Personal workstation defaults";
      };

      config = lib.mkIf config.mySystem.profiles.workstation.enable {
        mySystem = {
          profiles.desktop.enable = lib.mkDefault true;
          system = {
            flatpak.enable = lib.mkDefault true;
            development.enable = lib.mkDefault true;
            polkit.enable = lib.mkDefault true;
            nixgc.enable = lib.mkDefault true;
            rebuild-system.enable = lib.mkDefault true;
          };
          apps = {
            thunar.enable = lib.mkDefault true;
            neovim.enable = lib.mkDefault true;
            fastfetch.enable = lib.mkDefault true;
            git.enable = lib.mkDefault true;
            discord.enable = lib.mkDefault true;
            zed.enable = lib.mkDefault true;
            steam.enable = lib.mkDefault true;
            spotify.enable = lib.mkDefault true;
            btop.enable = lib.mkDefault true;
            thunderbird.enable = lib.mkDefault true;
            helium.enable = lib.mkDefault true;
          };
          games.minecraft.enable = lib.mkDefault true;
          desktop = {
            wm-ctrl.enable = lib.mkDefault true;
            plymouth.enable = lib.mkDefault true;
          };
        };
      };
    };
}
