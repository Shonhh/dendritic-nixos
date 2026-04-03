{ ... }:

{
  flake.nixosModules.noctalia =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.mySystem.desktop.noctalia;
    in
    {
      options.mySystem.desktop.noctalia.enable = lib.mkEnableOption "Noctalia Shell";

      config = lib.mkIf cfg.enable {
        # Skip local compilation
        nix.settings = {
          extra-substituters = [ "https://noctalia.cachix.org" ];
          extra-trusted-public-keys = [
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
        };

        # Noctalia needs these background services to read battery and hardware data
        mySystem.system.power-management.enable = true;
        mySystem.hardware.bluetooth.enable = true;

        # Noctalia needs a secret service
        services.gnome.gnome-keyring.enable = true;

        # I2C Hardware bus for brightness controls
        hardware.i2c.enable = true;
        environment.systemPackages = [ pkgs.ddcutil ];

        home-manager.users.shonh = {
          imports = [ inputs.noctalia.homeModules.default ];

          # enable and customize noctalia
          programs.noctalia-shell = {
            enable = true;

            settings = {
              settingsVersion = 57;
              bar = {
                barType = "simple";
                position = "top";
                monitors = [ ];
                density = "default";
                showOutline = false;
                showCapsule = true;
                capsuleColorKey = "none";
                widgetSpacing = 6;
                contentPadding = 2;
                fontScale = 1;
                enableExclusionZoneInset = true;
                useSeparateOpacity = false;
                floating = false;
                marginVertical = 4;
                marginHorizontal = 4;
                frameThickness = 8;
                frameRadius = 12;
                outerCorners = false;
                hideOnOverview = false;
                displayMode = "always_visible";
                autoHideDelay = 500;
                autoShowDelay = 150;
                showOnWorkspaceSwitch = true;
                widgets = {
                  left = [
                    {
                      colorizeDistroLogo = false;
                      colorizeSystemIcon = "none";
                      customIconPath = "";
                      enableColorization = true;
                      icon = "noctalia";
                      id = "ControlCenter";
                      useDistroLogo = true;
                    }
                    {
                      compactMode = false;
                      diskPath = "/";
                      iconColor = "none";
                      id = "SystemMonitor";
                      showCpuCores = false;
                      showCpuFreq = false;
                      showCpuTemp = true;
                      showCpuUsage = true;
                      showDiskAvailable = false;
                      showDiskUsage = false;
                      showDiskUsageAsPercent = false;
                      showGpuTemp = false;
                      showLoadAverage = false;
                      showMemoryAsPercent = false;
                      showMemoryUsage = true;
                      showNetworkStats = false;
                      showSwapUsage = false;
                      textColor = "none";
                      useMonospaceFont = true;
                      usePadding = true;
                    }
                    {
                      compactMode = false;
                      hideMode = "hidden";
                      hideWhenIdle = false;
                      id = "MediaMini";
                      maxWidth = 145;
                      panelShowAlbumArt = true;
                      scrollingMode = "hover";
                      showAlbumArt = true;
                      showArtistFirst = true;
                      showProgressRing = true;
                      showVisualizer = false;
                      textColor = "none";
                      useFixedWidth = false;
                      visualizerType = "linear";
                    }
                  ];
                  center = [
                    {
                      characterCount = 10;
                      colorizeIcons = false;
                      emptyColor = "secondary";
                      enableScrollWheel = true;
                      focusedColor = "primary";
                      followFocusedScreen = false;
                      fontWeight = "bold";
                      groupedBorderOpacity = 1;
                      hideUnoccupied = true;
                      iconScale = 0.8;
                      id = "Workspace";
                      labelMode = "name";
                      occupiedColor = "secondary";
                      pillSize = 0.6;
                      showApplications = false;
                      showApplicationsHover = false;
                      showBadge = true;
                      showLabelsOnlyWhenOccupied = true;
                      unfocusedIconsOpacity = 1;
                    }
                  ];
                  right = [
                    {
                      blacklist = [ ];
                      chevronColor = "none";
                      colorizeIcons = false;
                      drawerEnabled = true;
                      hidePassive = false;
                      id = "Tray";
                      pinned = [ ];
                    }
                    {
                      displayMode = "onhover";
                      iconColor = "none";
                      id = "Network";
                      textColor = "none";
                    }
                    {
                      deviceNativePath = "__default__";
                      displayMode = "graphic";
                      hideIfIdle = false;
                      hideIfNotDetected = true;
                      id = "Battery";
                      showNoctaliaPerformance = false;
                      showPowerProfiles = true;
                    }
                    {
                      displayMode = "onhover";
                      iconColor = "none";
                      id = "Volume";
                      middleClickCommand = "pwvucontrol || pavucontrol";
                      textColor = "none";
                    }
                    {
                      displayMode = "onhover";
                      iconColor = "none";
                      id = "Bluetooth";
                      textColor = "none";
                    }
                    {
                      applyToAllMonitors = false;
                      displayMode = "onhover";
                      iconColor = "none";
                      id = "Brightness";
                      textColor = "none";
                    }
                    {
                      hideWhenZero = false;
                      hideWhenZeroUnread = false;
                      iconColor = "none";
                      id = "NotificationHistory";
                      showUnreadBadge = true;
                      unreadBadgeColor = "primary";
                    }
                    {
                      clockColor = "none";
                      customFont = "";
                      formatHorizontal = "h:mm AP";
                      formatVertical = "HH mm - MM dd";
                      id = "Clock";
                      tooltipFormat = "HH:mm ddd, MMM dd";
                      useCustomFont = false;
                    }
                    {
                      iconColor = "error";
                      id = "SessionMenu";
                    }
                  ];
                };
                mouseWheelAction = "none";
                reverseScroll = false;
                mouseWheelWrap = true;
                middleClickAction = "none";
                middleClickFollowMouse = false;
                middleClickCommand = "";
                rightClickAction = "controlCenter";
                rightClickFollowMouse = true;
                rightClickCommand = "";
                screenOverrides = [ ];
              };
              general = {
                avatarImage = "/home/shonh/.face";
                dimmerOpacity = 0.2;
                showScreenCorners = false;
                forceBlackScreenCorners = false;
                scaleRatio = 1;
                radiusRatio = 1;
                iRadiusRatio = 1;
                boxRadiusRatio = 1;
                screenRadiusRatio = 1;
                animationSpeed = 1;
                animationDisabled = false;
                compactLockScreen = false;
                lockScreenAnimations = false;
                lockOnSuspend = true;
                showSessionButtonsOnLockScreen = true;
                showHibernateOnLockScreen = false;
                enableLockScreenMediaControls = false;
                enableShadows = true;
                enableBlurBehind = true;
                shadowDirection = "bottom_right";
                shadowOffsetX = 2;
                shadowOffsetY = 3;
                language = "";
                allowPanelsOnScreenWithoutBar = true;
                showChangelogOnStartup = true;
                telemetryEnabled = false;
                enableLockScreenCountdown = true;
                lockScreenCountdownDuration = 5000;
                autoStartAuth = false;
                allowPasswordWithFprintd = false;
                clockStyle = "custom";
                clockFormat = "hh\nmm";
                passwordChars = false;
                lockScreenMonitors = [ ];
                lockScreenBlur = 0;
                lockScreenTint = 0;
                keybinds = {
                  keyUp = [
                    "Up"
                  ];
                  keyDown = [
                    "Down"
                  ];
                  keyLeft = [
                    "Left"
                  ];
                  keyRight = [
                    "Right"
                  ];
                  keyEnter = [
                    "Return"
                    "Enter"
                  ];
                  keyEscape = [
                    "Esc"
                  ];
                  keyRemove = [
                    "Del"
                  ];
                };
                reverseScroll = false;
              };
              ui = {
                fontDefault = "Lato";
                fontFixed = "${config.stylix.fonts.monospace.name}";
                fontDefaultScale = 1;
                fontFixedScale = 1;
                tooltipsEnabled = true;
                scrollbarAlwaysVisible = true;
                boxBorderEnabled = true;
                translucentWidgets = true;
                panelsAttachedToBar = true;
                settingsPanelMode = "attached";
                settingsPanelSideBarCardStyle = false;
              };
              location = {
                name = "Austin, TX";
                weatherEnabled = true;
                weatherShowEffects = false;
                useFahrenheit = true;
                use12hourFormat = true;
                showWeekNumberInCalendar = false;
                showCalendarEvents = true;
                showCalendarWeather = true;
                analogClockInCalendar = false;
                firstDayOfWeek = -1;
                hideWeatherTimezone = false;
                hideWeatherCityName = false;
              };
              calendar = {
                cards = [
                  {
                    enabled = true;
                    id = "calendar-header-card";
                  }
                  {
                    enabled = true;
                    id = "calendar-month-card";
                  }
                  {
                    enabled = true;
                    id = "weather-card";
                  }
                ];
              };
              wallpaper = {
                enabled = true;
                overviewEnabled = false;
                directory = "/home/shonh/nixos/wallpapers";
                monitorDirectories = [ ];
                enableMultiMonitorDirectories = false;
                showHiddenFiles = false;
                viewMode = "single";
                setWallpaperOnAllMonitors = true;
                fillMode = "crop";
                fillColor = "#000000";
                useSolidColor = false;
                solidColor = "#1a1a2e";
                automationEnabled = false;
                wallpaperChangeMode = "random";
                randomIntervalSec = 300;
                transitionDuration = 1500;
                transitionType = "random";
                skipStartupTransition = true;
                transitionEdgeSmoothness = 0.05;
                panelPosition = "follow_bar";
                hideWallpaperFilenames = false;
                overviewBlur = 0.4;
                overviewTint = 0.6;
                useWallhaven = false;
                wallhavenQuery = "";
                wallhavenSorting = "relevance";
                wallhavenOrder = "desc";
                wallhavenCategories = "111";
                wallhavenPurity = "100";
                wallhavenRatios = "";
                wallhavenApiKey = "";
                wallhavenResolutionMode = "atleast";
                wallhavenResolutionWidth = "";
                wallhavenResolutionHeight = "";
                sortOrder = "name";
                favorites = [ ];
              };
              appLauncher = {
                enableClipboardHistory = false;
                autoPasteClipboard = false;
                enableClipPreview = true;
                clipboardWrapText = true;
                clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
                clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
                position = "center";
                pinnedApps = [ ];
                useApp2Unit = false;
                sortByMostUsed = true;
                terminalCommand = "foot";
                customLaunchPrefixEnabled = true;
                customLaunchPrefix = "uwsm-app --";
                viewMode = "list";
                showCategories = false;
                iconMode = "tabler";
                showIconBackground = false;
                enableSettingsSearch = true;
                enableWindowsSearch = true;
                enableSessionSearch = true;
                ignoreMouseInput = false;
                screenshotAnnotationTool = "";
                overviewLayer = false;
                density = "default";
              };
              controlCenter = {
                position = "close_to_bar_button";
                diskPath = "/";
                shortcuts = {
                  left = [
                    {
                      id = "Network";
                    }
                    {
                      id = "Bluetooth";
                    }
                    {
                      id = "WallpaperSelector";
                    }
                    {
                      id = "NoctaliaPerformance";
                    }
                  ];
                  right = [
                    {
                      id = "Notifications";
                    }
                    {
                      id = "PowerProfile";
                    }
                    {
                      id = "KeepAwake";
                    }
                    {
                      id = "NightLight";
                    }
                  ];
                };
                cards = [
                  {
                    enabled = true;
                    id = "profile-card";
                  }
                  {
                    enabled = true;
                    id = "shortcuts-card";
                  }
                  {
                    enabled = true;
                    id = "audio-card";
                  }
                  {
                    enabled = false;
                    id = "brightness-card";
                  }
                  {
                    enabled = true;
                    id = "weather-card";
                  }
                  {
                    enabled = true;
                    id = "media-sysmon-card";
                  }
                ];
              };
              systemMonitor = {
                cpuWarningThreshold = 80;
                cpuCriticalThreshold = 90;
                tempWarningThreshold = 80;
                tempCriticalThreshold = 90;
                gpuWarningThreshold = 80;
                gpuCriticalThreshold = 90;
                memWarningThreshold = 80;
                memCriticalThreshold = 90;
                swapWarningThreshold = 80;
                swapCriticalThreshold = 90;
                diskWarningThreshold = 80;
                diskCriticalThreshold = 90;
                diskAvailWarningThreshold = 20;
                diskAvailCriticalThreshold = 10;
                batteryWarningThreshold = 20;
                batteryCriticalThreshold = 5;
                enableDgpuMonitoring = false;
                warningColor = "";
                criticalColor = "";
                externalMonitor = "foot btop || resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
              };
              noctaliaPerformance = {
                disableWallpaper = true;
                disableDesktopWidgets = true;
              };
              dock = {
                enabled = false;
                position = "bottom";
                displayMode = "auto_hide";
                dockType = "floating";
                floatingRatio = 1;
                size = 1;
                onlySameOutput = true;
                monitors = [ ];
                pinnedApps = [ ];
                colorizeIcons = false;
                showLauncherIcon = false;
                launcherPosition = "end";
                launcherIconColor = "none";
                pinnedStatic = false;
                inactiveIndicators = false;
                groupApps = false;
                groupContextMenuMode = "extended";
                groupClickAction = "cycle";
                groupIndicatorStyle = "dots";
                deadOpacity = 0.6;
                animationSpeed = 1;
                sitOnFrame = false;
                showDockIndicator = false;
                indicatorThickness = 3;
                indicatorColor = "primary";
                indicatorOpacity = 0.6;
              };
              network = {
                wifiEnabled = true;
                airplaneModeEnabled = false;
                bluetoothRssiPollingEnabled = false;
                bluetoothRssiPollIntervalMs = 60000;
                networkPanelView = "wifi";
                wifiDetailsViewMode = "grid";
                bluetoothDetailsViewMode = "grid";
                bluetoothHideUnnamedDevices = false;
                disableDiscoverability = false;
                bluetoothAutoConnect = true;
              };
              sessionMenu = {
                enableCountdown = true;
                countdownDuration = 10000;
                position = "center";
                showHeader = true;
                showKeybinds = true;
                largeButtonsStyle = true;
                largeButtonsLayout = "single-row";
                powerOptions = [
                  {
                    action = "lock";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "1";
                  }
                  {
                    action = "suspend";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "2";
                  }
                  {
                    action = "reboot";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "3";
                  }
                  {
                    action = "logout";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "4";
                  }
                  {
                    action = "shutdown";
                    command = "";
                    countdownEnabled = true;
                    enabled = true;
                    keybind = "5";
                  }
                  {
                    action = "hibernate";
                    command = "";
                    countdownEnabled = true;
                    enabled = false;
                    keybind = "";
                  }
                  {
                    action = "rebootToUefi";
                    command = "";
                    countdownEnabled = true;
                    enabled = false;
                    keybind = "";
                  }
                  {
                    action = "userspaceReboot";
                    command = "";
                    countdownEnabled = true;
                    enabled = false;
                    keybind = "";
                  }
                ];
              };
              notifications = {
                enabled = true;
                enableMarkdown = false;
                density = "compact";
                monitors = [ ];
                location = "top_right";
                overlayLayer = true;
                respectExpireTimeout = false;
                lowUrgencyDuration = 2;
                normalUrgencyDuration = 7;
                criticalUrgencyDuration = 14;
                clearDismissed = true;
                saveToHistory = {
                  low = true;
                  normal = true;
                  critical = true;
                };
                sounds = {
                  enabled = false;
                  volume = 0.5;
                  separateSounds = false;
                  criticalSoundFile = "";
                  normalSoundFile = "";
                  lowSoundFile = "";
                  excludedApps = "discord,firefox,chrome,chromium,edge";
                };
                enableMediaToast = true;
                enableKeyboardLayoutToast = true;
                enableBatteryToast = true;
              };
              osd = {
                enabled = true;
                location = "top_right";
                autoHideMs = 1000;
                overlayLayer = true;
                enabledTypes = [
                  0
                  1
                  2
                  3
                ];
                monitors = [ ];
              };
              audio = {
                volumeStep = 5;
                volumeOverdrive = false;
                spectrumFrameRate = 30;
                visualizerType = "linear";
                mprisBlacklist = [ ];
                preferredPlayer = "";
                volumeFeedback = false;
                volumeFeedbackSoundFile = "";
              };
              brightness = {
                brightnessStep = 5;
                enforceMinimum = true;
                enableDdcSupport = true;
                backlightDeviceMappings = [ ];
              };
              colorSchemes = {
                useWallpaperColors = false;
                predefinedScheme = "Noctalia (default)";
                darkMode = true;
                schedulingMode = "off";
                manualSunrise = "06:30";
                manualSunset = "18:30";
                generationMethod = "tonal-spot";
                monitorForColors = "";
              };
              templates = {
                activeTemplates = [ ];
                enableUserTheming = false;
              };
              nightLight = {
                enabled = false;
                forced = false;
                autoSchedule = true;
                nightTemp = "4000";
                dayTemp = "6500";
                manualSunrise = "06:30";
                manualSunset = "18:30";
              };
              hooks = {
                enabled = false;
                wallpaperChange = "";
                darkModeChange = "";
                screenLock = "";
                screenUnlock = "";
                performanceModeEnabled = "";
                performanceModeDisabled = "";
                startup = "";
                session = "";
              };
              plugins = {
                autoUpdate = false;
              };
              idle = {
                enabled = true;
                screenOffTimeout = 600;
                lockTimeout = 660;
                suspendTimeout = 1800;
                fadeDuration = 5;
                screenOffCommand = "";
                lockCommand = "";
                suspendCommand = "";
                resumeScreenOffCommand = "";
                resumeLockCommand = "";
                resumeSuspendCommand = "";
                customCommands = "[]";
              };
              desktopWidgets = {
                enabled = false;
                overviewEnabled = true;
                gridSnap = false;
                gridSnapScale = false;
                monitorWidgets = [ ];
              };
            };
          };

          # Screenshot Plugin Dependencies
          home.packages = with pkgs; [
            grim
            imagemagick
            wl-clipboard
          ];
        };
      };
    };
}
