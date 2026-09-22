# dotfiles

Clean, native macOS dotfiles and developer environment management powered by **GNU Stow**, **Homebrew Bundle**, **Mise**, and **Just**.

## What You Get

- **Package Management**: Unified `Brewfile` managing CLI utilities, GUI casks, and Nerd Fonts. A smart, non-destructive shell wrapper in Zsh automatically updates your `Brewfile` whenever you run `brew install` or `brew uninstall`.
- **Polyglot Runtimes (`mise`)**: Language runtimes, SDKs, and build toolchains (Node LTS, Python, Go, Java OpenJDK 21, Gradle, and .NET) are managed cleanly via Mise, preventing system package conflicts and duplicate JDK installs.
- **Symlink Architecture (`stow`)**: GNU Stow organizes configuration files into modular packages under `stow/` mirrored directly into `$HOME`. Any in-place edit in `~/.config/` is immediately tracked in Git.
- **System Settings**: Native `scripts/macos-defaults.sh` for Dark mode, fast key repeat (accent popups disabled for Vim), instant Dock with zero animation delay, Finder list view with breadcrumbs, screenshot location in Downloads, and **all Hot Corners disabled** (preventing accidental Quick Note or Mission Control triggers).
- **Touch ID for Sudo**: Native macOS `/etc/pam.d/sudo_local` configuration with Touch ID authentication (persists across OS updates).
- **Workspace Taxonomy**: `~/Developer/{projects,repos,games,uni,scratch}` created automatically to separate heavy game assets (Godot/Unity/Blender) from fast code repositories.
- **Gaming Optimization (`awdl`)**: Standalone CLI utility (`scripts/awdl`) to toggle Apple Wireless Direct Link (AWDL/AirDrop) on demand (`awdl on|off|status|toggle`) for low-jitter Wi-Fi gaming.
- **Terminal & Multiplexer**: Ghostty (Catppuccin Frappe, IBM Plex Mono / BlexMono Nerd Font) + Herdr (`ctrl+b` keybindings) with native `smart-paste` helper.
- **Launcher & Utilities**: Raycast with tracked `.rayconfig` backup (Ghostty terminal alias, `Cmd+Shift+V` Clipboard History).
- **Editor**: Modular Neovim (Treesitter, LSP, Conform format-on-save, Oil, Snacks, Rose-Pine Moon theme).
- **Shell**: Zsh + Starship prompt, `zoxide` (smart cd), `eza` (ls), `bat` (cat), `delta` (diff), `lazygit`, `direnv`, `mise`, and Antigravity CLI aliases (`ag`, `aga`).
- **AI Integration**: Canonical `AGENTS.md` mirrored via internal relative symlinks to Claude Code, Codex, OpenCode, and Gemini/Antigravity; Antigravity CLI custom status bar and Pi Agent extensions.

---

## Fresh Machine Setup

After a macOS install or reset:

1. Clone this repository to `~/.dotfiles`:
   ```bash
   git clone https://github.com/egand/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```
2. Run the 1-click bootstrap script:
   ```bash
   ./bootstrap.sh
   ```

*The script checks Xcode Command Line Tools, installs Homebrew non-interactively, provisions workspace folders, stows all dotfiles, installs all Brewfile packages and Nerd Fonts, installs Mise runtimes, compiles `smart-paste`, applies macOS system defaults, enables Touch ID for sudo, and opens the Raycast configuration wizard.*

---

## Daily Workflow

### Editing Configurations In Place
Because all configuration files in `$HOME` are live symlinks to `~/.dotfiles/stow/`, you can edit them directly in place:

```bash
nvim ~/.config/ghostty/config  # Directly edits ~/.dotfiles/stow/ghostty/.config/ghostty/config
```

Any modification is immediately visible in `git status` inside `~/.dotfiles`.

### Command Runner (`just`)

Use `just` to manage, update, and synchronize your environment:

```bash
just sync        # Mirror all stow packages to $HOME and link helper binaries
just brew        # Install and update packages from Brewfile
just runtimes    # Install polyglot toolchains declared in mise
just macos       # Re-apply macOS system settings (Dock, Finder, Hot Corners)
just touchid     # Ensure Touch ID for sudo is active
just folders     # Re-create Developer workspace taxonomy
just upgrade     # Full upgrade: Homebrew packages + Mise runtimes + Stow sync
just status      # Inspect git status and stow package health
just setup       # Run complete workstation setup
```

### Automatic Homebrew Sync

Whenever you install or remove packages, the Zsh wrapper automatically updates your tracked `Brewfile`:

```bash
brew install htop            # Installs htop and adds brew "htop" to Brewfile
brew install --cask arc      # Installs Arc browser and adds cask "arc" to Brewfile
brew uninstall htop          # Removes htop from system and Brewfile
```

### AWDL / AirDrop Controls (Gaming)

```bash
awdl status      # Check current AWDL / AirDrop status
awdl on          # Enable AirDrop / AirPlay
awdl off         # Disable AWDL (Low-Latency Gaming Mode)
awdl toggle      # Toggle between active and inactive
```
