{
  pkgs,
  gameDirectory ? null,
}:

let
  pname = "mkw-recomp";
  version = "0.1.11";

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Mario Kart World Recompiled";
    exec = pname;
    icon = "applications-games";
    categories = [ "Game" ];
    terminal = false;
  };

  app = pkgs.appimageTools.wrapType2 {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://github.com/adriadam10/mkw-recomp/releases/download/v${version}/mkw-recomp-${version}-x86_64.AppImage";
      hash = "sha256-LZjk9PCQhd1GFoIgYq+0oa/FLmfW+SOreAMGfXIjXdA=";
    };

    extraPkgs = pkgs: [
      pkgs.vulkan-loader
    ];

    extraInstallCommands = ''
      install -Dm444 \
        ${desktopItem}/share/applications/${pname}.desktop \
        "$out/share/applications/${pname}.desktop"
    '';

    meta.mainProgram = pname;
  };

  launcher = pkgs.writeShellScript "${pname}-launcher" ''
    export MKW_GAME_DIR=${pkgs.lib.escapeShellArg gameDirectory}
    exec ${app}/bin/${pname} "$@"
  '';
in
if gameDirectory == null then
  app
else
  pkgs.symlinkJoin {
    name = "${pname}-${version}";
    paths = [ app ];

    postBuild = ''
      rm "$out/bin/${pname}"
      ln -s ${launcher} "$out/bin/${pname}"
    '';

    meta.mainProgram = pname;
  }
