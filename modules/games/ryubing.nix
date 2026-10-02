{ ... }:

{
  flake.nixosModules.ryubing =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.games.ryubing;
      ryubing-canary = pkgs.callPackage ../../packages/ryubing.nix { };
    in
    {
      options.mySystem.games.ryubing.enable = lib.mkEnableOption "Ryubing Canary Switch emulator";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = [
          ryubing-canary
        ];
      };
    };
}
