{ ... }:
{
  flake.nixosModules.quiet-boot =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.system.quiet-boot = {
        enable = lib.mkEnableOption "Quiet graphical boot";
      };

      config = lib.mkIf config.mySystem.system.quiet-boot.enable {
        boot.kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "loglevel=3"
          "udev.log_priority=3"
          "rd.udev.log_level=3"
          "rd.systemd.show_status=false"
          "vt.global_cursor_default=0"
        ];
        boot.consoleLogLevel = 0;
        boot.initrd.verbose = false;
      };
    };
}
