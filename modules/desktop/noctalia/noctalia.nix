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

        home-manager.users.shonh = {
          imports = [ inputs.noctalia.homeModules.default ];

          # UPDATED: Renamed from noctalia-shell to noctalia
          systemd.user.services.noctalia = {
            Unit = {
              Description = "Noctalia Desktop Environment";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              # UPDATED: The v5 executable is simply 'noctalia'
              ExecStart = "${pkgs.uwsm}/bin/uwsm app -- noctalia";
              Restart = "always";
              RestartSec = 2;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };

          # UPDATED: Enable the v5 module but let the app handle its own TOML config via the GUI
          programs.noctalia = {
            enable = true;
          };

          # Screenshot Plugin Dependencies
          home.packages = with pkgs; [
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
