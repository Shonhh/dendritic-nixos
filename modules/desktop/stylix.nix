{ ... }:

{
  flake.nixosModules.stylix =
    {
      inputs,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.desktop.stylix;
    in
    {
      options.mySystem.desktop.stylix.enable = lib.mkEnableOption "Stylix System Theming";

      config = lib.mkIf cfg.enable {
        stylix = {
          enable = true;

          image = inputs.self + "/wallpapers/gruvified-wallpaper.png";
          polarity = "dark";
          base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";

          cursor = {
            package = pkgs.phinger-cursors;
            name = "phinger-cursors-light";
            size = 24;
          };

          fonts = {
            monospace = {
              package = pkgs.nerd-fonts.fira-code;
              name = "FiraCode Nerd Font";
            };

            sansSerif = {
              package = pkgs.lato;
              name = "Lato";
            };
          };

          icons = {
            enable = true;
            package = pkgs.papirus-icon-theme;

            dark = "Papirus-Dark";
            light = "Papirus-Light";
          };
        };

        home-manager.users.shonh = {
          home.sessionVariables = {
            XCURSOR_THEME = config.stylix.cursor.name;
            XCURSOR_SIZE = toString config.stylix.cursor.size;
            HYPRCURSOR_THEME = config.stylix.cursor.name;
            HYPRCURSOR_SIZE = toString config.stylix.cursor.size;
          };
        };
      };
    };
}
