{ ... }:

{
  flake.nixosModules.development = { config, lib, pkgs, ... }:
  let
    cfg = config.mySystem.system.development;
  in {
    options.mySystem.system.development.enable = lib.mkEnableOption "Development Tools & Direnv";

    config = lib.mkIf cfg.enable {

      # Core development packages globally available
      environment.systemPackages = with pkgs; [
        git
        gnumake
        gcc
      ];

      home-manager.users.shonh = {
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        # Shell Coniguration
        programs.bash.enable = true;

        programs.zsh = {
          enable = false;
        };
      };
    };
  };
}
