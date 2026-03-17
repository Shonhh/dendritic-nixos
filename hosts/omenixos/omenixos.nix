{ inputs, config, ... }:

{
  flake.nixosConfigurations."omenixos" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    
    modules = 
      [ 
        inputs.home-manager.nixosModules.home-manager
	inputs.stylix.nixosModules.stylix
      ] ++
      (builtins.attrValues config.flake.nixosModules) ++ 
      [
        ./hardware-configuration.nix
        
        ({ ... }: {
          networking.hostName = "omenixos";
          system.stateVersion = "25.11";
          
          boot = {
	    loader = {
              grub = {
                enable = true;
                efiSupport = true;
                device = "nodev";
                useOSProber = true;
              };
          
              efi.canTouchEfiVariables = true;
            };

	    initrd.systemd.tpm2.enable = false;
	    kernelParams = [
              "systemd.mask=dev-tpm0.device"
              "systemd.mask=dev-tpmrm0.device"
	    ];
	  };

	  systemd.tpm2.enable = false;


          # --- 2TB SHARED DRIVE MOUNT ---
          fileSystems."/mnt/shared" = {
            device = "/dev/disk/by-uuid/72925CFC925CC66F";
            fsType = "ntfs3";
            options = [ "rw" "uid=1000" "gid=100" "dmask=0022" "fmask=0133" ];
          };

	  # Enable various user-defined modules
	  mySystem = {
            # Turn on the core system
            system.core.enable = true;

	    # Hardware-specific modules
	    hardware.nvidia.enable = true;

	    # Enable Apps
            apps = {
	      foot.enable = true; 
	      yazi.enable = true;
	      neovim.enable = true;
	      fastfetch.enable = true;
	      git.enable = true;
	    };

	    # Define Environment
	    desktop = {
	      hyprland.enable = true;
	      noctalia.enable = true;
	      stylix.enable = true;
	    };
	  };
        })
      ];
  };
}
