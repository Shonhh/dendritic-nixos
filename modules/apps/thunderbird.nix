{ ... }:

{
  flake.nixosModules.thunderbird =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.thunderbird;
    in
    {
      options.mySystem.apps.thunderbird = {
        enable = lib.mkEnableOption "Thunderbird Email Client";
      };

      config = lib.mkIf cfg.enable {
        programs.thunderbird.enable = true;
      };
    };
}
