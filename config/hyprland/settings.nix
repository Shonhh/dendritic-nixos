{
  config,
  lib,
  commands,
}:

let
  lua = lib.generators.toLua { };

  settings = {
    render.direct_scanout = 0;

    general = {
      gaps_in = 3;
      gaps_out = 8;
      border_size = 2;
      resize_on_border = true;
      allow_tearing = false;
      layout = "dwindle";
    };

    decoration = {
      rounding = 7;
      active_opacity = 1.0;
      inactive_opacity = 1.0;

      blur = {
        enabled = true;
        size = 9;
        passes = 4;
        new_optimizations = true;
        ignore_opacity = true;
        xray = false;
        popups = true;
        popups_ignorealpha = 0.2;
      };
    };

    dwindle.preserve_split = true;
    master.new_status = "master";

    misc = {
      force_default_wallpaper = 0;
      disable_splash_rendering = true;
      disable_hyprland_logo = true;
      vrr = 2;
    }
    // lib.optionalAttrs config.mySystem.desktop.stylix.enable {
      background_color = "rgb(${config.lib.stylix.colors.base00})";
    };

    xwayland.force_zero_scaling = true;

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

    cursor.no_hardware_cursors = 1;
    animations.enabled = true;
  };
in
''
  hl.config(${lua settings})

  -- Apply host-specific startup workspaces
  for output, workspace in pairs(${lua config.mySystem.desktop.displays.hyprlandDefaultWorkspaces}) do
      hl.workspace_rule({
          workspace = tostring(workspace),
          monitor = output,
          default = true,
      })
  end

  -- Keep using the monitor strings already defined in your hosts.
  do
      local monitors = ${lua config.mySystem.desktop.displays.hyprland}
      local nextDefaultWorkspace = 3

      for _, specification in ipairs(monitors) do
          local fields = {}
          for field in (specification .. ","):gmatch("(.-),") do
              fields[#fields + 1] = field:match("^%s*(.-)%s*$")
          end

          local rule = { output = fields[1] }

          if fields[2] == "disable" then
              rule.disabled = true
          else
              assert(#fields >= 4, "Incomplete monitor specification: " .. specification)
              rule.mode = fields[2]
              rule.position = fields[3]
              rule.scale = tonumber(fields[4]) or fields[4]

              for i = 5, #fields, 2 do
                  assert(fields[i + 1], "Missing monitor option value: " .. specification)
                  local value = fields[i + 1]
                  if value == "true" then
                      value = true
                  elseif value == "false" then
                      value = false
                  else
                      value = tonumber(value) or value
                  end
                  rule[fields[i]] = value
              end
          end

          if not rule.disabled and rule.output ~= "" then
              hl.workspace_rule({
                  workspace = tostring(nextDefaultWorkspace),
                  monitor = rule.output,
                  default = true,
              })

              nextDefaultWorkspace = nextDefaultWorkspace + 1
          end

          hl.monitor(rule)
      end
  end

  -- Application opacity.
  do
      local rules = {
          { "^([tT]hunar)$", "0.75 0.75" },
          { "^(discord)$", "0.80 0.80" },
          { "^([sS]potify)$", "0.80 0.80" },
          { "^(dev.zed.Zed)$", "0.92 0.92" },
          { "^(md.Obsidian)$", "0.92 0.92" },
      }

      for _, rule in ipairs(rules) do
          hl.window_rule({
              match = { class = rule[1] },
              opacity = rule[2],
          })
      end
  end

  -- Let Noctalia animate its own surfaces.
  hl.layer_rule({
      match = {
          namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
      },
      no_anim = true,
      ignore_alpha = 0.5,
      blur = true,
      blur_popups = true,
  })

  hl.layer_rule({
      match = { namespace = "^noctalia-screenshot-region$" },
      no_anim = true,
  })

  hl.workspace_rule({
      workspace = "12",
      no_border = true,
      no_rounding = true,
  })

  hl.gesture({
      fingers = 3,
      direction = "horizontal",
      action = "workspace",
  })

  -- Define curves before the animations that reference them.
  do
      local curves = {
          { "wind", 0.05, 0.85, 0.03, 0.97 },
          { "winIn", 0.07, 0.88, 0.04, 0.99 },
          { "winOut", 0.20, -0.15, 0, 1 },
          { "liner", 1, 1, 1, 1 },
          { "md3_standard", 0.12, 0, 0, 1 },
          { "md3_decel", 0.05, 0.80, 0.10, 0.97 },
          { "md3_accel", 0.20, 0, 0.80, 0.08 },
          { "overshot", 0.05, 0.85, 0.07, 1.04 },
          { "crazyshot", 0.1, 1.22, 0.68, 0.98 },
          { "hyprnostretch", 0.05, 0.82, 0, 1 },
          { "menu_decel", 0.05, 0.82, 0, 1 },
          { "menu_accel", 0.20, 0, 0.82, 0.10 },
          { "easeInOutCirc", 0.78, 0, 0.15, 1 },
          { "easeOutCirc", 0, 0.48, 0.38, 1 },
          { "easeOutExpo", 0.10, 0.94, 0.23, 0.98 },
          { "softAcDecel", 0.20, 0.20, 0.15, 1 },
          { "md2", 0.30, 0, 0.15, 1 },
          { "OutBack", 0.28, 1.40, 0.58, 1 },
      }

      for _, curve in ipairs(curves) do
          hl.curve(curve[1], {
              type = "bezier",
              points = {
                  { curve[2], curve[3] },
                  { curve[4], curve[5] },
              },
          })
      end

      local animations = {
          { "border", 1.6, "liner" },
          { "borderangle", 82, "liner", "once" },
          { "windowsIn", 3.2, "winIn", "slide" },
          { "windowsOut", 2.8, "easeOutCirc" },
          { "windowsMove", 3.0, "wind", "slide" },
          { "fade", 1.8, "md3_decel" },
          { "layersIn", 1.8, "menu_decel", "slide" },
          { "layersOut", 1.5, "menu_accel" },
          { "fadeLayersIn", 1.6, "menu_decel" },
          { "fadeLayersOut", 1.8, "menu_accel" },
          { "workspaces", 4.0, "menu_decel", "slide" },
          { "specialWorkspace", 2.3, "md3_decel", "slidefadevert 15%" },
      }

      for _, animation in ipairs(animations) do
          hl.animation({
              leaf = animation[1],
              enabled = true,
              speed = animation[2],
              bezier = animation[3],
              style = animation[4],
          })
      end
  end
''
+ lib.optionalString config.mySystem.apps.foot.enable ''
  hl.workspace_rule({
      workspace = "special:terminal",
      persistent = false,
  })
''
+ ''
  -- Launch applications when their workspace is created empty.
  do
      local programs = {}

      ${lib.optionalString config.mySystem.apps.foot.enable ''
        programs["special:terminal"] = {
            command = ${lua "uwsm-app -- ${commands.terminal}"},
            rules = { float = true, size = { 960, 540 } },
        }
      ''}

      ${lib.optionalString config.mySystem.apps.discord.enable ''
        hl.workspace_rule({
            workspace = "2",
            default_name = "discord",
        })

        programs["2"] = {
            command = "uwsm-app -- discord",
            rules = {},
        }
      ''}

      ${lib.optionalString config.mySystem.apps.spotify.enable ''
        hl.workspace_rule({
            workspace = "1",
            default_name = "spotify",
        })

        programs["1"] = {
            command = "uwsm-app -- spotify",
            rules = {},
        }
      ''}

      for number = 1, 10 do
          hl.workspace_rule({
              workspace = tostring(number + 2),
              default_name = tostring(number),
          })
      end

      hl.on("workspace.created", function(ws)
          if not ws.is_empty then return end

          local program = programs[tostring(ws.id)]

          -- Only the special terminal uses a name-based lookup.
          if ws.name == "special:terminal" then
              program = programs["special:terminal"]
          end
          if not program then return end

          local rules = {}
          for key, value in pairs(program.rules) do
              rules[key] = value
          end

          rules.workspace = (ws.id and tostring(ws.id) or ws.name) .. " silent"
          hl.exec_cmd(program.command, rules)
      end)
  end
''
