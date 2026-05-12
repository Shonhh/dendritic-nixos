{ ... }:

{
  flake.nixosModules.swayfx =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.desktop.swayfx;
      modifier = "Mod4"; # SUPER key
    in
    {
      options.mySystem.desktop.swayfx.enable = lib.mkEnableOption "SwayFX Wayland Compositor";

      config = lib.mkIf cfg.enable {
        # --- System Level Setup ---
        # Note: We enable Sway at the system level, but override the package with SwayFX
        programs.sway = {
          enable = true;
          package = pkgs.swayfx;
        };
        programs.uwsm.enable = true;

        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.common.default = "*";
        };

        # Make sure the autotiling daemon is available
        environment.systemPackages = [ pkgs.autotiling ];

        # --- User Level Setup ---
        home-manager.users.shonh = {
          wayland.windowManager.sway = {
            enable = true;
            package = pkgs.swayfx;

            # CRITICAL: Home Manager validates the config against standard Sway.
            # We must disable this check so the validator doesn't crash when it sees SwayFX-specific commands like 'blur'
            checkConfig = false;

            config = {
              inherit modifier;

              terminal = "foot";

              # Replaces general.gaps_in and general.gaps_out
              gaps = {
                inner = 3;
                outer = 8;
              };

              # Monitors (Outputs)
              output = {
                "Virtual-1" = {
                  resolution = "1280x720";
                  scale = "1";
                };
                "eDP-1" = {
                  resolution = "1920x1080";
                  scale = "2";
                }; # Specify your actual resolution here
                "*" = {
                  resolution = "1920x1080";
                }; # Default fallback
              };

              # Input configuration
              input = {
                "*" = {
                  xkb_layout = "us";
                  pointer_accel = "0.3";
                  accel_profile = "flat";
                  natural_scroll = "enabled";
                  scroll_factor = "0.5";
                };
                "type:touchpad" = {
                  dwt = "enabled"; # Disable while typing
                  natural_scroll = "enabled";
                  scroll_factor = "0.15";
                };
              };

              # Window Rules (Replaces windowrule)
              window = {
                titlebar = false; # Removes standard window titlebars
                border = 2;
                commands = [
                  {
                    command = "opacity 0.80";
                    criteria = {
                      app_id = "foot";
                    };
                  }
                  {
                    command = "opacity 0.80";
                    criteria = {
                      class = "discord";
                    };
                  }
                  {
                    command = "opacity 0.80";
                    criteria = {
                      class = "Spotify";
                    };
                  }
                  {
                    command = "opacity 0.75";
                    criteria = {
                      app_id = "thunar";
                    };
                  }
                  {
                    command = "opacity 0.92";
                    criteria = {
                      class = "dev.zed.Zed";
                    };
                  }
                  {
                    command = "opacity 0.92";
                    criteria = {
                      class = "obsidian";
                    };
                  }
                ];
              };

              # Replaces bindm (Mouse Drags)
              floating = {
                modifier = "${modifier}";
              };

              # Startup Applications
              startup = [
                # Automatically handles dwindle-style tiling
                {
                  command = "autotiling";
                  always = true;
                }
              ];

              # Keybindings
              # We use mkOptionDefault to keep standard Sway binds (like reloading) while adding yours
              keybindings = lib.mkOptionDefault (
                let
                  uwsm = app: "exec uwsm-app -- ${app}";
                in
                {
                  # Core Apps
                  "${modifier}+t" = uwsm "foot";
                  "${modifier}+f" = uwsm "helium";
                  "${modifier}+e" = uwsm "thunar";
                  "${modifier}+c" = uwsm "zeditor";
                  "${modifier}+n" = uwsm "obsidian";

                  # Specific Workspaces
                  "${modifier}+d" = "workspace discord";
                  "${modifier}+s" = "workspace spotify";
                  "${modifier}+g" = "exec swaymsg workspace 10 && uwsm-app -- steam";
                  "${modifier}+Shift+g" = "exec steam-console"; # Assuming this handles Sway logic internally now

                  # Desktop State
                  "${modifier}+Delete" = "exec swaynag -t warning -m 'Exit Sway?' -B 'Yes' 'swaymsg exit'";
                  "Control+Mod1+w" = "exec sh -c 'noctalia-shell kill || uwsm-app -- noctalia-shell'";
                  "${modifier}+a" = "exec noctalia-shell ipc call launcher toggle";
                  "${modifier}+q" = "kill";
                  "${modifier}+w" = "floating toggle";
                  "${modifier}+Shift+f" = "fullscreen toggle";
                  "${modifier}+p" = "exec noctalia-shell ipc call plugin:screenshot takeScreenshot region";
                  "${modifier}+j" = "layout toggle split";

                  # Movement
                  "${modifier}+Left" = "focus left";
                  "${modifier}+Right" = "focus right";
                  "${modifier}+Up" = "focus up";
                  "${modifier}+Down" = "focus down";

                  "${modifier}+Shift+Left" = "move left";
                  "${modifier}+Shift+Right" = "move right";
                  "${modifier}+Shift+Up" = "move up";
                  "${modifier}+Shift+Down" = "move down";

                  # Workspace 10 & Special
                  "${modifier}+0" = "workspace number 10";
                  "${modifier}+Shift+0" = "move container to workspace number 10";
                  "${modifier}+Return" = "scratchpad show"; # Closest equivalent to togglespecialworkspace
                  "${modifier}+Shift+Return" = "move scratchpad";

                  # Multimedia (using --locked to allow usage while screen is locked)
                  "XF86AudioRaiseVolume" = "exec --locked wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
                  "XF86AudioLowerVolume" = "exec --locked wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
                  "XF86AudioMute" = "exec --locked wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                  "XF86AudioMicMute" = "exec --locked wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                  "XF86MonBrightnessUp" = "exec --locked noctalia-shell ipc call brightness increase";
                  "XF86MonBrightnessDown" = "exec --locked noctalia-shell ipc call brightness decrease";

                  "XF86AudioNext" = "exec --locked playerctl next";
                  "XF86AudioPause" = "exec --locked playerctl play-pause";
                  "XF86AudioPlay" = "exec --locked playerctl play-pause";
                  "XF86AudioPrev" = "exec --locked playerctl previous";
                }
              );
            };

            # --- SwayFX Specific Aesthetics ---
            # Home Manager's standard Sway module doesn't natively support SwayFX aesthetic keys yet,
            # so we append them directly to the end of the config file using extraConfig.
            extraConfig = ''
              # Corners
              corner_radius 7

              # Background Blur
              blur enable
              blur_passes 3
              blur_radius 5

              # Window Shadows (Optional, but replicates Hyprland's drop shadows)
              shadows enable
              shadow_blur_radius 10
              shadow_color #0000007F

              # Disable direct scanout if you experience tearing, otherwise keep enabled for gaming
              # direct_scanout disable
            '';
          };
        };
      };
    };
}
