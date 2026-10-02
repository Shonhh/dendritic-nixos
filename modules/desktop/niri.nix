{ ... }:

{
  flake.nixosModules.niri =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.mySystem.desktop.niri;
      commands = config.mySystem.desktop.commands;
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

        # --- User Level Setup ---
        home-manager.users.shonh = {
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
              outputs = config.mySystem.desktop.displays.niri;

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

                  "Mod+Delete".action.quit = [ ];
                  "Mod+Q".action."close-window" = [ ];
                  "Mod+Shift+F".action."maximize-column" = [ ];

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
                }
                // lib.optionalAttrs config.mySystem.apps.foot.enable {
                  "Mod+T".action.spawn = uwsm commands.terminal;
                }
                // lib.optionalAttrs config.mySystem.apps.helium.enable {
                  "Mod+F".action.spawn = uwsm commands.browser;
                }
                // lib.optionalAttrs config.mySystem.apps.thunar.enable {
                  "Mod+E".action.spawn = uwsm commands.fileManager;
                }
                // lib.optionalAttrs config.mySystem.apps.zed.enable {
                  "Mod+C".action.spawn = uwsm commands.codeEditor;
                }
                // lib.optionalAttrs config.mySystem.apps.obsidian.enable {
                  "Mod+N".action.spawn = uwsm "obsidian";
                }
                // lib.optionalAttrs config.mySystem.apps.discord.enable {
                  "Mod+D".action.spawn = uwsm "discord";
                }
                // lib.optionalAttrs config.mySystem.apps.spotify.enable {
                  "Mod+S".action.spawn = uwsm "spotify";
                }
                // lib.optionalAttrs config.mySystem.apps.steam.enable {
                  "Mod+G".action.spawn = uwsm "steam";
                  "Mod+Shift+G".action.spawn = [ "steam-console" ];
                }
                // lib.optionalAttrs config.mySystem.desktop.noctalia.enable {
                  "Mod+P".action.spawn = [
                    "sh"
                    "-c"
                    commands.screenshot
                  ];
                  "Ctrl+Alt+W".action.spawn = [
                    "sh"
                    "-c"
                    commands.barToggle
                  ];
                  "Mod+A".action.spawn = [
                    "sh"
                    "-c"
                    commands.launcher
                  ];
                  "XF86MonBrightnessUp".action.spawn = [
                    "sh"
                    "-c"
                    commands.brightnessUp
                  ];
                  "XF86MonBrightnessDown".action.spawn = [
                    "sh"
                    "-c"
                    commands.brightnessDown
                  ];
                };
            };
          };
        };
      };
    };
}
