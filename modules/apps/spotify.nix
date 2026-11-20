{ ... }:

{
  flake.nixosModules.spotify =
    {
      inputs,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.spotify;
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      colors = config.lib.stylix.colors;
      uiFont = config.stylix.fonts.sansSerif.name;
    in
    {
      options.mySystem.apps.spotify.enable = lib.mkEnableOption "Themed Spotify";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh = {
          imports = [ inputs.spicetify-nix.homeManagerModules.default ];
          stylix.targets.spicetify.enable = false;

          programs.spicetify = {
            enable = true;
            enabledExtensions = with spicePkgs.extensions; [
              shuffle
              fullAppDisplay
              aiBandBlocker
            ];

            theme = spicePkgs.themes.dribbblish // {
              additionalCss = (spicePkgs.themes.dribbblish.additionalCss or "") + ''
                :root {
                  --font-family: "${uiFont}", sans-serif;
                  --encore-body-font-stack: "${uiFont}", sans-serif;
                  --encore-title-font-stack: "${uiFont}", sans-serif;
                }
                body, button, input, textarea {
                  font-family: "${uiFont}", sans-serif;
                }
              '';
            };
            colorScheme = "custom";
            customColorScheme = {
              text = colors.base05;
              subtext = colors.base04;
              sidebar-text = colors.base05;
              main = colors.base00;
              main-secondary = colors.base01;
              sidebar = colors.base00;
              player = colors.base01;
              card = colors.base01;
              shadow = colors.base00;
              selected-row = colors.base03;
              button = colors.base0D;
              button-active = colors.base0C;
              button-disabled = colors.base03;
              tab-active = colors.base02;
              notification = colors.base0D;
              notification-error = colors.base08;
              misc = colors.base03;
            };
          };
        };
      };
    };
}
