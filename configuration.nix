{ user, ... }:

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

  # Gaming network optimization: Disable AWDL (AirDrop) on boot for lower Wi-Fi jitter
  launchd.daemons.disable-awdl = {
    command = "/sbin/ifconfig awdl0 down";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
    };
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;                          # fast key repeat
      InitialKeyRepeat = 15;                  # short delay before repeat
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
    };
  };
}
