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
  # Match the retention policy of the automatic garbage collector.
  sudo nix-collect-garbage --delete-older-than 14d
  exit 0
fi

cd "$flake_dir"
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
    nix flake check
    nix eval --json .#nixosConfigurations --apply builtins.attrNames |
      jq -r '.[]' |
      while IFS= read -r target; do
        nix eval --raw ".#nixosConfigurations.$target.config.system.build.toplevel.drvPath"
        printf '\n'
      done
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
