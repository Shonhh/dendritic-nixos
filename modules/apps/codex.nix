{ ... }:

{
  flake.nixosModules.codex =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.codex;
    in
    {
      options.mySystem.apps.codex.enable = lib.mkEnableOption "ChatGPT Codex";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh = {
          programs.codex = {
            enable = true;
          };
        };
      };
    };
}
