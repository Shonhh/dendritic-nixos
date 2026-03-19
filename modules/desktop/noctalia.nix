# modules/desktop/noctalia.nix
{ ... }:

{
  flake.nixosModules.noctalia = { config, lib, pkgs, inputs, ... }: 
  let
    cfg = config.mySystem.desktop.noctalia;
  in {
    options.mySystem.desktop.noctalia.enable = lib.mkEnableOption "Noctalia Shell";

    config = lib.mkIf cfg.enable {
      
      # Noctalia needs these background services to read battery and hardware data
      mySystem.system.power-management.enable = true;
      mySystem.hardware.bluetooth.enable = true;

      home-manager.users.shonh = {
        imports = [ inputs.noctalia.homeModules.default ];
        
        programs.noctalia-shell = {
          enable = true;

	  settings = {
	    bar = {
	      widgets = {
		center = [
		  {
		    id = "Workspace";
		  }
		];
	      };
	    };
	  };
        };
      };
    };
  };
}
