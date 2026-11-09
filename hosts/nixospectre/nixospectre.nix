{ inputs, config, ... }:
let
  mkHost = import ../../lib/mk-host.nix {
    inherit inputs;
    nixosModules = config.flake.nixosModules;
  };
in
{
  flake.nixosConfigurations."nixospectre" = mkHost {
    hostName = "nixospectre";
    hardware = ./hardware-configuration.nix;
    configuration =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        system.stateVersion = "25.11";

        boot = {
          loader = {
            limine = {
              # chainload Windows
              extraEntries = ''
                /Windows 11
                    protocol: efi
                    path: uuid(ba6caefb-d7fa-4822-be6a-4784db155c46):/EFI/Microsoft/Boot/bootmgfw.efi
                    comment: Boot into Windows 11
              '';
            };

            timeout = 5;
            efi.canTouchEfiVariables = false; # errors with laptop
          };

          # Camera
          kernelPatches = [
            {
              name = "hi556-longer-reset-delay";

              patch = pkgs.writeText "hi556-longer-reset-delay.patch" (
                "--- a/drivers/media/i2c/hi556.c\n"
                + "+++ b/drivers/media/i2c/hi556.c\n"
                + "@@ -1 +1 @@\n"
                + "-\tusleep_range(5000, 5500);\n"
                + "+\tmsleep(300);\n"
              );
            }
          ];
        };

        # Camera
        hardware.ipu6 = {
          enable = true;
          platform = "ipu6";
          videoDeviceNumber = 64;
        };

        services = {
          # More Camera
          v4l2-relayd.instances.ipu6 = {
            extraPackages = lib.mkForce [ pkgs.libcamera ];

            input = {
              pipeline = lib.mkForce (
                "libcamerasrc"
                + " ! capsfilter caps=video/x-raw,width=1920,height=1080"
                + " ! videoconvert ! videoscale"
                + " ! capsfilter caps=video/x-raw,format=YUY2,width=1280,height=720,framerate=30/1"
              );

              format = lib.mkForce "YUY2";
              width = 1280;
              height = 720;
              framerate = 30;
            };
          };
        };

        systemd.services.v4l2-relayd-ipu6.script = lib.mkForce ''
          exec ${pkgs.v4l2-relayd}/bin/v4l2-relayd \
            -i "${config.services.v4l2-relayd.instances.ipu6.input.pipeline}" \
            -o "appsrc name=appsrc caps=video/x-raw,format=YUY2,width=1280,height=720,framerate=30/1 ! videoconvert ! queue ! v4l2sink name=v4l2sink device=$(cat "$V4L2_DEVICE_FILE") sync=false"
        '';

        # Enable various user-defined modules
        mySystem = {
          profiles.workstation.enable = true;

          system.limine.enable = true;
          system.quiet-boot.enable = true;

          # Hardware-specific modules
          hardware = {
            intel.enable = true;
            screen-rotation.enable = true;
          };

          # Enable Apps
          apps = {
            foot = {
              sizeModifier = -2;
            };
            steam.enable = true;
            zoom = {
              scaleFactor = 2;
              cameraDevice = "/dev/video64";
            };
            slack.enable = true;
          };

          # Define Environment
          desktop = {
            niri.enable = true;

            displays = {
              hyprland = [
                "eDP-1,preferred,auto,2"
                ",preferred,auto,1"
              ];

              hyprlandDefaultWorkspaces = {
                "eDP-1" = 3; # Normal workspace 1
              };

              niri."eDP-1".scale = 2.0;

              sway."eDP-1" = {
                resolution = "1920x1080";
                scale = "2";
              };
            };

            stylix.wallpaper = inputs.self + "/wallpapers/gruvified-wallpaper5.png";
          };
        };
      };
  };
}
