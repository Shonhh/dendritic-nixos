{ ... }:

{
  flake.nixosModules.helium =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.helium;

      helium = pkgs.appimageTools.wrapType2 rec {
        pname = "helium";
        version = "0.11.5.1";

        src = pkgs.fetchurl {
          url = "https://github.com/imputnet/helium-linux/releases/download/${version}/${pname}-${version}-x86_64.AppImage";
          sha256 = "sha256-Ni7IZ9UBafr+ss0BcQaRKqmlmJI4IV1jRAJ8jhcodlg=";
        };

        extraInstallCommands =
          let
            contents = pkgs.appimageTools.extract { inherit pname version src; };
          in
          ''
            install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications

            substituteInPlace $out/share/applications/${pname}.desktop \
              --replace 'Exec=AppRun' 'Exec=${pname}'

            cp -r ${contents}/usr/share/icons $out/share
          '';
      };
    in
    {
      options.mySystem.apps.helium = {
        enable = lib.mkEnableOption "Helium Browser";
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ helium ];
      };
    };
}
