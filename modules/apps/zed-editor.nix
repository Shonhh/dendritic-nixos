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
          stylix.targets.zed.enable = false;

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

              buffer_font_family = "Fira Code Nerd Font";
              buffer_font_size = 15.0;
              theme = "Gruvbox Baby";

              ui_font_family = "Lato";
              ui_font_size = 15.0;
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
