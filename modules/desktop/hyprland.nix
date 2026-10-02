{ ... }:

{
  flake.nixosModules.hyprland =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.desktop.hyprland;
      commands = config.mySystem.desktop.commands;

      focusMode = pkgs.writeShellApplication {
        name = "hypr-focus-mode";
        runtimeInputs = [
          config.programs.hyprland.package
          config.home-manager.users.shonh.programs.noctalia.package
          pkgs.coreutils
          pkgs.gawk
          pkgs.power-profiles-daemon
        ];
        text = builtins.readFile ./scripts/hypr-focus-mode.sh;
      };

      gameMode = pkgs.writeShellApplication {
        name = "hypr-game-mode";
        runtimeInputs = [
          config.programs.hyprland.package
          config.home-manager.users.shonh.programs.noctalia.package
          pkgs.coreutils
          pkgs.gawk
          pkgs.power-profiles-daemon
        ];
        text = builtins.readFile ./scripts/hypr-game-mode.sh;
      };
    in
    {
      options.mySystem.desktop.hyprland = {
        enable = lib.mkEnableOption "Hyprland Wayland Compositor";
      };

      config = lib.mkIf cfg.enable {
        mySystem.system.power-management.enable = lib.mkIf config.mySystem.desktop.noctalia.enable true;
        # Skip local compilation
        nix.settings = {
          substituters = [ "https://hyprland.cachix.org" ];
          trusted-substituters = [ "https://hyprland.cachix.org" ];
          trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
        };

        # --- System Level Setup ---
        programs.hyprland = {
          enable = true;
          withUWSM = true;
        };

        # --- User Level Setup
        home-manager.users.shonh = {
          wayland.windowManager.hyprland = {
            enable = true;
            systemd.enable = false;
            configType = "hyprlang";

            settings = lib.mkMerge [
              (import ../../config/hyprland/settings.nix {
                inherit config lib commands;
              })
              (import ../../config/hyprland/bindings.nix {
                inherit
                  config
                  lib
                  commands
                  focusMode
                  gameMode
                  ;
              })
            ];
          };
        };
      };
    };
}
