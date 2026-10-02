{ ... }:
{
  flake.nixosModules.user =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.system.user = {
        enable = lib.mkEnableOption "Personal account and Home Manager";
      };

      config = lib.mkIf config.mySystem.system.user.enable {
        users.users.shonh = {
          isNormalUser = true;
          description = "Shonh";
          extraGroups = [
            "networkmanager"
            "wheel"
            "i2c"
          ];
        };
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          users.shonh.home.stateVersion = "25.11";
        };
      };
    };
}
