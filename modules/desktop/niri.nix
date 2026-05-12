{ ... }:

{
  flake.nixosModules.niri =
    {
      config,
      lib,
      pkgs,
      inputs, # 1. Added inputs here to grab the flake
      ...
    }:
    let
      cfg = config.mySystem.desktop.niri;
    in
    {
      options.mySystem.desktop.niri.enable = lib.mkEnableOption "Niri Scrollable Wayland Compositor";

      config = lib.mkIf cfg.enable {
        # --- System Level Setup ---
        programs.niri = {
          enable = true;
          package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
        };
        programs.uwsm.enable = true;

        nix.settings = {
          extra-substituters = [ "https://niri.cachix.org" ];
          extra-trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
        };

        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.common.default = "*";
        };

        # --- User Level Setup ---
        home-manager.users.shonh = {
          # 3. IMPORT THE FLAKE'S HOME MANAGER MODULE HERE
          imports = [ inputs.niri.homeModules.niri ];

          programs.niri = {
            enable = true;

            settings = {
              # Strip ugly titlebars
              "prefer-no-csd" = true;

              # Inputs
              input = {
                keyboard.xkb.layout = "us";

                "focus-follows-mouse" = {
                  "max-scroll-amount" = "0%";
                };

                touchpad = {
                  tap = true;
                  "natural-scroll" = true;
                  "scroll-factor" = 0.15;
                };

                mouse = {
                  "accel-profile" = "flat";
                  "scroll-factor" = 0.5;
                };
              };

              # Monitors
              outputs = {
                "Virtual-1" = {
                  mode = {
                    width = 1280;
                    height = 720;
                  };
                  scale = 1.0;
                };
                "eDP-1" = {
                  scale = 2.0;
                };
              };

              # Layout
              layout = {
                gaps = 8;
                "center-focused-column" = "never";

                border = {
                  enable = true;
                  width = 2;
                  active.color = "#a6c8ff";
                  inactive.color = "#444444";
                };

                "focus-ring".enable = false;
              };

              # Window Rules
              "window-rules" = [
                {
                  "geometry-corner-radius" = {
                    "top-left" = 7.0;
                    "top-right" = 7.0;
                    "bottom-right" = 7.0;
                    "bottom-left" = 7.0;
                  };
                  "clip-to-geometry" = true;
                  "draw-border-with-background" = false;
                }

                {
                  matches = [
                    { "app-id" = "^(foot)$"; }
                    { "app-id" = "^(discord)$"; }
                    { "app-id" = "^([sS]potify)$"; }
                  ];
                  opacity = 0.80;
                }
                {
                  matches = [
                    { "app-id" = "^(dev\\.zed\\.Zed)$"; }
                    { "app-id" = "^(obsidian)$"; }
                  ];
                  opacity = 0.92;
                }
                {
                  matches = [ { "app-id" = "^([tT]hunar)$"; } ];
                  opacity = 0.75;
                }
              ];

              # Keybinds
              binds =
                with lib;
                let
                  uwsm = app: [
                    "uwsm-app"
                    "--"
                    app
                  ];

                  workspaces = attrsets.mergeAttrsList (
                    builtins.genList (
                      i:
                      let
                        ws = i + 1;
                      in
                      {
                        "Mod+${toString ws}".action."focus-workspace" = ws;
                        "Mod+Shift+${toString ws}".action."move-window-to-workspace" = ws;
                      }
                    ) 9
                  );
                in
                workspaces
                // {
                  "Mod+0".action."focus-workspace" = 10;
                  "Mod+Shift+0".action."move-window-to-workspace" = 10;

                  "Mod+T".action.spawn = uwsm "foot";
                  "Mod+F".action.spawn = uwsm "helium";
                  "Mod+E".action.spawn = uwsm "thunar";
                  "Mod+C".action.spawn = uwsm "zeditor";
                  "Mod+N".action.spawn = uwsm "obsidian";

                  "Mod+D".action.spawn = uwsm "discord";
                  "Mod+S".action.spawn = uwsm "spotify";
                  "Mod+G".action.spawn = uwsm "steam";
                  "Mod+Shift+G".action.spawn = [ "steam-console" ];

                  "Mod+Delete".action.quit = [ ];
                  "Mod+Q".action."close-window" = [ ];
                  "Mod+Shift+F".action."maximize-column" = [ ];
                  "Mod+P".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "plugin:screenshot"
                    "takeScreenshot"
                    "region"
                  ];

                  "Ctrl+Alt+W".action.spawn = [
                    "sh"
                    "-c"
                    "noctalia-shell kill || uwsm-app -- noctalia-shell"
                  ];
                  "Mod+A".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "launcher"
                    "toggle"
                  ];

                  "Mod+Left".action."focus-column-left" = [ ];
                  "Mod+Right".action."focus-column-right" = [ ];
                  "Mod+Up".action."focus-window-up" = [ ];
                  "Mod+Down".action."focus-window-down" = [ ];

                  "Mod+Shift+Left".action."move-column-left" = [ ];
                  "Mod+Shift+Right".action."move-column-right" = [ ];
                  "Mod+Shift+Up".action."move-window-up" = [ ];
                  "Mod+Shift+Down".action."move-window-down" = [ ];

                  "Mod+W".action."consume-or-expel-window-left" = [ ];
                  "Mod+J".action."consume-or-expel-window-right" = [ ];

                  "XF86AudioRaiseVolume".action.spawn = [
                    "wpctl"
                    "set-volume"
                    "@DEFAULT_AUDIO_SINK@"
                    "5%+"
                  ];
                  "XF86AudioLowerVolume".action.spawn = [
                    "wpctl"
                    "set-volume"
                    "@DEFAULT_AUDIO_SINK@"
                    "5%-"
                  ];
                  "XF86AudioMute".action.spawn = [
                    "wpctl"
                    "set-mute"
                    "@DEFAULT_AUDIO_SINK@"
                    "toggle"
                  ];
                  "XF86MonBrightnessUp".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "brightness"
                    "increase"
                  ];
                  "XF86MonBrightnessDown".action.spawn = [
                    "noctalia-shell"
                    "ipc"
                    "call"
                    "brightness"
                    "decrease"
                  ];
                };
            };
          };
        };
      };
    };
}
