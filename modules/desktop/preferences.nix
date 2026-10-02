{ ... }:
{
  flake.nixosModules.desktop-preferences =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.desktop;
      apps = config.mySystem.apps;
      waylandEnabled = cfg.hyprland.enable || cfg.niri.enable || cfg.swayfx.enable;
    in
    {
      options.mySystem.desktop = {
        commands =
          lib.mapAttrs
            (
              _: value:
              lib.mkOption {
                type = lib.types.str;
                default = value;
                description = "Shared desktop command.";
              }
            )
            {
              terminal = "foot";
              browser = "helium";
              fileManager = "thunar";
              codeEditor = "zeditor";
              editor = "nvim";
              launcher = "noctalia msg panel-toggle launcher";
              screenshot = "noctalia msg screenshot-region";
              barToggle = "noctalia msg bar-toggle";
              brightnessUp = "noctalia msg brightness-up";
              brightnessDown = "noctalia msg brightness-down";
            };
        displays = {
          hyprland = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ",preferred,auto,1" ];
            description = "Host-specific Hyprland monitor declarations.";
          };
          niri = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Host-specific Niri output settings.";
          };
          sway = lib.mkOption {
            type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
            default = {
              "*".resolution = "1920x1080";
            };
            description = "Host-specific Sway output settings.";
          };
        };
      };

      config = lib.mkIf waylandEnabled {
        environment.sessionVariables.NIXOS_OZONE_WL = "1";
        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.common.default = "*";
        };
        home-manager.users.shonh.home.sessionVariables =
          lib.optionalAttrs apps.foot.enable { TERMINAL = cfg.commands.terminal; }
          // lib.optionalAttrs apps.neovim.enable { EDITOR = cfg.commands.editor; }
          // lib.optionalAttrs apps.helium.enable { BROWSER = cfg.commands.browser; };
      };
    };
}
