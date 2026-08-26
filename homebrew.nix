{ user, ... }:

{
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
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

      # Local AI & Model Tooling
      "ollama"
      "mlx-lm"
      "llmfit"
      "pi-coding-agent"
    ];

    casks = [
      # AI & Terminals
      "antigravity-cli"
      "ghostty@tip"

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
