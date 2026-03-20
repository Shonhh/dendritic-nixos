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
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
      options.mySystem.apps.spotify.enable = lib.mkEnableOption "Neovim Editor";

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

            theme = spicePkgs.themes.dribbblish;
            colorScheme = "gruvbox-material-dark";
          };
        };
      };
    };
}
