set -eu

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

action="${1:-}"
argument="${2:-}"

if [ "$action" = workspace ]; then
  case "$argument" in
    ''|*[!0-9]*)
      echo "Usage: wm-ctrl workspace NUMBER" >&2
      exit 2
      ;;
  esac
fi

case "$wm:$action" in
  hyprland:workspace)
    hyprctl dispatch "hl.dsp.focus({ workspace = \"$argument\" })"
    ;;
  niri:workspace)
    niri msg action focus-workspace "$argument"
    ;;
  sway:workspace)
    swaymsg workspace number "$argument"
    ;;

  hyprland:scratchpad)
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("")'
    ;;
  sway:scratchpad)
    swaymsg scratchpad show
    ;;

  hyprland:gaps_off)
    hyprctl eval '
      hl.config({
          animations = { enabled = false },
          general = {
              gaps_in = 0,
              gaps_out = 0,
          },
          decoration = {
              rounding = 0,
              shadow = { enabled = false },
              blur = { enabled = false },
          },
      })
    '
    ;;
  sway:gaps_off)
    swaymsg "gaps inner 0, gaps outer 0, smart_gaps on"
    ;;
  niri:gaps_off|niri:reload)
    :
    ;;

  hyprland:reload)
    hyprctl reload
    ;;
  sway:reload)
    swaymsg reload
    ;;

  *)
    echo "Unsupported command '$action' for $wm" >&2
    exit 2
    ;;
esac
