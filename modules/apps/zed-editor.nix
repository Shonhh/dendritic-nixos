{ ... }:

{
  flake.nixosModules.zed =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.zed;
    in
    {
      options.mySystem.apps.zed.enable = lib.mkEnableOption "Zed Editor";

      config = lib.mkIf cfg.enable {

        home-manager.users.shonh = {
          stylix.targets.zed.colors.enable = true;

          programs.zed-editor = {
            enable = true;

            extensions = [
              "HTML"
              "TOML"
              "Git Firefly"
              "Java"
              "Nix"
              "Colored Zed Icons Theme"
              "Gruvbox Baby"
              "Make"
            ];

            userSettings = {
              show_wrap_guides = true;
              terminal = {
                font-family = "${config.stylix.fonts.monospace.name}";
              };

              languages = {
                Nix = {
                  language_servers = [
                    "nixd"
                    "!nil"
                  ];
                  formatter = {
                    external = {
                      command = "nixfmt";
                    };
                  };
                };
              };

              telemetry = {
                diagnostics = false;
                metrics = false;
              };

              lsp = {
                clangd = {
                  binary = {
                    arguments = [
                      "-j=2"
                      "--pch-storage=memory"
                      "--query-driver=/usr/bin/gcc"
                    ];
                  };
                };
              };

              agent = {
                dock = "left";
              };

              title_bar = {
                show_sign_in = false;
                show_user_picture = false;
                show_branch_icon = false;
              };

              project_panel = {
                dock = "right";
                button = true;
              };

              diagnostics = {
                inline = {
                  enable = true;
                };
              };

              colorize_brackets = true;
              inlay_hints = {
                enabled = false;
              };

              relative_line_numbers = "enabled";
              sticky_scroll = {
                enabled = true;
              };

              use_system_prompts = true;
              use_system_path_prompts = true;

              indent_guides = {
                background_coloring = "disabled";
                coloring = "indent_aware";
              };

              minimap = {
                thumb = "always";
                show = "auto";
              };

              vim-mode = true;

              icon_theme = "Colored Zed Icons Theme Dark";

              buffer_font_family = "${config.stylix.fonts.monospace.name}";
              buffer_font_size = lib.mkDefault 15.0;

              ui_font_family = "${config.stylix.fonts.sansSerif.name}";
              ui_font_size = lib.mkDefault 15.0;

              theme_overrides =
                let
                  palette = config.lib.stylix.colors;

                  brighten =
                    hex:
                    let
                      saturation = 2.00;
                      brightness = 1.20;

                      channels = map (offset: lib.fromHexString (builtins.substring offset 2 hex)) [
                        0
                        2
                        4
                      ];

                      lowest = lib.foldl' lib.min 255 channels;
                      highest = lib.foldl' lib.max 0 channels;
                      midpoint = (lowest + highest) / 2.0;

                      adjust =
                        channel:
                        let
                          saturated = midpoint + (channel - midpoint) * saturation;
                          result = builtins.floor (saturated * brightness);
                          clamped = lib.max 0 (lib.min 255 result);
                        in
                        lib.fixedWidthString 2 "0" (lib.toHexString clamped);
                    in
                    "#" + lib.concatMapStrings adjust channels;

                  c =
                    palette.withHashtag
                    // lib.genAttrs [
                      "base08"
                      "base09"
                      "base0A"
                      "base0B"
                      "base0C"
                      "base0D"
                      "base0E"
                      "base0F"
                    ] (name: brighten palette.${name});

                  # Derive a darker editor background from the current palette.
                  darken =
                    hex:
                    "#"
                    +
                      lib.concatMapStrings
                        (
                          offset:
                          let
                            channel = lib.fromHexString (builtins.substring offset 2 hex);
                            shaded = lib.toHexString (builtins.floor (channel * 0.60));
                          in
                          lib.fixedWidthString 2 "0" shaded
                        )
                        [
                          0
                          2
                          4
                        ];

                  editorBackground = if config.stylix.polarity == "dark" then darken palette.base00 else c.base00;

                  uiBackground = editorBackground;
                  uiForeground = brighten palette.base05;
                  uiMuted = brighten palette.base04;

                  uiSurface = if config.stylix.polarity == "dark" then darken palette.base01 else c.base01;
                in
                {
                  "Base16 ${palette.scheme-name}" = {
                    # Window, sidebar, toolbar, and status bar.
                    "background" = editorBackground;
                    "panel.background" = editorBackground;
                    "title_bar.background" = editorBackground;
                    "title_bar.inactive_background" = editorBackground;
                    "toolbar.background" = editorBackground;
                    "status_bar.background" = editorBackground;
                    "tab_bar.background" = editorBackground;

                    # Raised surfaces and inactive tabs.
                    "surface.background" = uiSurface;
                    "elevated_surface.background" = uiSurface;
                    "tab.inactive_background" = uiSurface;
                    "tab.active_background" = editorBackground;

                    # Editor.
                    "editor.background" = editorBackground;
                    "editor.gutter.background" = editorBackground;
                    "editor.active_line.background" = uiSurface;

                    # Interface foregrounds.
                    "text" = uiForeground;
                    "text.muted" = uiMuted;
                    "text.placeholder" = uiMuted;
                    "text.accent" = c.base0D;

                    "icon" = uiForeground;
                    "icon.muted" = uiMuted;
                    "icon.placeholder" = uiMuted;
                    "icon.accent" = c.base0D;

                    # Git status colors, using the already-brightened Stylix accents.
                    "modified" = c.base0A;
                    "created" = c.base0B;
                    "deleted" = c.base08;
                    "renamed" = c.base0D;
                    "conflict" = c.base09;

                    # Files excluded by Git remain secondary, but more readable.
                    "ignored" = uiMuted;
                    "hidden" = uiMuted;

                    syntax = {
                      "variable".color = c.base0D;
                      "variable.parameter".color = c.base0D;
                      "variable.member".color = c.base0D;
                      "variable.special".color = c.base0D;
                      "property".color = c.base0D;

                      "function".color = c.base0A;
                      "function.builtin".color = c.base0A;
                      "function.method".color = c.base0A;

                      "type".color = c.base0B;
                      "type.builtin".color = c.base0B;
                      "constructor".color = c.base0B;
                      "namespace".color = c.base0B;
                      "variant".color = c.base0B;

                      "keyword".color = c.base08;
                      "keyword.function".color = c.base08;
                      "keyword.modifier".color = c.base08;

                      "constant".color = c.base0E;
                      "number".color = c.base0E;
                      "boolean".color = c.base0E;

                      "attribute".color = c.base09;
                      "preproc".color = c.base09;

                      "string".color = c.base0B;
                      "string.special".color = c.base0C;
                      "string.escape".color = c.base09;

                      "operator".color = c.base05;
                      "punctuation".color = c.base05;
                      "punctuation.delimiter".color = c.base05;
                      "punctuation.bracket".color = c.base05;

                      "comment".color = c.base03;
                      "comment.doc".color = c.base03;
                    };
                  };
                };
            };

            userTasks = [
              {
                label = "Rust: Run";
                command = "cargo run";
                cwd = "$ZED_WORKTREE_ROOT";
                use_new_terminal = false;
                allow_concurrent_runs = false;
                reveal = "always";
              }
              {
                label = "C: Run All";
                command = "gcc *.c -o main && ./main";
                use_new_terminal = false;
                allow_concurrent_runs = false;
                reveal = "always";
              }
              {
                label = "C: Make Run";
                command = "make run";
                cwd = "$ZED_WORKTREE_ROOT";
                use_new_terminal = false;
                reveal = "always";
              }
            ];

            userKeymaps = [
              {
                context = "Workspace";
                bindings = {
                  "ctrl-n" = "task::Spawn";
                  "ctrl-alt-n" = "task::Rerun";
                };
              }
            ];
          };
        };
      };
    };
}
