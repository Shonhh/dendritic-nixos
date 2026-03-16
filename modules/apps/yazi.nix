# modules/apps/yazi.nix
{ ... }:

{
  flake.nixosModules.yazi = { config, lib, pkgs, ... }: 
  let
    cfg = config.mySystem.apps.yazi;
  in {
    options.mySystem.apps.yazi.enable = lib.mkEnableOption "Yazi File Manager";

    config = lib.mkIf cfg.enable {
      
      home-manager.users.shonh = {
        home.packages = [ pkgs.ripdrag ];

        programs.yazi = {
          enable = true;
          enableBashIntegration = true;
	  # enableZshIntegration = true;
          
          keymap = {
            manager.prepend_keymap = [
              {
                on = [ "<C-d>" ];
                # Passes the selected file(s) to ripdrag in the background
                run = "shell 'ripdrag \"$@\" -x 2>/dev/null &' --confirm";
                desc = "Drag and drop selected files";
              }
            ];
          };
        };
      };
    };
  };
}
