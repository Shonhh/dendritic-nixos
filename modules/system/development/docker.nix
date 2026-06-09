{ ... }:

{
  flake.nixosModules.docker =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.docker;
    in
    {
      options.mySystem.system.docker.enable = lib.mkEnableOption "Docker Dev Tools";

      config = lib.mkIf cfg.enable {
        virtualisation.docker.enable = true;
      };
    };
}
