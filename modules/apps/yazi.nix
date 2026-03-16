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
          
          settings = {
            opener = {
              edit = [
                { run = "nvim \"$@\""; block = true; desc = "Neovim"; }
              ];
            };
            open = {
              prepend_rules = [
                { mime = "text/*"; use = "edit"; }
              ];
            };
          };

          keymap = {
            mgr.prepend_keymap = [
              {
                on = [ "<C-n>" ]; 
                run = "shell 'ripdrag \"$@\" -x 2>/dev/null' --confirm --orphan";
                desc = "Drag and drop selected files";
              }
            ];
          };
        };
        
      };
    };
  };
}
