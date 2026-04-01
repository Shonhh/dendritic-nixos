{ ... }:

{
  flake.nixosModules.core =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.core;
    in
    {
      options.mySystem.system.core.enable = lib.mkEnableOption "Core System Settings";

      config = lib.mkIf cfg.enable {

        # --- Flakes & Nix Settings ---
        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          download-buffer-size = 536870912; # 512 MB
          cores = 2;
          max-jobs = 1;
        };

        # --- Kernel ---
        boot.kernelPackages = pkgs.linuxPackages_zen;
        boot.kernelModules = [ "ntsync" ];

        # --- Networking ---
        networking.networkmanager.enable = true;

        # --- Time & Locale ---
        time.timeZone = "America/Chicago";
        i18n.defaultLocale = "en_US.UTF-8";
        i18n.extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };

        # --- X11 & Login Manager ---
        services.xserver.enable = true;
        mySystem.system.tuigreet.enable = true;
        services.xserver.xkb = {
          layout = "us";
          variant = "";
        };

        # --- Services (Printing & Audio) ---
        services.printing.enable = true;
        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        # --- User Account ---
        users.users.shonh = {
          isNormalUser = true;
          description = "Shonh";
          extraGroups = [
            "networkmanager"
            "wheel"
            "i2c"
          ];
        };

        # --- Home Manager Base ---
        home-manager = {
          backupFileExtension = "backup";

          users.shonh = {
            home.sessionVariables = {
              TERMINAL = "foot";
              EDITOR = "nvim";
              BROWSER = "vivaldi";
            };

            home.stateVersion = "25.11";
          };
        };

        # --- Base Applications ---
        environment.systemPackages = with pkgs; [
          tree
          sl
          cmatrix
          cbonsai
          vivaldi
          wget
          unzip
          vlc
          kdePackages.filelight
          efibootmgr
        ];
      };
    };
}
