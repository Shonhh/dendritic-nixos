{ inputs, config, ... }:

{
  flake.nixosConfigurations."omenixos" = inputs.nixpkgs.lib.nixosSystem {
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
          networking.hostName = "omenixos";
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

              # minimal startup
              "quiet"
              "splash"
              "boot.shell_on_fail"
              "udev.log_priority=3"
              "rd.systemd.show_status=auto"
            ];

            # minimal startup
            consoleLogLevel = 3;
            initrd.verbose = false;
          };

          systemd.tpm2.enable = false;

          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnfreePredicate = pkg: true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

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
            };

            # Hardware-specific modules
            hardware.nvidia.enable = true;
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
              obsidian.enable = true;
              zoom.enable = true;
              anki.enable = true;
              thunderbird.enable = true;
            };

            games = {
              minecraft.enable = true;
              mindustry.enable = true;
            };

            # Define Environment
            desktop = {
              hyprland.enable = true;
              noctalia.enable = true;
              stylix.enable = true;
              plymouth.enable = true;
            };
          };
        }
      )
    ];
  };
}
