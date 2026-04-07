# hosts/nixovm/nixovm.nix
{ inputs, config, ... }:

{
  flake.nixosConfigurations."nixovm" = inputs.nixpkgs.lib.nixosSystem {
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
        { ... }:
        {
          networking.hostName = "nixovm";
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

          # Enable various user-defined modules
          mySystem = {
            # Turn on the core system
            system.core.enable = true;

            # Enable Apps
            apps.foot.enable = true;
            apps.yazi.enable = true;

            # Define Environment
            desktop.hyprland.enable = true;
            desktop.noctalia.enable = true;
            desktop.stylix.enable = true;
          };
        }
      )
    ];
  };
}
