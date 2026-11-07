set -eu

STATE_DIR="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR is not set}"
POWER_STATE="$STATE_DIR/hypr-gamemode-power-profile"

ANIMATIONS="$(hyprctl repl 'hl.get_config("animations.enabled")')"

case "$ANIMATIONS" in
  false)
    PROFILE="balanced"

    if [ -f "$POWER_STATE" ]; then
      PROFILE="$(cat "$POWER_STATE")"
    fi

    powerprofilesctl set "${PROFILE:-balanced}"
    hyprctl reload
    rm -f "$POWER_STATE"
    exit 0
    ;;
  true) ;;
  *)
    printf 'Could not read Hyprland animation state: %s\n' "$ANIMATIONS" >&2
    exit 1
    ;;
esac

powerprofilesctl get > "$POWER_STATE"

hyprctl eval '
  hl.config({
      animations = { enabled = false },
      general = {
          gaps_in = 0,
          gaps_out = 0,
          border_size = 0,
      },
      decoration = {
          rounding = 0,
          shadow = { enabled = false },
          blur = { enabled = false },
      },
  })
'

if ! powerprofilesctl set performance; then
  printf '%s\n' \
    "Visual game mode enabled, but the performance power profile could not be selected." >&2
fi
