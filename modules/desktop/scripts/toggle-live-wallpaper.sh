live=linux-wallpaperengine.service
static=hyprpaper.service

if systemctl --user is-active --quiet "$live"; then
  systemctl --user stop "$live"
  systemctl --user start "$static"
else
  # Confirm the static service exists before switching away from it.
  systemctl --user cat "$static" >/dev/null
  systemctl --user stop "$static"

  if ! systemctl --user start "$live"; then
    systemctl --user start "$static"
    exit 1
  fi
fi
