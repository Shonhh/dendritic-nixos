{ inputs, config, ... }:

{
  flake.nixosConfigurations."nixospectre" = inputs.nixpkgs.lib.nixosSystem {
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
          networking.hostName = "nixospectre";
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
                      path: uuid(ba6caefb-d7fa-4822-be6a-4784db155c46):/EFI/Microsoft/Boot/bootmgfw.efi
                      comment: Boot into Windows 11
                '';
              };

              timeout = 5;
              efi.canTouchEfiVariables = false; # errors with laptop
            };

            kernelParams = [
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

          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnfreePredicate = pkg: true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

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
            hardware.intel.enable = true;
            hardware.bluetooth.enable = true;

            # Enable Apps
            apps = {
              foot = {
                enable = true;
                sizeModifier = -2;
              };
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
              zoom = {
                enable = true;
                scaleFactor = 2;
              };
            };

            games = {
              minecraft.enable = true;
              mindustry.enable = true;
            };

            # Define Environment
            desktop = {
              hyprland.enable = true;
              noctalia.enable = true;
              stylix = {
                enable = true;
                wallpaper = inputs.self + "/wallpapers/gruvified-wallpaper2.png";
              };
              plymouth.enable = true;
            };
          };
        }
      )
    ];
  };
}
