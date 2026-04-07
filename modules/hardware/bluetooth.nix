{ ... }:
{
  flake.nixosModules.bluetooth =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.hardware.bluetooth;
    in
    {
      options.mySystem.hardware.bluetooth.enable = lib.mkEnableOption "Bluetooth Support";

      config = lib.mkIf cfg.enable {
        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;

        environment.systemPackages = [
          pkgs.bluetui
        ];
      };
    };
}
