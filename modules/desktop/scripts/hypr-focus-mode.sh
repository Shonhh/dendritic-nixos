set -eu

HYPRCTL="hyprctl"

# toggle bar
noctalia msg bar-toggle

BORDER_SIZE="$(
  "$HYPRCTL" getoption general:border_size \
    | awk 'NR == 1 { print $2 }'
)"


if [ "$BORDER_SIZE" = "0" ]; then
  "$HYPRCTL" reload
  exit 0
fi

"$HYPRCTL" --batch "\
  keyword general:gaps_in 0;\
  keyword general:gaps_out 0;\
  keyword general:border_size 0;\
  keyword decoration:rounding 0;\
  keyword decoration:shadow:enabled false;\
  keyword decoration:blur:enabled false"

"$HYPRCTL" -r keyword windowrule \
  "match:class .*, opacity 1.0 override 1.0 override 1.0 override, force_rgbx on"
