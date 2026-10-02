{ ... }:
{
  flake.nixosModules.profile-gaming =
    { config, lib, ... }:
    {
      options.mySystem.profiles.gaming.enable = lib.mkEnableOption "Shared gaming defaults";

      config = lib.mkIf config.mySystem.profiles.gaming.enable {
        mySystem = {
          # Game Launcher
          apps.steam.enable = lib.mkDefault true;
          games = {
            # Game Binaries
            minecraft.enable = lib.mkDefault true;

            # Emulators
            dolphin-emu.enable = lib.mkDefault true;
            ryubing.enable = lib.mkDefault true;

            # Mods
            r2modman.enable = lib.mkDefault true;
          };
        };
      };
    };
}
