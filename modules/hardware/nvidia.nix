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
      options.mySystem.hardware.nvidia = {
        enable = lib.mkEnableOption "NVIDIA Drivers and Wayland Fixes";

        package = lib.mkOption {
          type = lib.types.package;
          default = config.boot.kernelPackages.nvidiaPackages.stable;
          description = "The specific NVIDIA driver package to use for this host.";
        };

        prime = {
          enable = lib.mkEnableOption "NVIDIA Optimus PRIME (Hybrid Graphics)";

          alwaysOn = lib.mkEnableOption "Force Sync Mode (Run everything on the dGPU)";

          intelBusId = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          amdgpuBusId = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          nvidiaBusId = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
        };
      };

      config = lib.mkIf cfg.enable {

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [ nvidia-vaapi-driver ];
        };

        services.xserver.videoDrivers = [ "nvidia" ];
        services.udev.packages = [ pkgs.game-devices-udev-rules ];

        hardware.nvidia = {
          modesetting.enable = true;

          # Only use finegrained power management if we are actually trying to save battery in offload mode
          powerManagement.enable = true;
          powerManagement.finegrained = cfg.prime.enable && !cfg.prime.alwaysOn;

          open = false;
          nvidiaSettings = true;
          package = cfg.package;

          # The Routing Logic
          prime = lib.mkIf cfg.prime.enable {
            # If alwaysOn is FALSE, we use Offload (Battery Saver)
            offload = lib.mkIf (!cfg.prime.alwaysOn) {
              enable = true;
              enableOffloadCmd = true;
            };

            # If alwaysOn is TRUE, we use Sync (Maximum Performance)
            sync.enable = cfg.prime.alwaysOn;

            intelBusId = lib.mkIf (cfg.prime.intelBusId != "") cfg.prime.intelBusId;
            amdgpuBusId = lib.mkIf (cfg.prime.amdgpuBusId != "") cfg.prime.amdgpuBusId;
            nvidiaBusId = cfg.prime.nvidiaBusId;
          };
        };

        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";
          LIBVA_DRIVER_NAME = "nvidia";
          XDG_SESSION_TYPE = "wayland";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          NVD_BACKEND = "direct";
        };

        # Only install the offload script if we are actually using offload mode
        environment.systemPackages = lib.mkIf (cfg.prime.enable && !cfg.prime.alwaysOn) [
          pkgs.nvtopPackages.nvidia
        ];
      };
    };
}
