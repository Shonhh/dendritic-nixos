{ ... }:

{
  flake.nixosModules.dolphin-emu =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.dolphin-emu;
    in
    {
      options.mySystem.apps.dolphin-emu.enable = lib.mkEnableOption "Dolphin Wii Emulator";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          dolphin-emu
        ];
      };
    };
}
