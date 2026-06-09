{ ... }:

{
  flake.nixosModules.odysseus =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.odysseus;
    in
    {
      options.mySystem.apps.odysseus = {
        enable = lib.mkEnableOption "Odysseus Local AI Workspace";

        targetDir = lib.mkOption {
          type = lib.types.str;
          default = "/mnt/shared/odysseus";
          description = "The target directory where the Odysseus repository will be cloned and executed.";
        };
      };

      config = lib.mkIf cfg.enable {
        mySystem.system.docker.enable = true;

        home-manager.users.shonh = {
          home.packages = [
            # 1. The Hardware-Agnostic Launcher Script
            (pkgs.writeShellScriptBin "launch-odysseus" ''
              TARGET_DIR="${cfg.targetDir}"

              if [ ! -d "$TARGET_DIR" ]; then
                echo "Odysseus not found. Cloning repository..."
                mkdir -p "$(dirname "$TARGET_DIR")"
                ${pkgs.git}/bin/git clone https://github.com/pewdiepie-archdaemon/odysseus.git "$TARGET_DIR"

                # Dynamic hardware layer configuration
                if [ -c /dev/nvidia0 ] || command -v nvidia-smi &> /dev/null; then
                  echo "NVIDIA GPU detected. Wiring in CUDA passthrough..."
                  echo "COMPOSE_FILE=docker-compose.yml:docker/gpu.nvidia.yml" > "$TARGET_DIR/.env"
                else
                  echo "No NVIDIA GPU detected. Safely defaulting to CPU mode..."
                  echo "# CPU-only mode" > "$TARGET_DIR/.env"
                fi

                echo "Setup complete!"
              fi

              cd "$TARGET_DIR" || exit

              # Spin up the containers
              docker compose up -d

              PROFILE_DIR="$HOME/.config/odysseus-profile"
              mkdir -p "$PROFILE_DIR"

              # Launch Helium and block execution until closed
              helium --app="http://localhost:7000" --user-data-dir="$PROFILE_DIR"

              # Tear down stack on exit
              docker compose down
            '')

            # 2. The Native App Launcher Shortcut
            (pkgs.makeDesktopItem {
              name = "odysseus-workspace";
              desktopName = "Odysseus Workspace";
              comment = "Launch Local AI Environment";
              exec = "launch-odysseus";
              icon = "utilities-terminal";
              terminal = false;
              type = "Application";
              categories = [ "Development" ];
            })
          ];
        };
      };
    };
}
