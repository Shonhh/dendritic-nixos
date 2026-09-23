{ ... }:

{
  flake.nixosModules.slack =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.slack;
    in
    {
      options.mySystem.apps.slack.enable = lib.mkEnableOption "Slack Desktop Client";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home.packages = with pkgs; [
          slack
        ];
      };
    };
}
