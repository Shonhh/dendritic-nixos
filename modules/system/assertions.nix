{ ... }:
{
  flake.nixosModules.configuration-assertions = { config, ... }: {
    assertions = [
      {
        assertion = !(config.mySystem.system.tuigreet.enable && config.mySystem.system.regreet.enable);
        message = "Select one greeter: disable mySystem.system.tuigreet.enable when enabling regreet.";
      }
      {
        assertion = !config.mySystem.apps.foot.enable || config.mySystem.desktop.stylix.enable;
        message = "The configured Foot theme requires mySystem.desktop.stylix.enable.";
      }
      {
        assertion = !config.mySystem.apps.yazi.enable || config.mySystem.apps.neovim.enable;
        message = "The configured Yazi editor is Neovim; keep mySystem.apps.neovim.enable enabled.";
      }
      {
        assertion =
          !config.mySystem.hardware.screen-rotation.enable || config.mySystem.desktop.hyprland.enable;
        message = "The screen-rotation integration uses iio-hyprland and requires Hyprland.";
      }
    ];
  };
}
