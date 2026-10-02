{ ... }:
{
  flake.nixosModules.wm-ctrl =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.desktop.wm-ctrl.enable = lib.mkEnableOption "Shared compositor command dispatcher";

      config = lib.mkIf config.mySystem.desktop.wm-ctrl.enable {
        environment.systemPackages = [
          (pkgs.writeShellApplication {
            name = "wm-ctrl";
            runtimeInputs =
              lib.optional config.mySystem.desktop.hyprland.enable config.programs.hyprland.package
              ++ lib.optional config.mySystem.desktop.niri.enable config.programs.niri.package
              ++ lib.optional config.mySystem.desktop.swayfx.enable config.programs.sway.package;
            text = builtins.readFile ./scripts/wm-ctrl.sh;
          })
        ];
      };
    };
}
