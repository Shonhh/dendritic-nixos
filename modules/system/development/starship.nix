{ ... }:

{
  flake.nixosModules.development =
    {
      inputs,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.starship;
    in
    {
      options.mySystem.system.starship.enable = lib.mkEnableOption "Starship Configuration";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh = {
          stylix.targets.starship.enable = false;
          programs.starship = {
            enable = true;
            enableZshIntegration = true;

            settings = {
              format = "[█](color_orange)$os$username[](bg:color_yellow fg:color_orange)$directory[](fg:color_yellow bg:color_aqua)$git_branch$git_status[](fg:color_aqua bg:color_blue)$c$cpp$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:color_blue bg:color_bg3)$docker_context$conda$pixi[](fg:color_bg3 bg:color_bg1)$time[ ](fg:color_bg1)$line_break$character";

              palette = "stylix";

              palettes.stylix =
                let
                  darken = inputs.nix-colorizer.hex.darken;
                in
                {
                  color_fg0 = "#${config.lib.stylix.colors.base05}"; # Default Foreground
                  color_bg1 = "#${config.lib.stylix.colors.base01}"; # Lighter Background
                  color_bg3 = "#${config.lib.stylix.colors.base03}"; # Selection Background
                  color_fg_alt = "#${config.lib.stylix.colors.base04}"; # Replaces the hardcoded #83a598

                  color_blue = darken "#${config.lib.stylix.colors.base0D}" 0.16; # Blue
                  color_aqua = darken "#${config.lib.stylix.colors.base0C}" 0.16; # Cyan
                  color_green = darken "#${config.lib.stylix.colors.base0B}" 0.16; # Green
                  color_orange = darken "#${config.lib.stylix.colors.base09}" 0.16; # Orange
                  color_purple = darken "#${config.lib.stylix.colors.base0E}" 0.16; # Magenta
                  color_red = darken "#${config.lib.stylix.colors.base08}" 0.16; # Red
                  color_yellow = darken "#${config.lib.stylix.colors.base0A}" 0.16; # Yellow
                };

              os = {
                disabled = false;
                style = "bg:color_orange fg:color_fg0";
                symbols = {
                  Windows = "󰍲";
                  Ubuntu = "󰕈";
                  SUSE = "";
                  Raspbian = "󰐿";
                  Mint = "󰣭";
                  Macos = "󰀵";
                  Manjaro = "";
                  Linux = "󰌽";
                  Gentoo = "󰣨";
                  Fedora = "󰣛";
                  Alpine = "";
                  Amazon = "";
                  Android = "";
                  AOSC = "";
                  Arch = "󰣇";
                  Artix = "󰣇";
                  EndeavourOS = "";
                  CentOS = "";
                  Debian = "󰣚";
                  Redhat = "󱄛";
                  RedHatEnterprise = "󱄛";
                  Pop = "";
                  NixOS = "";
                };
              };

              username = {
                show_always = true;
                style_user = "bg:color_orange fg:color_fg0";
                style_root = "bg:color_orange fg:color_fg0";
                format = "[ $user ]($style)";
              };

              directory = {
                style = "fg:color_fg0 bg:color_yellow";
                format = "[ $path ]($style)";
                truncation_length = 3;
                truncation_symbol = "…/";
                substitutions = {
                  "Documents" = "󰈙 ";
                  "Downloads" = " ";
                  "Music" = "󰝚 ";
                  "Pictures" = " ";
                  "Developer" = "󰲋 ";
                };
              };

              git_branch = {
                symbol = "";
                style = "bg:color_aqua";
                format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)";
              };

              git_status = {
                style = "bg:color_aqua";
                format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
              };

              nodejs = {
                symbol = "";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              c = {
                symbol = " ";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              cpp = {
                symbol = " ";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              rust = {
                symbol = "";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              golang = {
                symbol = "";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              php = {
                symbol = "";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              java = {
                symbol = "";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              kotlin = {
                symbol = "";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              haskell = {
                symbol = "";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              python = {
                symbol = "";
                style = "bg:color_blue";
                format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
              };

              docker_context = {
                symbol = "";
                style = "bg:color_bg3";
                format = "[[ $symbol( $context) ](fg:color_fg_alt bg:color_bg3)]($style)";
              };

              conda = {
                style = "bg:color_bg3";
                format = "[[ $symbol( $environment) ](fg:color_fg_alt bg:color_bg3)]($style)";
              };

              pixi = {
                style = "bg:color_bg3";
                format = "[[ $symbol( $version)( $environment) ](fg:color_fg0 bg:color_bg3)]($style)";
              };

              time = {
                disabled = false;
                time_format = "%R";
                style = "bg:color_bg1";
                format = "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)";
              };

              line_break = {
                disabled = false;
              };

              character = {
                disabled = false;
                success_symbol = "[❯](bold fg:color_green)";
                error_symbol = "[❯](bold fg:color_red)";
                vimcmd_symbol = "[❮](bold fg:color_green)";
                vimcmd_replace_one_symbol = "[❮](bold fg:color_purple)";
                vimcmd_replace_symbol = "[❮](bold fg:color_purple)";
                vimcmd_visual_symbol = "[❮](bold fg:color_yellow)";
              };
            };
          };
        };
      };
    };
}
