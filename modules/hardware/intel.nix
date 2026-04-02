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
      cfg = config.mySystem.hardware.intel;
    in
    {
      options.mySystem.hardware.intel.enable = lib.mkEnableOption "Intel Drivers and Wayland Fixes";

      config = lib.mkIf cfg.enable {

        # Enable OpenGL / Graphics Support
        hardware.graphics = {
          enable = true;
          enable32Bit = true; # Crucial for 32-bit games (like older Terraria versions/mods)

          extraPackages = with pkgs; [
            intel-media-driver
            vpl-gpu-rt
          ];
        };

        # Tell X11/Wayland to use the modesetting driver
        services.xserver.videoDrivers = [ "modesetting" ];

        # Inject Wayland variables into UWSM to force NVIDIA hardware acceleration
        home-manager.users.shonh = {
          home.sessionVariables = {
            LIBVA_DRIVER_NAME = "iHD";
            XDG_SESSION_TYPE = "wayland";
            NIXOS_OZONE_WL = "1";
          };
        };
      };
    };
}
