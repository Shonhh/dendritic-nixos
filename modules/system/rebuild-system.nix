{ ... }:

{
  flake.nixosModules.rebuild-system =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.rebuild-system;
    in
    {
      options.mySystem.system.rebuild-system.enable =
        lib.mkEnableOption "Provides an executable to run a very nice rebuild script.";

      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          # required dependencies for the script
          nvd
          nix-output-monitor
          libnotify

          # main rebuild script
          (writeShellScriptBin "nrs" ''
            # exit immediately if any command fails
            set -e

            FLAKE_DIR="$HOME/nixos"

            # Check for arguments
            if [ -z "$1" ]; then
              echo "Error: Please provide an action (switch, boot, test, update, clean)"
              exit 1
            fi

            ACTION=$1

            # Handle the 'clean' command independently
            if [ "$ACTION" == "clean" ]; then
              echo "Deleting old generations and optimizing store..."
              sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations old
              sudo nix-collect-garbage -d
              echo "System cleaned!"
              exit 0
            fi

            # Navigate to the flake directory and pull changes
            echo "Navigating to $FLAKE_DIR and pulling latest changes..."
            cd "$FLAKE_DIR"
            git pull

            # Handle the 'update' command
            if [ "$ACTION" == "update" ]; then
              echo "Updating Flake inputs..."
              nix flake update
              BUILD_ACTION="switch"
            else
              BUILD_ACTION=$ACTION
            fi

            echo "Staging changes..."
            git add .

            echo "Formatting Nix files..."
            git ls-files '*.nix' | xargs nixfmt

            echo "Staging formatting changes..."
            git add .

            echo "Rebuilding NixOS ($BUILD_ACTION) for host $(hostname)..."
            # Execute the rebuild with Nix Output Monitor
            sudo true
            sudo nixos-rebuild "$BUILD_ACTION" --flake .#$(hostname) --log-format internal-json |& nom --json

            # Post-build actions for switch/update
            if [ "$BUILD_ACTION" == "switch" ]; then
              echo "Package diff:"
              # Suppress errors if this is the very first generation and no diff exists
              nvd diff $(ls -d1v /nix/var/nix/profiles/system-*-link | tail -n 2) || true

              notify-send "NixOS Rebuild" "System successfully updated to a new generation!" -u normal
            fi

            echo "Rebuild complete!"
          '')
        ];
      };
    };
}
