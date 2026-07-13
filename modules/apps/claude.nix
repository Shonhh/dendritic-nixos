{ ... }:

{
  flake.nixosModules.claude =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.claude;
    in
    {
      options.mySystem.apps.claude.enable = lib.mkEnableOption "Claude Desktop/Code";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh = {
          programs.claude-code = {
            enable = true;
          };
        };
      };
    };
}
