{ ... }:

{
  flake.nixosModules.zoom =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.mySystem.apps.zoom;

      zoomLauncher = pkgs.writeShellScript "zoom-camera-launcher" ''
        exec ${pkgs.bubblewrap}/bin/bwrap \
          --dev-bind / / \
          --dev-bind ${lib.escapeShellArg cfg.cameraDevice} /dev/video0 \
          -- ${pkgs.zoom-us}/bin/zoom "$@"
      '';

      zoomPackage =
        if cfg.cameraDevice == null then
          pkgs.zoom-us
        else
          pkgs.symlinkJoin {
            name = "zoom-with-camera-mapping";
            paths = [ pkgs.zoom-us ];

            postBuild = ''
              rm "$out/bin/zoom"
              ln -s ${zoomLauncher} "$out/bin/zoom"

              # Make application-menu launches use the same wrapper.
              for desktop in ${pkgs.zoom-us}/share/applications/*.desktop; do
                target="$out/share/applications/$(basename "$desktop")"
                rm "$target"
                sed -E \
                  -e "s|^Exec=[^ ]+|Exec=$out/bin/zoom|" \
                  -e "s|^TryExec=.*|TryExec=$out/bin/zoom|" \
                  "$desktop" > "$target"
              done
            '';
          };
    in
    {
      options.mySystem.apps.zoom = {
        enable = lib.mkEnableOption "Zoom-US Application";

        scaleFactor = lib.mkOption {
          type = lib.types.int;
          default = 1;
          description = "Adjustment to the X11 Zoom Scaling";
        };

        cameraDevice = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Camera device to expose to Zoom as /dev/video0.";
        };
      };

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh.home = {
          packages = [ zoomPackage ];

          file.".config/zoomus.conf".text = ''
            [General]
            ScaleFactor=${toString cfg.scaleFactor}
          '';
        };
      };
    };
}
