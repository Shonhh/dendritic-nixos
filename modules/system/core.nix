{ ... }:
{
  flake.nixosModules.core =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.system.core = {
        enable = lib.mkEnableOption "Base system settings";
      };

      config = lib.mkIf config.mySystem.system.core.enable {
        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          download-buffer-size = 536870912;
          cores = 0;
          max-jobs = "auto";
        };
        nixpkgs.config.allowUnfree = true;
        # Retained from the original configuration; review when its consumer is updated.
        nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];
        networking.networkmanager.enable = true;
        time.timeZone = lib.mkDefault "America/Chicago";
        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
        i18n.extraLocaleSettings = lib.genAttrs [
          "LC_ADDRESS"
          "LC_IDENTIFICATION"
          "LC_MEASUREMENT"
          "LC_MONETARY"
          "LC_NAME"
          "LC_NUMERIC"
          "LC_PAPER"
          "LC_TELEPHONE"
          "LC_TIME"
        ] (_: "en_US.UTF-8");
        services.fstrim.enable = true;
        zramSwap = {
          enable = true;
          memoryPercent = 50;
        };
        environment.systemPackages = with pkgs; [
          tree
          wget
          unzip
          efibootmgr
          p7zip
        ];
      };
    };
}
