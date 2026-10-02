{ ... }:
{
  flake.nixosModules.limine =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.system.limine = {
        enable = lib.mkEnableOption "Shared Limine configuration";
      };

      config = lib.mkIf config.mySystem.system.limine.enable {
        boot.loader.limine = {
          enable = true;
          secureBoot.enable = lib.mkDefault false;
          style = lib.mkIf config.mySystem.desktop.stylix.enable {
            wallpapers = lib.mkForce [ ];
            backdrop = lib.mkForce config.lib.stylix.colors.base00;
            graphicalTerminal.background = lib.mkForce "00${config.lib.stylix.colors.base00}";
          };
        };
        stylix.targets.limine.image.enable = lib.mkIf config.mySystem.desktop.stylix.enable false;
      };
    };
}
