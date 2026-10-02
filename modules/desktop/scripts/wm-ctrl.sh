if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  wm=hyprland
elif [ -n "${NIRI_SOCKET:-}" ]; then
  wm=niri
elif [ -n "${SWAYSOCK:-}" ]; then
  wm=sway
else
  echo "No supported Wayland compositor detected." >&2
  exit 1
fi

command="${1:-}"
argument="${2:-}"
if [ "$command" = workspace ] && [ -z "$argument" ]; then
  echo "Usage: wm-ctrl workspace NUMBER" >&2
  exit 2
fi

case "$wm:$command" in
  hyprland:workspace) hyprctl dispatch workspace "$argument" ;;
  niri:workspace) niri msg action focus-workspace "$argument" ;;
  sway:workspace) swaymsg workspace number "$argument" ;;
  hyprland:scratchpad) hyprctl dispatch togglespecialworkspace ;;
  sway:scratchpad) swaymsg scratchpad show ;;
  hyprland:gaps_off)
    hyprctl --batch "keyword animations:enabled 0; keyword decoration:shadow:enabled 0; keyword decoration:blur:enabled 0; keyword general:gaps_in 0; keyword general:gaps_out 0; keyword decoration:rounding 0"
    ;;
  sway:gaps_off) swaymsg "gaps inner 0, gaps outer 0, smart_gaps on" ;;
  niri:gaps_off|niri:reload) : ;;
  hyprland:reload) hyprctl reload ;;
  sway:reload) swaymsg reload ;;
  *) echo "Unsupported command '$command' for $wm" >&2; exit 2 ;;
esac
