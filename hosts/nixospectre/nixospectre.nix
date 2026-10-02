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
    configuration = { config, lib, ... }: {
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
      };

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
          obsidian.enable = true;
          anki.enable = true;
          zoom = {
            enable = true;
            scaleFactor = 2;
          };
          libreoffice.enable = true;
          slack.enable = true;
        };

        # Define Environment
        desktop = {
          displays = {
            hyprland = [
              "eDP-1,preferred,auto,2"
              ",preferred,auto,1"
            ];
            niri."eDP-1".scale = 2.0;
            sway."eDP-1" = {
              resolution = "1920x1080";
              scale = "2";
            };
          };
          stylix = {
            wallpaper = inputs.self + "/wallpapers/gruvified-wallpaper5.png";
          };
        };
      };
    };
  };
}
