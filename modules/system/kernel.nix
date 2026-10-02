{ ... }:
{
  flake.nixosModules.kernel =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.system.kernel = {
        enable = lib.mkEnableOption "Personal kernel defaults";
      };

      config = lib.mkIf config.mySystem.system.kernel.enable {
        boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
        boot.kernelModules = [ "ntsync" ];
      };
    };
}
