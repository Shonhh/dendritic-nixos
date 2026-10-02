action="${1:-}"

if [ "$#" -ne 1 ]; then
  echo "Usage: nrs {switch|boot|test|build|check|fmt|update|pull|clean}" >&2
  exit 2
fi

case "$action" in
  switch|boot|test|build|check|fmt|update|pull|clean) ;;
  *) echo "Unknown action: $action" >&2; exit 2 ;;
esac

if [ "$action" = clean ]; then
  sudo nix-collect-garbage --delete-older-than 14d
  exit 0
fi

# These variables are supplied by the Nix wrapper.
: "${flake_dir:?Missing repository path}" "${host:?Missing host name}"
cd "$flake_dir" || exit 1

case "$action" in
  pull)
    git pull --ff-only
    exit 0
    ;;
  update)
    nix flake update
    echo "Inputs updated. Review flake.lock, then run nrs build or nrs switch."
    exit 0
    ;;
  fmt)
    git ls-files -z -- '*.nix' | xargs -0 -r nixfmt
    exit 0
    ;;
  check)
    nix flake check --no-update-lock-file --keep-going --print-build-logs
    exit 0
    ;;
esac

before="$(readlink -f /run/current-system)"

if [ "$action" = build ]; then
  nixos-rebuild build --flake ".#$host" --log-format internal-json |& nom --json
else
  sudo -v
  sudo nixos-rebuild "$action" --flake ".#$host" --log-format internal-json |& nom --json
fi

if [ "$action" = switch ] || [ "$action" = test ]; then
  after="$(readlink -f /run/current-system)"
  nvd diff "$before" "$after" || true
  notify-send "NixOS Rebuild" "Completed $action for $host" -u normal || true
fi
