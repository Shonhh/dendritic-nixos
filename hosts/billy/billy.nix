{ inputs, config, ... }:
let
  mkHost = import ../../lib/mk-host.nix {
    inherit inputs;
    nixosModules = config.flake.nixosModules;
  };
in
{
  flake.nixosConfigurations."billy" = mkHost {
    hostName = "billy";
    hardware = ./hardware-configuration.nix;
    configuration = { config, lib, ... }: {
      system.stateVersion = "25.11";

      boot = {
        loader = {
          limine = {
            # chainload Windows
            extraEntries = ''
              /Windows 11
                  protocol: efi
                  path: uuid(ab3d6301-a2e4-4db3-9c91-eefc427f3f34):/EFI/Microsoft/Boot/bootmgfw.efi
                  comment: Boot into Windows 11
            '';
          };

          timeout = 1;
          efi.canTouchEfiVariables = true;
        };

        kernelParams = [
          # faster boots, mask this system
          "systemd.mask=dev-tpm0.device"
          "systemd.mask=dev-tpmrm0.device"

          # stop usbs from dcing
          "usbcore.autosuspend=-1"
          "processor.max_cstate=5"
        ];
      };

      # --- 1TB SHARED DRIVE MOUNT ---
      fileSystems."/mnt/shared" = {
        device = "/dev/disk/by-uuid/3D1BD58875712A30";
        fsType = "ntfs3";
        options = [
          "rw"
          "uid=1000"
          "gid=100"
          "dmask=0022"
          "fmask=0022"

          # Drive mounts when needed, not when booting
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=600"
        ];
      };

      # Enable various user-defined modules
      mySystem = {
        profiles.workstation.enable = true;
        system.limine.enable = true;
        system.quiet-boot.enable = true;

        # Hardware-specific modules
        hardware.nvidia = {
          enable = true;

          prime = {
            enable = true;
            alwaysOn = true;
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
          };
        };

        games = {
          ryubing.enable = true;
          dolphin-emu.enable = true;
        };

        # Define Environment
        desktop = {
          stylix = {
            wallpaper = inputs.self + "/wallpapers/gruvified-wallpaper3.png";
          };
        };
      };
    };
  };
}
