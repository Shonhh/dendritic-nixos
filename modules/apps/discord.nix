{ ... }:

{
  flake.nixosModules.discord =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.mySystem.apps.discord;
    in
    {
      options.mySystem.apps.discord.enable = lib.mkEnableOption "Discord (Nixcord)";

      config = lib.mkIf cfg.enable {
        home-manager.users.shonh = {
          imports = [ inputs.nixcord.homeModules.nixcord ];
          stylix.targets.nixcord.enable = true;

          # Let Nixcord supply the CSS; replace the empty writable file.
          home.file."${config.home-manager.users.shonh.xdg.configHome}/vesktop/settings/quickCss.css".force =
            true;

          programs.nixcord = {
            enable = true;
            vesktop.enable = true;

            # Silences the warning about the standard Discord client missing a modloader
            discord.vencord.enable = true;

            quickCss =
              let
                palette = config.lib.stylix.colors;

                adjust =
                  saturation: brightness: hex:
                  let
                    channels = map
                      (offset: lib.fromHexString (builtins.substring offset 2 hex))
                      [ 0 2 4 ];

                    lowest = lib.foldl' lib.min 255 channels;
                    highest = lib.foldl' lib.max 0 channels;
                    midpoint = (lowest + highest) / 2.0;

                    channelHex =
                      channel:
                      let
                        saturated = midpoint + (channel - midpoint) * saturation;
                        value = builtins.floor (saturated * brightness);
                        clamped = lib.max 0 (lib.min 255 value);
                      in
                      lib.fixedWidthString 2 "0" (lib.toHexString clamped);
                  in
                  "#" + lib.concatMapStrings channelHex channels;

                background = adjust 1.0 0.60 palette.base00;
                surface = adjust 1.0 0.70 palette.base01;
                raised = adjust 1.0 0.75 palette.base02;

                foreground = adjust 1.0 1.12 palette.base05;
                secondary = adjust 1.0 1.12 palette.base04;

                accentSource = adjust 1.75 1.12 palette.base0E;
                accent = "oklch(from ${accentSource} l c calc(h - 55))";
                accentHover =
                  "oklch(from ${accentSource} calc(l + 0.05) c calc(h - 55))";

                onAccent = background;
              in
              ''
                .theme-dark,
                .theme-darker,
                .theme-midnight {
                  /* Main conversation, sidebars, and title bar. */
                  --background-primary: ${background} !important;
                  --background-secondary: ${surface} !important;
                  --background-secondary-alt: ${surface} !important;
                  --background-tertiary: ${background} !important;
                  --background-floating: ${surface} !important;

                  /* Discord's newer surface names. */
                  --background-base-lowest: ${background} !important;
                  --background-base-lower: ${background} !important;
                  --background-base-low: ${surface} !important;
                  --background-surface-high: ${surface} !important;
                  --background-surface-higher: ${raised} !important;
                  --background-surface-highest: ${raised} !important;

                  /* Text and navigation controls. */
                  --text-normal: ${foreground} !important;
                  --text-default: ${foreground} !important;
                  --text-primary: ${foreground} !important;
                  --text-muted: ${secondary} !important;
                  --text-subtle: ${secondary} !important;
                  --header-primary: ${foreground} !important;
                  --header-secondary: ${secondary} !important;
                  --channels-default: ${secondary} !important;

                  --interactive-normal: ${secondary} !important;
                  --interactive-hover: ${foreground} !important;
                  --interactive-active: ${foreground} !important;
                  --interactive-text-default: ${secondary} !important;
                  --interactive-text-active: ${foreground} !important;
                  --interactive-icon-default: ${secondary} !important;
                  --interactive-icon-active: ${foreground} !important;

                  /* Message composer and search inputs. */
                  --channeltextarea-background: ${surface} !important;
                  --chat-background-default: ${surface} !important;
                  --input-background: ${surface} !important;
                  --input-background-default: ${surface} !important;
                  --textbox-markdown-syntax: ${secondary} !important;

                  /* Purple brand surfaces and controls. */
                  --bg-brand: ${accent} !important;
                  --background-brand: ${accent} !important;
                  --background-accent: ${accent} !important;
                  --control-brand-foreground: ${accent} !important;
                  --brand-500: ${accent} !important;
                  --brand-560: ${accentHover} !important;

                  --button-filled-brand-background: ${accent} !important;
                  --button-filled-brand-background-hover: ${accentHover} !important;
                  --button-filled-brand-text: ${onAccent} !important;

                  --button-brand-background: ${accent} !important;
                  --button-brand-background-hover: ${accentHover} !important;
                  --button-brand-background-active: ${accentHover} !important;

                  /* Positive buttons used by Discord and Vencord. */
                  --button-positive-background: ${accent} !important;
                  --button-positive-background-hover: ${accentHover} !important;
                  --button-positive-background-active: ${accentHover} !important;

                  --button-filled-positive-background: ${accent} !important;
                  --button-filled-positive-background-hover: ${accentHover} !important;
                  --button-filled-positive-text: ${onAccent} !important;

                  --redesign-button-positive-background: ${accent} !important;
                  --redesign-button-positive-text: ${onAccent} !important;
                }

                /* Fallback for the older green button component. */
                #app-mount [class*="lookFilled_"][class*="colorGreen_"] {
                  background-color: ${accent} !important;
                  color: ${onAccent} !important;
                }

                #app-mount [class*="lookFilled_"][class*="colorGreen_"]:hover {
                  background-color: ${accentHover} !important;
                }

                /* Composer background, placeholder, and entered text. */
                [class*="channelTextArea_"] {
                  background: ${surface} !important;
                }

                [class*="channelTextArea_"] [class*="placeholder_"] {
                  color: ${secondary} !important;
                  opacity: 1 !important;
                }

                [class*="channelTextArea_"] [role="textbox"] {
                  color: ${foreground} !important;
                }

                /* Home button: purple tile with a cream Discord logo. */
                #app-mount [data-list-item-id="guildsnav___home"] {
                  background: transparent !important;
                }

                #app-mount [data-list-item-id="guildsnav___home"] [class*="childWrapper"] {
                  background: ${accent} !important;
                  color: ${foreground} !important;
                }

                #app-mount [data-list-item-id="guildsnav___home"]:hover [class*="childWrapper"] {
                  background: ${accentHover} !important;
                  color: ${foreground} !important;
                }

                #app-mount [data-list-item-id="guildsnav___home"] svg,
                #app-mount [data-list-item-id="guildsnav___home"] svg path {
                  color: ${foreground} !important;
                  fill: ${foreground} !important;
                }

                /* Small text badges, including NEW and bot/official labels. */
                #app-mount [class*="textBadge"],
                #app-mount [class*="newBadge"],
                #app-mount [class*="botTag"] {
                  background: ${accent} !important;
                  color: ${onAccent} !important;
                }

                #app-mount [class*="botTag"] svg {
                  color: ${onAccent} !important;
                }
              '';

            config = {
              disableMinSize = true;
              useQuickCss = true;

              plugins = {
                anonymiseFileNames.enable = true;
                betterGifAltText.enable = true;
                betterGifPicker.enable = true;
                betterRoleContext.enable = true;
                betterRoleDot.enable = true;
                betterSessions.enable = true;
                betterSettings.enable = true;
                betterUploadButton.enable = true;
                biggerStreamPreview.enable = true;
                blurNsfw.enable = true; # UPDATED
                callTimer.enable = true;
                clearUrls.enable = true; # UPDATED
                clientTheme.enable = false;
                copyFileContents.enable = true;
                copyUserUrls.enable = true; # UPDATED
                customRpc.enable = true; # UPDATED
                dearrow.enable = true;
                dontRoundMyTimestamps.enable = true;
                fakeNitro.enable = true;
                fixCodeblockGap.enable = true;
                fixImagesQuality.enable = true;
                fixSpotifyEmbeds.enable = true;
                fixYoutubeEmbeds.enable = true;
                # friendsSince.enable = true;
                fullSearchContext.enable = true;
                gameActivityToggle.enable = true;
                imageZoom.enable = true;
                implicitRelationships.enable = true;
                keepCurrentChannel.enable = true;
                memberCount.enable = true;
                mentionAvatars.enable = true;
                messageClickActions.enable = true;
                messageLinkEmbeds.enable = true;
                messageLogger.enable = true;
                noUnblockToJump.enable = true;
                openInApp.enable = true;
                permissionFreeWill.enable = true;
                platformIndicators.enable = true;
                relationshipNotifier.enable = true;
                revealAllSpoilers.enable = true;
                roleColorEverywhere.enable = true;
                serverInfo.enable = true;
                shikiCodeblocks.enable = true;
                showHiddenChannels.enable = true;
                showHiddenThings.enable = true;

                showMeYourName = {
                  enable = true;
                };

                showTimeoutDuration.enable = true;
                sortFriendRequests.enable = true;
                spotifyCrack.enable = true;
                spotifyShareCommands.enable = true;
                typingIndicator.enable = true;
                typingTweaks.enable = true;
                unlockedAvatarZoom.enable = true;
                userVoiceShow.enable = true;
                validReply.enable = true;
                validUser.enable = true;
                volumeBooster.enable = true;
                webScreenShareFixes.enable = true;
                youtubeAdblock.enable = true;
              };
            };
          };
        };
      };
    };
}
