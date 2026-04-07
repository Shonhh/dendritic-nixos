{ ... }:

{
  flake.nixosModules.nvidia =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.hardware.nvidia;
    in
    {
      options.mySystem.hardware.nvidia.enable = lib.mkEnableOption "NVIDIA Drivers and Wayland Fixes";

      config = lib.mkIf cfg.enable {

        # 1. Enable OpenGL / Graphics Support
        hardware.graphics = {
          enable = true;
          enable32Bit = true; # Crucial for 32-bit games (like older Terraria versions/mods)

          extraPackages = with pkgs; [
            nvidia-vaapi-driver
          ];
        };

        # 2. Tell X11/Wayland to use the Nvidia driver
        services.xserver.videoDrivers = [ "nvidia" ];

        # 3. Configure the Nvidia package
        hardware.nvidia = {
          modesetting.enable = true;

          powerManagement.enable = true;
          powerManagement.finegrained = false;

          open = false;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
        };

        # 4. Inject Wayland variables into UWSM to force NVIDIA hardware acceleration
        home-manager.users.shonh = {
          home.sessionVariables = {
            LIBVA_DRIVER_NAME = "nvidia";
            XDG_SESSION_TYPE = "wayland";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            NVD_BACKEND = "direct"; # Fixes graphical glitches in Electron/Chromium apps
          };
        };

        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";
        };
      };
    };
}
