{
  config,
  lib,
  commands,
  focusMode,
  gameMode,
}:

let
  lua = lib.generators.toLua { };

  execBind = keys: command: "hl.bind(${lua keys}, hl.dsp.exec_cmd(${lua command}))";
in
''
  hl.bind("SUPER + Delete", hl.dsp.exit())
  hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({
      action = "toggle",
      mode = "fullscreen",
  }))

  hl.bind("SUPER + Q", hl.dsp.window.close())
  hl.bind("SUPER + W", hl.dsp.window.float({ action = "toggle" }))

  do
      local directions = {
          left = "l",
          right = "r",
          up = "u",
          down = "d",
      }

      for key, direction in pairs(directions) do
          hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = direction }))
      end
  end

  hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
  hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

  hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "12" }))
  hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({
      workspace = "12",
      follow = true,
  }))

  for i = 1, 9 do
      local key = "code:" .. tostring(i + 9)
      local workspace = tostring(i + 2)

      hl.bind("SUPER + " .. key, hl.dsp.focus({
          workspace = workspace,
      }))
      hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({
          workspace = workspace,
          follow = true,
      }))
  end

  hl.bind("SUPER + Z", hl.dsp.window.drag(), { mouse = true })
  hl.bind("SUPER + X", hl.dsp.window.resize(), { mouse = true })
  hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

  do
      local flags = { repeating = true, locked = true }

      hl.bind("XF86AudioRaiseVolume",
          hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), flags)
      hl.bind("XF86AudioLowerVolume",
          hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), flags)
      hl.bind("XF86AudioMute",
          hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), flags)
      hl.bind("XF86AudioMicMute",
          hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), flags)
  end

  hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
  hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
  hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
  hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
''
+ lib.optionalString config.mySystem.apps.foot.enable ''
  ${execBind "SUPER + T" "uwsm-app -- ${commands.terminal}"}
  hl.bind("SUPER + code:36", hl.dsp.workspace.toggle_special("terminal"))
''
+ lib.optionalString config.mySystem.apps.helium.enable ''
  ${execBind "SUPER + F" "uwsm-app -- ${commands.browser}"}
''
+ lib.optionalString config.mySystem.apps.thunar.enable ''
  ${execBind "SUPER + E" "uwsm-app -- ${commands.fileManager}"}
''
+ lib.optionalString config.mySystem.apps.zed.enable ''
  ${execBind "SUPER + C" "uwsm-app -- ${commands.codeEditor}"}
''
+ lib.optionalString config.mySystem.apps.obsidian.enable ''
  ${execBind "SUPER + N" "uwsm-app -- obsidian"}
''
+ lib.optionalString config.mySystem.apps.discord.enable ''
  hl.bind("SUPER + D", hl.dsp.focus({ workspace = "2" }))
''
+ lib.optionalString config.mySystem.apps.spotify.enable ''
  hl.bind("SUPER + S", hl.dsp.focus({ workspace = "1" }))
''
+ lib.optionalString config.mySystem.apps.steam.enable ''
  ${execBind "SUPER + G" "uwsm-app -- steam"}
  ${execBind "SUPER + SHIFT + G" "steam-console"}
''
+ lib.optionalString config.mySystem.desktop.noctalia.enable ''
  ${execBind "SUPER + P" commands.screenshot}
  ${execBind "SUPER + ALT + G" (lib.getExe gameMode)}
  ${execBind "SUPER + ALT + F" (lib.getExe focusMode)}
  ${execBind "CTRL + ALT + W" commands.barToggle}
  ${execBind "SUPER + A" commands.launcher}

  hl.bind("XF86MonBrightnessUp",
      hl.dsp.exec_cmd(${lua commands.brightnessUp}),
      { repeating = true, locked = true })
  hl.bind("XF86MonBrightnessDown",
      hl.dsp.exec_cmd(${lua commands.brightnessDown}),
      { repeating = true, locked = true })
''
