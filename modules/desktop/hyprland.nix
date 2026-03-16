{ ... }:

{
  flake.nixosModules.hyprland = { config, lib, pkgs, ... }:
  let
    cfg = config.mySystem.desktop.hyprland;
  in {
    options.mySystem.desktop.hyprland.enable = lib.mkEnableOption "Hyprland Wayland Compositor";

    config = lib.mkIf cfg.enable {
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

	  settings = {
	    "$terminal" = "foot";
	    "$browser" = "vivaldi";
	    "$file-manager" = "foot yazi";
	    "$mod" = "SUPER";

	    "exec-once" = [
	      "uwsm app -- noctalia-shell"
	    ];

	    monitor = [ 
	      "Virtual-1,1280x720,auto,1"
	      ",highres@highrr,auto,1" # Default
	    ];

	    bind = [
	      # Applications
	      "$mod, T, exec, uwsm app -- $terminal"
	      "$mod, F, exec, uwsm app -- $browser"
	      "$mod, E, exec, uwsm app -- $file-manager"

	      # Desktop Keybinds
	      "$mod, Delete, exit,"
	      "$mod+Alt, G, exec, ~/nixos/scripts/gamemode.sh"
	      "CTRL+ALT, W, exec, noctalia-shell kill || uwsm app -- noctalia-shell"
	      "$mod, A, exec, noctalia-shell ipc call launcher toggle"
	      "$mod, Q, killactive,"
	      "$mod, W, togglefloating,"
              "$mod+SHIFT, F, fullscreen"
              "$mod, J, togglesplit," # dwindle

	      # Move focus with mod + arrow keys
	      "$mod, left, movefocus, l"
              "$mod, right, movefocus, r"
              "$mod, up, movefocus, u"
	      "$mod, down, movefocus, d"

	      # Handling Workspaces
	      "$mod, 0, workspace, 10"
	      "$mod SHIFT, 0, movetoworkspace, 10"
              "$mod, code:36, togglespecialworkspace, terminal"

              # Scroll through existing workspaces with $mod + scroll
              "$mod, mouse_down, workspace, e+1"
              "$mod, mouse_up, workspace, e-1"
	    ]
	    ++ (
              # Binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
              builtins.concatLists (
                builtins.genList (
                  i:
                  let
                    ws = i + 1;
                  in
                  [
                    "$mod, code:1${toString i}, workspace, ${toString ws}"
                    "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                  ]
                ) 9
              )
            );

            bindm = [
              "$mod, Z, movewindow"
              "$mod, X, resizewindow"
      
              "$mod, mouse:272, movewindow"
              "$mod, mouse:273, resizewindow"
            ];

            # Laptop multimedia keys for volume and LCD brightness
            bindel = [
              ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
              ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
              ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
              ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
              ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
            ];

            bindl = [
              ", XF86AudioNext, exec, playerctl next"
              ", XF86AudioPause, exec, playerctl play-pause"
              ", XF86AudioPlay, exec, playerctl play-pause"
              ", XF86AudioPrev, exec, playerctl previous"
            ];

	    # General
      	    general = {
              gaps_in = 3;
              gaps_out = 8;

              border_size = 2;

              resize_on_border = true;

              allow_tearing = false;
              layout = "dwindle";
            };

      	    # Decoration
      	    decoration = {
              rounding = 7;
              active_opacity = 1.0;
              inactive_opacity = 1.0;

              blur = {
          	enabled = true;
          	size = 5;
          	passes = 3;
          	new_optimizations = "on";
          	ignore_opacity = "on";
          	xray = false;
              };
            };

	    windowrule = [
              # Opacity Rules
              "match:class ^($terminal)$, opacity 0.80 0.80"
	    ];

            workspace = [
              "10, border:false, rounding:false"
              "special:terminal, on-created-empty:[float; size 960 540] $terminal, persistent:false"
      	    ];

            gesture = [
              "3, horizontal, workspace"
            ];

      	    # Layout configuration
            dwindle = {
              pseudotile = true;
              preserve_split = true;
            };

            master = {
              new_status = "master";
            };

            # Miscellaneous
            misc = {
              force_default_wallpaper = 0;
              disable_hyprland_logo = true;
            };

            # Input
            input = {
              kb_layout = "us";
      
              follow_mouse = 1;
              sensitivity = 0.30;
              scroll_factor = 0.5;
              accel_profile = "flat";
              emulate_discrete_scroll = 0;
      
              touchpad = {
                disable_while_typing = false;
                natural_scroll = true;
                scroll_factor = 0.15;
              };
            };

            cursor = {
              no_hardware_cursors = 1;
            };

            device = [
              {
                # ... add later
              }
            ];

      	    # Animations
      	    animations = {
              enabled = true;

              bezier = [
          	"wind, 0.05, 0.85, 0.03, 0.97"
          	"winIn, 0.07, 0.88, 0.04, 0.99"
          	"winOut, 0.20, -0.15, 0, 1"
          	"liner, 1, 1, 1, 1"
          	"md3_standard, 0.12, 0, 0, 1"
          	"md3_decel, 0.05, 0.80, 0.10, 0.97"
          	"md3_accel, 0.20, 0, 0.80, 0.08"
          	"overshot, 0.05, 0.85, 0.07, 1.04"
          	"crazyshot, 0.1, 1.22, 0.68, 0.98"
          	"hyprnostretch, 0.05, 0.82, 0, 1"
          	"menu_decel, 0.05, 0.82, 0, 1"
          	"menu_accel, 0.20, 0, 0.82, 0.10"
          	"easeInOutCirc, 0.78, 0, 0.15, 1"
          	"easeOutCirc, 0, 0.48, 0.38, 1"
          	"easeOutExpo, 0.10, 0.94, 0.23, 0.98"
          	"softAcDecel, 0.20, 0.20, 0.15, 1"
          	"md2, 0.30, 0, 0.15, 1"

          	"OutBack, 0.28, 1.40, 0.58, 1"
              ];

              animation = [
          	"border, 1, 1.6, liner"
          	"borderangle, 1, 82, liner, once"
          	"windowsIn, 1, 3.2, winIn, slide"
          	"windowsOut, 1, 2.8, easeOutCirc"
          	"windowsMove, 1, 3.0, wind, slide"
          	"fade, 1, 1.8, md3_decel"
          	"layersIn, 1, 1.8, menu_decel, slide"
          	"layersOut, 1, 1.5, menu_accel"
          	"fadeLayersIn, 1, 1.6, menu_decel"
          	"fadeLayersOut, 1, 1.8, menu_accel"
          	"workspaces, 1, 4.0, menu_decel, slide"
          	"specialWorkspace, 1, 2.3, md3_decel, slidefadevert 15%"
              ];
            };	
	  };
	};
      };
    };
  };
}
