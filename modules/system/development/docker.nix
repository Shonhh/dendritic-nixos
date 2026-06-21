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
      options.mySystem.system.docker = {
        enable = lib.mkEnableOption "Docker Dev Tools";
        storeExternal = lib.mkEnableOption "Store Docker data in external drive named 'shared'";
      };

      config = lib.mkIf cfg.enable {
        virtualisation.docker = {
          enable = true;

          daemon.settings = lib.mkIf cfg.storeExternal {
            "data-root" = "/mnt/shared/docker-data";
          };
        };
      };
    };
}
