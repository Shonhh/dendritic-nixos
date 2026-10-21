{ pkgs }:

let
  pname = "eden-nightly";
  version = "2026-10-18-de7e6e01d4";
  release = "v1792353251.de7e6e01d4";
  commit = "de7e6e01d4";

  src = pkgs.fetchurl {
    url = "https://nightly.eden-emu.dev/${release}/Eden-Linux-${commit}-amd64-clang-pgo.AppImage";
    hash = "sha256-QtC4Dhp3o4KaUfky/15Xz4cCrtyZzeh/AWfQczgK+Ug=";
  };

  contents =
    pkgs.runCommand "${pname}-${version}-extracted"
      {
        nativeBuildInputs = [ pkgs.dwarfs ];
      }
      ''
        mkdir -p "$out"
        dwarfsextract --input ${src} --output "$out" --image-offset auto
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
      -e 's|^Exec=.*|Exec=env GAMEMODE_DISABLE=1 eden-nightly %f|' \
      -e '/^TryExec=/d' \
      -e 's|^Name=.*|Name=Eden Nightly|' \
      "$out"/share/applications/*.desktop

    if [ -d "${contents}/usr/share/icons" ]; then
      mkdir -p "$out/share/icons"
      cp -rL ${contents}/usr/share/icons/. "$out/share/icons/"
    fi
  '';
}
