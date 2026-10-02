{
  config,
  lib,
  commands,
  focusMode,
  gameMode,
}:
{
  bind = [

    # Desktop Keybinds
    "$mod, Delete, exit,"

    "$mod+SHIFT, F, fullscreen"

    # Window Binds
    "$mod, Q, killactive,"
    "$mod, W, togglefloating,"

    # Move focus with mod + arrow keys
    "$mod, left, movefocus, l"
    "$mod, right, movefocus, r"
    "$mod, up, movefocus, u"
    "$mod, down, movefocus, d"

    # Handling Workspaces
    "$mod, 0, workspace, 10"
    "$mod SHIFT, 0, movetoworkspace, 10"

    # Scroll through existing workspaces with $mod + scroll
    "$mod, mouse_down, workspace, e+1"
    "$mod, mouse_up, workspace, e-1"
  ]
  ++ lib.optionals config.mySystem.apps.foot.enable [
    "$mod, T, exec, uwsm-app -- $terminal"
    "$mod, code:36, togglespecialworkspace, terminal"
  ]
  ++ lib.optionals config.mySystem.apps.helium.enable [
    "$mod, F, exec, uwsm-app -- $browser"
  ]
  ++ lib.optionals config.mySystem.apps.thunar.enable [
    "$mod, E, exec, uwsm-app -- $file-manager"
  ]
  ++ lib.optionals config.mySystem.apps.zed.enable [
    "$mod, C, exec, uwsm-app -- $code_editor"
  ]
  ++ lib.optionals config.mySystem.apps.obsidian.enable [
    "$mod, N, exec, uwsm-app -- obsidian"
  ]
  ++ lib.optionals config.mySystem.apps.discord.enable [
    "$mod, D, workspace, name:discord"
  ]
  ++ lib.optionals config.mySystem.apps.spotify.enable [
    "$mod, S, workspace, name:spotify"
  ]
  ++ lib.optionals config.mySystem.apps.steam.enable [
    "$mod, G, exec, uwsm-app -- steam"
    "$mod+Shift, G, exec, steam-console"
  ]
  ++ lib.optionals config.mySystem.desktop.noctalia.enable [
    "$mod, P, exec, ${commands.screenshot}"
    "$mod+Alt, G, exec, ${lib.getExe gameMode}"
    "$mod+Alt, F, exec, ${lib.getExe focusMode}"
    "CTRL+ALT, W, exec, ${commands.barToggle}"
    "$mod, A, exec, ${commands.launcher}"
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
  ]
  ++ lib.optionals config.mySystem.desktop.noctalia.enable [
    ",XF86MonBrightnessUp, exec, ${commands.brightnessUp}"
    ",XF86MonBrightnessDown, exec, ${commands.brightnessDown}"
  ];

  bindl = [
    ", XF86AudioNext, exec, playerctl next"
    ", XF86AudioPause, exec, playerctl play-pause"
    ", XF86AudioPlay, exec, playerctl play-pause"
    ", XF86AudioPrev, exec, playerctl previous"
  ];
}
