{ ... }:

{
  flake.nixosModules.mkw-recomp =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.games.mkw-recomp;

      package = pkgs.callPackage ../../packages/mkw-recomp.nix {
        inherit (cfg) gameDirectory;
      };
    in
    {
      options.mySystem.games.mkw-recomp = {
        enable = lib.mkEnableOption "Mario Kart World Recompiled";

        gameDirectory = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Writable installation directory; null uses the application default.";
        };
      };

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = [ package ];
      };
    };
}
