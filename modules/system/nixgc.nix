{ ... }:

{
  flake.nixosModules.nixgc =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.nixgc;
    in
    {
      options.mySystem.system.nixgc.enable = lib.mkEnableOption "Enables Generation Garbage Collection";

      config = lib.mkIf cfg.enable {
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 14d";
        };
      };
    };
}
