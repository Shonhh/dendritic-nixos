{ ... }:

{
  flake.nixosModules.neovim =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.neovim;
    in
    {
      options.mySystem.apps.neovim.enable = lib.mkEnableOption "Neovim Editor";

      config = lib.mkIf cfg.enable {
        programs.neovim = {
          enable = true;
          programs.neovim.withRuby = false;
          programs.neovim.withPython3 = false;
        };

        home-manager.users.shonh.programs.neovim = {
          enable = true;
        };
      };
    };
}
