set -eu

HYPRCTL="hyprctl"
POWERPROFILES="powerprofilesctl"

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
POWER_STATE="$STATE_DIR/hypr-gamemode-power-profile"

ANIMATIONS="$(
  "$HYPRCTL" getoption animations:enabled \
    | awk 'NR == 1 { print $2 }'
)"

if [ "$ANIMATIONS" = "0" ]; then
  "$HYPRCTL" reload

  if [ -f "$POWER_STATE" ]; then
    PROFILE="$(cat "$POWER_STATE")"

    if [ -n "$PROFILE" ]; then
      noctalia msg power-set "$PROFILE"
    fi

    rm -f "$POWER_STATE"
  else
    noctalia msg power-set balanced
  fi

  exit 0
fi

"$POWERPROFILES" get > "$POWER_STATE" 2>/dev/null \
  || printf '%s\n' "balanced" > "$POWER_STATE"

noctalia msg power-set performance

"$HYPRCTL" --batch "\
  keyword animations:enabled false;\
  keyword decoration:shadow:enabled false;\
  keyword decoration:blur:enabled false;\
  keyword general:gaps_in 0;\
  keyword general:gaps_out 0;\
  keyword general:border_size 0;\
  keyword decoration:rounding 0"
