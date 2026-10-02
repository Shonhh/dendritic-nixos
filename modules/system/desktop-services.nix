{ ... }:
{
  flake.nixosModules.desktop-services =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.mySystem.system.desktop-services = {
        enable = lib.mkEnableOption "Graphical workstation services";
      };

      config = lib.mkIf config.mySystem.system.desktop-services.enable {
        services.xserver = {
          enable = true;
          xkb = {
            layout = "us";
            variant = "";
          };
        };
        services.printing.enable = true;
        services.pulseaudio.enable = false;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
        security.rtkit.enable = true;
      };
    };
}
