{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Core CLI
    ripgrep
    fd
    fzf
    jq
    lazygit
    neovim
    zoxide
    eza
    bat
    delta

    # Fonts
    nerd-fonts.blex-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      bindkey '^f' autosuggest-accept

      # --- Zoxide (Smarter cd) ---
      if command -v zoxide &> /dev/null; then
        eval "$(zoxide init zsh)"
      fi

      # --- AWDL (AirDrop) Toggle for Low-Latency Gaming ---
      awdl() {
        case "$1" in
          on|enable)
            sudo ifconfig awdl0 up
            echo "📡 AWDL enabled (AirDrop/AirPlay active)"
            ;;
          off|disable)
            sudo ifconfig awdl0 down
            echo "🎮 AWDL disabled (Low-Latency Gaming Mode active)"
            ;;
          status)
            if ifconfig awdl0 2>/dev/null | grep -q "status: active"; then
              echo "📡 AWDL: Active (AirDrop ON)"
            else
              echo "🎮 AWDL: Inactive (Gaming Mode ON)"
            fi
            ;;
          toggle)
            if ifconfig awdl0 2>/dev/null | grep -q "status: active"; then
              sudo ifconfig awdl0 down
              echo "🎮 AWDL disabled (Gaming Mode ON)"
            else
              sudo ifconfig awdl0 up
              echo "📡 AWDL enabled (AirDrop ON)"
            fi
            ;;
          *)
            echo "Usage: awdl {on|off|status|toggle}"
            ;;
        esac
      }

      _awdl_completion() {
        local -a commands=(
          "on:Enable AWDL/AirDrop"
          "off:Disable AWDL (Gaming mode)"
          "status:Check current AWDL status"
          "toggle:Toggle between active and inactive"
        )
        _describe 'command' commands
      }
      compdef _awdl_completion awdl

      # --- Homebrew Auto-Sync Wrapper ---
      # Automatically captures brew install / uninstall into ~/.dotfiles/homebrew.nix
      brew() {
        if [[ "$1" == "install" || "$1" == "uninstall" || "$1" == "remove" ]]; then
          command brew "$@"
          local exit_code=$?
          if [[ $exit_code -eq 0 && -f "$HOME/.dotfiles/scripts/brew-sync.sh" ]]; then
            echo "🔄 Updating ~/.dotfiles/homebrew.nix..."
            "$HOME/.dotfiles/scripts/brew-sync.sh" --quiet
          fi
          return $exit_code
        else
          command brew "$@"
        fi
      }

      # Path additions for Antigravity tools
      export PATH="$HOME/.antigravity/antigravity/bin:$HOME/.local/bin:$PATH"
    '';

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";

      # Modern CLI replacements
      ls = "eza --icons";
      ll = "eza -la --icons --git";
      tree = "eza --tree --icons";
      cat = "bat";

      # Antigravity CLI
      ag = "antigravity";
      aga = "antigravity --auto";

      # Git
      g = "git";
      gst = "git status";
      gaa = "git add -A";
      gc = "git commit -m";
      gp = "git push";
      gl = "git pull";
      sw = "git switch";
      lg = "lazygit";

      # Rebuild & Upgrade system
      rb = "~/.dotfiles/rebuild.sh";
      upgrade = "~/.dotfiles/scripts/system-upgrade.sh";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
      };
    };
  };

  # Edit-in-place: Symlink live configuration files directly into ~/.config
  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # AI Agent instructions
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".gemini/config/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  # Antigravity CLI configurations
  home.file.".gemini/antigravity-cli/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.gemini/antigravity-cli/settings.json";
  home.file.".gemini/antigravity-cli/statusline.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.gemini/antigravity-cli/statusline.sh";

  # Pi Agent configurations
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";
}
