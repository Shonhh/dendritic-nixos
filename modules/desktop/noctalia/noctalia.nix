{ ... }:

{
  flake.nixosModules.noctalia =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.mySystem.desktop.noctalia;
    in
    {
      options.mySystem.desktop.noctalia.enable = lib.mkEnableOption "Noctalia Shell";

      config = lib.mkIf cfg.enable {
        # Skip local compilation
        nix.settings = {
          extra-substituters = [ "https://noctalia.cachix.org" ];
          extra-trusted-public-keys = [
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
        };

        # Noctalia needs these background services to read battery and hardware data
        mySystem.system.power-management.enable = true;
        mySystem.hardware.bluetooth.enable = true;

        # Noctalia needs a secret service
        services.gnome.gnome-keyring.enable = true;

        # I2C Hardware bus for brightness controls
        hardware.i2c.enable = true;
        environment.systemPackages = [ pkgs.ddcutil ];

        home-manager.users.shonh = { config, lib, ... }: {
          # imports = [ inputs.noctalia.homeModules.default ];

          # UPDATED: Renamed from noctalia-shell to noctalia
          systemd.user.services.noctalia = {
            Unit = {
              Description = "Noctalia Desktop Environment";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${pkgs.uwsm}/bin/uwsm app -- noctalia";
              Restart = "always";
              RestartSec = 2;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };

          # programs.noctalia = {
          #   enable = true;
          # };

          # Keep declarative config in the repo, but leave runtime state local.
          home.activation.linkNoctalia = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            sourceDir="${config.home.homeDirectory}/nixos/modules/desktop/noctalia"
            configDir="${config.home.homeDirectory}/.config/noctalia"
            stateDir="${config.home.homeDirectory}/.local/state/noctalia"

            if [ -L "$configDir" ]; then
              rm "$configDir"
            fi

            if [ -L "$stateDir" ]; then
              rm "$stateDir"
            fi

            mkdir -p "$configDir" "$stateDir"

            ln -sfnT "$sourceDir/settings.toml" "$configDir/settings.toml"
            ln -sfnT "$sourceDir/plugins.json" "$configDir/plugins.json"
            ln -sfnT "$sourceDir/plugins" "$configDir/plugins"
          '';

          # Screenshot Plugin Dependencies + Noctalia
          home.packages = with pkgs; [
            inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

            grim
            imagemagick
            wl-clipboard
            cliphist
            pwvucontrol
            hyprshot
          ];
        };
      };
    };
}
