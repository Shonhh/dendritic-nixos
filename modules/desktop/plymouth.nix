{ ... }:

{
  flake.nixosModules.plymouth =
    {
      inputs,
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.desktop.plymouth;
    in
    {
      options.mySystem.desktop.plymouth.enable = lib.mkEnableOption "Plymouth Boot Animation";

      config = lib.mkIf cfg.enable {
        stylix.targets.plymouth.enable = false;

        boot.plymouth = {
          enable = true;
          theme = "connect";

          themePackages = [
            pkgs.adi1090x-plymouth-themes
          ];
        };
      };
    };
}
