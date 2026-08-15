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
        # Use Noctalia's binary cache instead of compiling locally.
        nix.settings = {
          extra-substituters = [
            "https://noctalia.cachix.org"
          ];

          extra-trusted-public-keys = [
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
        };

        # Services used by Noctalia for battery, power, and Bluetooth data.
        mySystem.system.power-management.enable = true;
        mySystem.hardware.bluetooth.enable = true;

        # Secret Service provider used by Noctalia.
        services.gnome.gnome-keyring.enable = true;

        # I2C and DDC/CI support for external-display brightness controls.
        hardware.i2c.enable = true;

        environment.systemPackages = with pkgs; [
          ddcutil
        ];

        home-manager.users.shonh =
          { config, ... }:
          let
            # This remains outside the Nix store so Noctalia can write GUI
            # changes directly into the Git working tree.
            noctaliaRepo = "${config.home.homeDirectory}/nixos/modules/desktop/noctalia";
          in
          {
            imports = [
              inputs.noctalia.homeModules.default
            ];

            xdg.enable = true;

            # Stylix and any other Nix modules can merge attribute-set
            # definitions into programs.noctalia.settings.
            #
            # Do not set `settings = ./config.toml` here because a path cannot
            # be merged with the attribute sets supplied by Stylix.
            programs.noctalia = {
              enable = true;
              systemd.enable = true;
            };

            # Noctalia writes GUI changes to:
            #
            #   ~/.local/state/noctalia/settings.toml
            #
            # The destination is managed by Home Manager, while the writable
            # source remains in the Git repository.
            xdg.stateFile."noctalia/settings.toml".source =
              config.lib.file.mkOutOfStoreSymlink "${noctaliaRepo}/settings.toml";

            # Utilities used by screenshot, clipboard, and audio actions.
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
