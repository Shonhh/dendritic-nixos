{ ... }:

{
  flake.nixosModules.helium =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.helium;
      helium = pkgs.callPackage ../../packages/helium.nix { };

      colors = config.lib.stylix.colors;
      rgb =
        color:
        map (offset: lib.fromHexString (builtins.substring offset 2 color)) [
          0
          2
          4
        ];

      browserTheme = {
        manifest_version = 3;
        name = "Stylix Desktop";
        version = "1.0.0";
        description = "Browser colors generated from the system Stylix palette.";
        theme.colors = {
          frame = rgb colors.base00;
          frame_inactive = rgb colors.base00;
          toolbar = rgb colors.base01;
          toolbar_text = rgb colors.base05;
          toolbar_button_icon = rgb colors.base05;
          tab_text = rgb colors.base05;
          tab_background_text = rgb colors.base04;
          bookmark_text = rgb colors.base05;
          omnibox_background = rgb colors.base00;
          omnibox_text = rgb colors.base05;
          ntp_background = rgb colors.base00;
          ntp_text = rgb colors.base05;
          ntp_link = rgb colors.base0D;
        };
      };
    in
    {
      options.mySystem.apps.helium = {
        enable = lib.mkEnableOption "Helium Browser";
      };

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh = {
          home.packages = [ helium ];

          # Register Widevine CDM for Helium.
          xdg.configFile."net.imput.helium/WidevineCdm/latest-component-updated-widevine-cdm".text =
            builtins.toJSON
              {
                Path = "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm";
              };

          xdg.dataFile."helium-stylix-theme/manifest.json".text = builtins.toJSON browserTheme;
        };
      };
    };
}
