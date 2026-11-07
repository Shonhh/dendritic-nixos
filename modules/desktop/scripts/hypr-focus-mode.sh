set -eu

BORDER_SIZE="$(hyprctl repl 'hl.get_config("general.border_size")')"

case "$BORDER_SIZE" in
  0)
    hyprctl reload
    ;;
  ''|*[!0-9]*)
    printf 'Could not read Hyprland border size: %s\n' "$BORDER_SIZE" >&2
    exit 1
    ;;
  *)
    hyprctl eval '
      hl.config({
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

      hl.window_rule({
          name = "focus-mode-opacity",
          match = { class = ".*" },
          opacity = "1.0 override 1.0 override 1.0 override",
          force_rgbx = true,
      })
    '
    ;;
esac

# Toggle the bar after applying the compositor changes.
noctalia msg bar-toggle
