{ ... }:

{
  flake.nixosModules.ryubing =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.ryubing;

      ryubing-canary = pkgs.appimageTools.wrapType2 rec {
        pname = "ryubing-canary";
        version = "1.3.287";

        src = pkgs.fetchurl {
          # Hardcoded the prefix to 'ryujinx-' to match the exact file name on their server
          url = "https://git.ryujinx.app/Ryubing/Canary/releases/download/${version}/ryujinx-canary-${version}-x64.AppImage";

          hash = "sha256-rWl0iGyielfVk4II2KobLNa6lxHhLxDyMU5lWl/+A9o=";
        };

        # INJECT MISSING HOST LIBRARIES HERE
        extraPkgs =
          pkgs: with pkgs; [
            icu
            udev
          ];

        extraInstallCommands =
          let
            contents = pkgs.appimageTools.extract { inherit pname version src; };
          in
          ''
            install -m 444 -D ${contents}/*.desktop -t $out/share/applications

            sed -i 's|^Exec=.*|Exec=env GAMEMODE_DISABLE=1 ryubing-canary %f|' $out/share/applications/*.desktop

            if [ -d "${contents}/usr/share/icons" ]; then
              cp -r ${contents}/usr/share/icons $out/share
            fi
          '';
      };
    in
    {
      options.mySystem.apps.ryubing.enable = lib.mkEnableOption "Switch 1 Emulator";

      config = lib.mkIf cfg.enable {
        # Using home-manager to match your earlier configurations,
        # but environment.systemPackages works perfectly here too!
        home-manager.users.shonh.home.packages = [
          ryubing-canary
        ];
      };
    };
}
