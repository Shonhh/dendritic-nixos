{ ... }:

{
  flake.nixosModules.wm-ctrl =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.desktop.wm-ctrl;
    in
    {
      options.mySystem.desktop.wm-ctrl.enable =
        lib.mkEnableOption "Provides an executable to handle a variety of WM IPC commands.";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          (writeShellScriptBin "wm-ctrl" ''
            # 1. Detect the active compositor
            if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
              WM="hyprland"
            elif [ -n "$NIRI_SOCKET" ]; then
              WM="niri"
            elif [ -n "$SWAYSOCK" ]; then
              WM="sway"
            else
              echo "No supported Wayland compositor detected."
              exit 1
            fi

            COMMAND=$1
            ARG=$2

            # 2. Translate universal verbs into specific compositor IPC commands
            case $COMMAND in
              "workspace")
                [ "$WM" = "hyprland" ] && hyprctl dispatch workspace "$ARG"
                [ "$WM" = "niri" ] && niri msg action focus-workspace "$ARG"
                [ "$WM" = "sway" ] && swaymsg workspace number "$ARG"
                ;;

              "scratchpad")
                [ "$WM" = "hyprland" ] && hyprctl dispatch togglespecialworkspace
                [ "$WM" = "sway" ] && swaymsg scratchpad show
                ;;

              "gaps_off")
                [ "$WM" = "hyprland" ] && hyprctl --batch "keyword animations:enabled 0; keyword decoration:shadow:enabled 0; keyword decoration:blur:enabled 0; keyword general:gaps_in 0; keyword general:gaps_out 0; keyword decoration:rounding 0"
                [ "$WM" = "sway" ] && swaymsg "gaps inner 0, gaps outer 0, smart_gaps on"
                # Niri natively bypasses rendering on fullscreen, so we do nothing!
                ;;

              "reload")
                [ "$WM" = "hyprland" ] && hyprctl reload
                [ "$WM" = "sway" ] && swaymsg reload
                ;;
            esac
          '')
        ];
      };
    };
}
