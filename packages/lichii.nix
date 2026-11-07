{ pkgs }:

let
  pname = "lichii";
  version = "build-75";

  src = pkgs.fetchurl {
    url = "https://github.com/zortos293/Lichii/releases/download/${version}/lichii-linux-x86_64-pgo.AppImage";
    hash = "sha256-dFmlDb8WQY5rXTyrYecKhuYOTX1HkoO90/guADWHVH8=";
  };

  contents =
    pkgs.runCommand "${pname}-${version}-extracted"
      {
        nativeBuildInputs = [
          pkgs.dwarfs
          pkgs.appimageTools.appimage-exec
        ];
      }
      ''
        mkdir -p "$out"

        if dwarfsextract --input ${src} --output "$out" --image-offset auto; then
          echo "Extracted DwarFS AppImage"
        else
          rm -rf "$out"
          appimage-exec.sh -x "$out" ${src}
        fi

        test -x "$out/AppRun"
        chmod -R u+w "$out"
      '';
in
pkgs.appimageTools.wrapAppImage {
  inherit pname version;
  src = contents;

  extraPkgs =
    pkgs: with pkgs; [
      icu
      udev
    ];

  extraInstallCommands = ''
    install -m 444 -D ${contents}/*.desktop -t "$out/share/applications"

    sed -i \
      -e 's|^Exec=.*|Exec=env GAMEMODE_DISABLE=1 lichii %f|' \
      -e '/^TryExec=/d' \
      -e 's|^Name=.*|Name=Lichii|' \
      "$out"/share/applications/*.desktop

    if [ -d "${contents}/usr/share/icons" ]; then
      mkdir -p "$out/share/icons"
      cp -rL ${contents}/usr/share/icons/. "$out/share/icons/"
    fi
  '';

  meta.mainProgram = "lichii";
}
