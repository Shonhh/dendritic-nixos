{ ... }:

{
  # Push the configuration into the Flake's module pool
  flake.nixosModules.bluetooth = { config, lib, pkgs, ... }: 
  let
    cfg = config.mySystem.system.power-management;
  in {
    # 1. Define the custom toggle
    options.mySystem.system.power-management.enable = lib.mkEnableOption "Power Management/Profiles";

    # 2. Apply the configuration
    config = lib.mkIf cfg.enable {
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
    };
  };
}
