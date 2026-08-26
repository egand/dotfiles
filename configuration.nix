{ pkgs, user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;

  # Security: Touch ID for sudo & passwordless darwin-rebuild for automated background upgrades
  security.pam.services.sudo_local.touchIdAuth = true;
  security.sudo.extraConfig = ''
    ${user} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';

  # Fonts management for macOS GUI applications (installed into /Library/Fonts)
  fonts.packages = with pkgs; [
    nerd-fonts.blex-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

  # Gaming network optimization: Disable AWDL (AirDrop) on boot for lower Wi-Fi jitter
  launchd.daemons.disable-awdl = {
    command = "/sbin/ifconfig awdl0 down";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
    };
  };

  # Daily automatic background system upgrade (Homebrew + Nix Flakes) at 03:00 AM
  # Configured as a user agent so it runs under the user's session with correct HOME and permissions
  launchd.user.agents.daily-system-upgrade = {
    command = "/Users/${user}/.dotfiles/scripts/system-upgrade.sh";
    serviceConfig = {
      StartCalendarInterval = [
        { Hour = 3; Minute = 0; }
      ];
      StandardErrorPath = "/tmp/daily-system-upgrade.err.log";
      StandardOutPath = "/tmp/daily-system-upgrade.out.log";
    };
  };

  # Launch OpenSuperWhisper automatically on graphical desktop login
  launchd.user.agents.opensuperwhisper = {
    command = "/Applications/OpenSuperWhisper.app/Contents/MacOS/OpenSuperWhisper";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      LimitLoadToSessionType = [ "Aqua" ];
      ProcessType = "Interactive";
    };
  };

  # Power Management activation script (Display Sleep & battery optimization)
  system.activationScripts.postActivation.text = ''
    # Optimize sleep timers (battery: 10m display sleep, AC: 15m display sleep)
    pmset -b displaysleep 10 disksleep 10 sleep 15
    pmset -c displaysleep 15 disksleep 10 sleep 30
  '';

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;                          # fast key repeat
      InitialKeyRepeat = 20;                  # delay before repeat (~300ms)
      ApplePressAndHoldEnabled = false;       # enable key repeat in Vim/Neovim (no accent popup)
      _HIHideMenuBar = true;                  # auto-hide the menu bar
      AppleShowAllExtensions = true;

      # Text substitutions disabled for clean coding
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # Dialogs
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      "com.apple.sound.beep.feedback" = 0;   # mute volume change beep
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;                   # instant dock popup
      autohide-time-modifier = 0.0;
      show-recents = false;                   # clean dock without recent apps
      mru-spaces = false;                     # do not auto-rearrange Spaces
    };

    finder = {
      FXPreferredViewStyle = "Nlsv";          # list view by default
      CreateDesktop = false;                  # clean desktop (hide desktop icons)
      AppleShowAllFiles = true;               # show hidden files
      ShowPathbar = true;                     # show breadcrumb path bar
      ShowStatusBar = true;                   # show status bar
      _FXSortFoldersFirst = true;             # keep folders on top
      FXDefaultSearchScope = "SCcf";          # search current folder by default
      FXEnableExtensionChangeWarning = false; # no extension change warning
      FXRemoveOldTrashItems = true;          # auto-empty trash after 30 days
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = false;
    };

    screensaver = {
      askForPassword = true;                  # lock immediately on display sleep/screensaver
      askForPasswordDelay = 0;
    };

    trackpad = {
      Clicking = true;                        # tap to click
    };

    screencapture = {
      location = "~/Downloads";
      disable-shadow = true;                  # clean screenshots without dropshadows
      type = "png";
    };

    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      "ru.starmel.OpenSuperWhisper" = {
        hasCompletedOnboarding = true;
        selectedEngine = "whisper";
        whisperLanguage = "en";
        modifierOnlyHotkey = "rightOption";
        startHiddenInMenuBar = true;
        autoPasteTranscription = true;
        KeyboardShortcuts_toggleRecord = "{\"carbonKeyCode\":50,\"carbonModifiers\":2048}";
        KeyboardShortcuts_escape = "{\"carbonKeyCode\":53,\"carbonModifiers\":0}";
      };
    };
  };
}
