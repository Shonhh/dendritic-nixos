{
  config,
  lib,
  commands,
}:
{
  "$terminal" = commands.terminal;
  "$browser" = commands.browser;
  "$file-manager" = commands.fileManager;
  "$code_editor" = commands.codeEditor;
  "$mod" = "SUPER";

  monitor = config.mySystem.desktop.displays.hyprland;

  render = {
    direct_scanout = 0;
  };

  # General
  general = {
    gaps_in = 3;
    gaps_out = 8;

    border_size = 2;

    resize_on_border = true;

    allow_tearing = false;
  };

  # Decoration
  decoration = {
    rounding = 7;
    active_opacity = 1.0;
    inactive_opacity = 1.0;

    blur = {
      enabled = true;
      size = 9;
      passes = 4;
      new_optimizations = "on";
      ignore_opacity = "on";
      xray = false;

      popups = true;
      popups_ignorealpha = 0.2;
    };
  };

  windowrule = [
    # Opacity Rules
    "match:class ^([tT]hunar)$, opacity 0.75 0.75"
    "match:class ^(discord)$, opacity 0.80 0.80"
    "match:class ^([sS]potify)$, opacity 0.80 0.80"
    "match:class ^(dev.zed.Zed)$, opacity 0.92 0.92"
    "match:class ^(md.Obsidian)$, opacity 0.92 0.92"
  ];

  layerrule = [
    # Blur normal Noctalia surfaces and let Noctalia handle their animations.
    "match:namespace ^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$, no_anim on, ignore_alpha 0.5, blur on, blur_popups on"

    # The screenshot selector uses a separate namespace.
    "match:namespace ^noctalia-screenshot-region$, no_anim on"
  ];

  workspace = [
    "10, border:false, rounding:false"
  ]
  ++ lib.optionals config.mySystem.apps.foot.enable [
    "special:terminal, on-created-empty:[float; size 960 540] $terminal, persistent:false"
  ]
  ++ lib.optionals config.mySystem.apps.discord.enable [
    "name:discord, on-created-empty:uwsm-app -- discord"
  ]
  ++ lib.optionals config.mySystem.apps.spotify.enable [
    "name:spotify, on-created-empty:uwsm-app -- spotify"
  ];

  gesture = [
    "3, horizontal, workspace"
  ];

  # Layout configuration
  dwindle = {
    preserve_split = true;
  };

  master = {
    new_status = "master";
  };

  # Miscellaneous
  misc = {
    force_default_wallpaper = 0;
    disable_splash_rendering = true;
    disable_hyprland_logo = true;
    background_color = lib.mkIf config.mySystem.desktop.stylix.enable "rgb(${config.lib.stylix.colors.base00})";

    vrr = 2;
  };

  xwayland = {
    force_zero_scaling = true;
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
}
