{ user, ... }:

{
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];

    brews = [
      # Core Tools & Multiplexer
      "herdr"
      "gh"
      "uv"
      "go"
      "dotnet"
      "ffmpeg"
      "tlrc"
      "shellcheck"

      # Battery & Hardware CLI
      "battery"

      # Local AI & Model Tooling
      "ollama"
      "mlx-lm"
      "llmfit"
      "pi-coding-agent"
    ];

    casks = [
      # AI & Terminals
      "antigravity-cli"
      "ghostty"

      # Development & Editors
      "visual-studio-code"
      "orbstack"
      "yaak"

      # Game Dev, 3D & Music
      "godot"
      "unity-hub"
      "blender"
      "bitwig-studio"
      "obs"
      "vlc"

      # Gaming, Battery & Peripherals
      "league-of-legends"
      "nvidia-geforce-now"
      "steam"
      "epic-games"
      "linearmouse"
      "betterdisplay"
      "aldente"
      "stats"
      "app-tamer"

      # Browsers, Notes & Communication
      "google-chrome"
      "zen"
      "raycast"
      "obsidian"
      "discord"
      "whatsapp"
      "telegram"
      "qbittorrent"
    ];
  };
}
