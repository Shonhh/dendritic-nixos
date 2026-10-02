{ inputs, config, ... }:
let
  mkHost = import ../../lib/mk-host.nix {
    inherit inputs;
    nixosModules = config.flake.nixosModules;
  };
in
{
  flake.nixosConfigurations."nixovm" = mkHost {
    hostName = "nixovm";
    hardware = ./hardware-configuration.nix;
    configuration = { config, lib, ... }: {
      system.stateVersion = "25.11";

      swapDevices = [
        {
          device = "/var/lib/swapfile";
          size = 4096; # 4 GB
        }
      ];

      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/vda";
      boot.loader.grub.useOSProber = true;

      mySystem.profiles.desktop.enable = true;

      mySystem.desktop.displays = {
        hyprland = [
          "Virtual-1,1280x720,auto,1"
          ",preferred,auto,1"
        ];
        niri."Virtual-1" = {
          mode = {
            width = 1280;
            height = 720;
          };
          scale = 1.0;
        };
        sway."Virtual-1" = {
          resolution = "1280x720";
          scale = "1";
        };
      };
    };
  };
}
