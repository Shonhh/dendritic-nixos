{ ... }:
{
  flake.nixosModules.profile-base =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.profiles.base = {
        enable = lib.mkEnableOption "Shared system and user defaults";
      };

      config = lib.mkIf config.mySystem.profiles.base.enable {
        mySystem.system = {
          core.enable = lib.mkDefault true;
          user.enable = lib.mkDefault true;
          kernel.enable = lib.mkDefault true;
        };
      };
    };
}
