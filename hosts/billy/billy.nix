{ inputs, config, ... }:

{
  flake.nixosConfigurations."billy" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };

    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
    ]
    ++ (builtins.attrValues config.flake.nixosModules)
    ++ [
      ./hardware-configuration.nix

      (
        { lib, config, ... }:
        {
          networking.hostName = "billy";
          system.stateVersion = "25.11";

          # disable stylix limine theming
          stylix.targets.limine.image.enable = lib.mkIf config.mySystem.desktop.stylix.enable false;

          boot = {
            loader = {
              limine = {
                enable = true;
                secureBoot.enable = false;

                style = lib.mkIf config.mySystem.desktop.stylix.enable {
                  wallpapers = lib.mkForce [ ];
                  backdrop = lib.mkForce config.lib.stylix.colors.base00;
                  graphicalTerminal.background = lib.mkForce "00${config.lib.stylix.colors.base00}";
                };

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

              # minimal startup
              "quiet"
              "splash"
              "boot.shell_on_fail"
              "loglevel=3"
              "udev.log_priority=3"
              "rd.udev.log_level=3"
              "rd.systemd.show_status=false"
              "vt.global_cursor_default=0"

              # stop usbs from dcing
              "usbcore.autosuspend=-1"
              "processor.max_cstate=5"
            ];

            # minimal startup
            consoleLogLevel = 0;
            initrd.verbose = false;
          };

          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnfreePredicate = pkg: true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

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
            # Turn on the core system
            system = {
              core.enable = true;
              flatpak.enable = true;
              development.enable = true;
              polkit.enable = true;
              nixgc.enable = true;
              rebuild-system.enable = true;
              docker = {
                storeExternal = true;
              };
            };

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

            hardware.bluetooth.enable = true;

            # Enable Apps
            apps = {
              foot.enable = true;
              yazi.enable = true;
              thunar.enable = true;
              neovim.enable = true;
              fastfetch.enable = true;
              git.enable = true;
              discord.enable = true;
              zed.enable = true;
              steam.enable = true;
              spotify.enable = true;
              btop.enable = true;
              # obsidian.enable = true;
              # zoom.enable = true;
              anki.enable = true;
              # thunderbird.enable = true;
              helium.enable = true;
              odysseus.enable = true;
              ryubing.enable = true;
            };

            games = {
              minecraft.enable = true;
            };

            # Define Environment
            desktop = {
              wm-ctrl.enable = true;
              hyprland.enable = true;
              noctalia.enable = true;
              stylix = {
                enable = true;
                wallpaper = inputs.self + "/wallpapers/gruvified-wallpaper3.png";
              };
              plymouth.enable = true;
            };
          };
        }
      )
    ];
  };
}
