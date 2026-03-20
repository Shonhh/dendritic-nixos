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
      cfg = config.mySystem.apps.steam;
    in
    {
      options.mySystem.apps.steam.enable = lib.mkEnableOption "Steam Gaming";

      config = lib.mkIf cfg.enable {
        programs = {
          steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
          };

          gamescope = {
            enable = true;
            capSysNice = false; # doesn't work with UWSM
          };

          gamemode = {
            enable = true;
            enableRenice = true;
          };
        };

        environment.systemPackages = with pkgs; [
          mangohud
          protonup-qt

          (writeShellScriptBin "steam-console" ''
            hyprctl dispatch workspace 10
            uwsm app -- gamemoderun gamescope \
              -w 1920 -h 1080 -W 1920 -H 1080 -r 200 \
              -e -f \
              --xwayland-count 2 \
              --hdr-enabled --hdr-itm-enabled \
              --force-grab-cursor \
              -- steam -noverifyfiles -gamepadui
          '')
        ];
      };
    };
}
