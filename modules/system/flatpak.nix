{ ... }:

{
  flake.nixosModules.flatpak =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.system.flatpak;
    in
    {
      options.mySystem.system.flatpak.enable = lib.mkEnableOption "Flatpak Usability";

      config = lib.mkIf cfg.enable {
        services.flatpak.enable = true;
        systemd.services.flatpak-repo = {
          wantedBy = [ "multi-user.target" ];
          path = [ pkgs.flatpak ];
          script = ''
            	  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            	'';
        };
      };
    };
}
