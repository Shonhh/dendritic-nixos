{ inputs, config, ... }:
let
  mkHost = import ../../lib/mk-host.nix {
    inherit inputs;
    nixosModules = config.flake.nixosModules;
  };
in
{
  flake.nixosConfigurations."omenixos" = mkHost {
    hostName = "omenixos";
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
                  path: uuid(e6d3d16d-54ea-41e5-88fb-ef2040284a01):/EFI/Microsoft/Boot/bootmgfw.efi
                  comment: Boot into Windows 11
            '';
          };

          timeout = 1;
          efi.canTouchEfiVariables = true;
        };

        initrd.systemd.tpm2.enable = false;
        kernelParams = [
          # faster boots, mask this system
          "systemd.mask=dev-tpm0.device"
          "systemd.mask=dev-tpmrm0.device"

          "usbcore.autosuspend=-1"
          "processor.max_cstate=5"
        ];
      };

      systemd.tpm2.enable = false;

      # --- 2TB SHARED DRIVE MOUNT ---
      fileSystems."/mnt/shared" = {
        device = "/dev/disk/by-uuid/72925CFC925CC66F";
        fsType = "ntfs3";
        options = [
          "rw"
          "uid=1000"
          "gid=100"
          "dmask=0022"
          "fmask=0133"

          # Drive mounts when needed, not when booting
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=600"
        ];
      };

      # Enable various user-defined modules
      mySystem = {
        profiles = {
          workstation.enable = true;
          gaming.enable = true;
        };
        system.limine.enable = true;
        system.quiet-boot.enable = true;

        # Hardware-specific modules
        hardware.nvidia = {
          enable = true;
          package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
        };

        # Enable Apps
        apps = {
          codex.enable = true;
          obs-studio.enable = true;
          qbittorrent.enable = true;
        };

        games.lichii.enable = false;

        # Define Environment
        desktop = {
          displays = {
            hyprland = [
              "HDMI-A-1,1920x1080@60,0x0,1"
              "DP-1,1920x1080@200,1920x0,1"
              ",preferred,auto,1"
            ];

            hyprlandDefaultWorkspaces = {
              "HDMI-A-1" = 3; # Normal workspace 1
              "DP-1" = 4; # Normal workspace 2
            };
          };

          stylix.wallpaper = inputs.self + "/wallpapers/gruvified-wallpaper3.png";
        };
      };
    };
  };
}
