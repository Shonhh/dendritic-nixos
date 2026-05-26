{ ... }:

{
  flake.nixosModules.steam =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.steam;
    in
    {
      options.mySystem.apps.steam.enable = lib.mkEnableOption "Steam Gaming";

      config = lib.mkIf cfg.enable {
        programs = {
          steam = {
            enable = true;
            gamescopeSession.enable = true;

            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
          };

          gamescope = {
            enable = true;
            capSysNice = true;
          };

          gamemode = {
            enable = true;
            enableRenice = true;
          };
        };

        home-manager.users.shonh.home.packages = with pkgs; [
          mangohud
          protonup-qt

          (writeShellScriptBin "steam-console" ''
            uwsm-app -- gamemoderun sh -c 'unset LD_PRELOAD; steam -noverifyfiles -gamepadui'
          '')

          olympus
        ];

        # Olympus Dependency
        programs.nix-ld.libraries = with pkgs; [
          stdenv.cc.cc.lib
        ];
      };
    };
}
