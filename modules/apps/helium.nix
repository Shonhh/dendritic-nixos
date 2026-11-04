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
        };
      };
    };
}
