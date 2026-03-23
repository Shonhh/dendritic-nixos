{ ... }:

{
  flake.nixosModules.minecraft =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.games.minecraft;
    in
    {
      options.mySystem.games.minecraft.enable = lib.mkEnableOption "Minecraft and its Launchers";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          (prismlauncher.override {
            jdks = [
              temurin-jre-bin-8
              temurin-jre-bin-17
              temurin-jre-bin-21
            ];
          })
          badlion-client
        ];
      };
    };
}
