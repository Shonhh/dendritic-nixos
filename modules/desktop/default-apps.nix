{ ... }:
{
  flake.nixosModules.default-apps =
    { config, lib, ... }:
    let
      cfg = config.mySystem.desktop.default-apps;
      apps = config.mySystem.apps;
      commands = config.mySystem.desktop.commands;

      browserTypes = [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "application/pdf"
      ];

      textTypes = [
        "text/plain"
        "text/markdown"
        "text/x-nix"
        "application/json"
        "application/toml"
        "application/yaml"
        "text/yaml"
      ];

      folderTypes = [ "inode/directory" ];
      mailTypes = [ "x-scheme-handler/mailto" ];

      entry = name: exec: mimeType: {
        inherit name exec mimeType;
        noDisplay = true;
        terminal = false;
      };

      defaults = desktopId: mimeTypes: lib.genAttrs mimeTypes (_: lib.mkDefault [ desktopId ]);
    in
    {
      options.mySystem.desktop.default-apps.enable = lib.mkEnableOption "Desktop file associations";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh = {
          xdg.enable = true;

          xdg.desktopEntries =
            lib.optionalAttrs apps.helium.enable {
              personal-browser = entry "Default browser" "${commands.browser} %U" browserTypes;
            }
            // lib.optionalAttrs apps.zed.enable {
              personal-editor = entry "Default text editor" "${commands.codeEditor} %F" textTypes;
            }
            // lib.optionalAttrs apps.thunar.enable {
              personal-files = entry "Default file manager" "${commands.fileManager} %U" folderTypes;
            }
            // lib.optionalAttrs apps.thunderbird.enable {
              personal-mail = entry "Default mail client" "thunderbird %u" mailTypes;
            };

          xdg.mimeApps = {
            enable = true;

            defaultApplications =
              lib.optionalAttrs apps.helium.enable (defaults "personal-browser.desktop" browserTypes)
              // lib.optionalAttrs apps.zed.enable (defaults "personal-editor.desktop" textTypes)
              // lib.optionalAttrs apps.thunar.enable (defaults "personal-files.desktop" folderTypes)
              // lib.optionalAttrs apps.thunderbird.enable (defaults "personal-mail.desktop" mailTypes);
          };
        };
      };
    };
}
