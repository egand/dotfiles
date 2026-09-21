# dotfiles

Clean, native macOS dotfiles and environment management powered by **GNU Stow**, **Homebrew Bundle**, **Mise**, and **Just**.

## What You Get

- **Package Management**: Single unified `Brewfile` managing CLI utilities, GUI casks, and Nerd Fonts without restrictive wrappers or auto-cleanup zapping.
- **Symlink Architecture**: GNU Stow organizes configurations into modular packages under `stow/` linked directly to `$HOME`. In-place edits are immediately visible in `git status`.
- **System Settings**: Native `scripts/macos-defaults.sh` for Dark mode, fast key repeat (accent popups disabled for Vim), instant dock, Finder list view with breadcrumbs, screenshot location in Downloads.
- **Touch ID for Sudo**: Native macOS `/etc/pam.d/sudo_local` setup with Touch ID authentication.
- **Gaming Optimization**: `awdl` launcher daemon (AirDrop/AWDL disabled on boot for jitter-free Wi-Fi gaming in League of Legends & GeForce NOW) with on-demand `awdl on|off|status|toggle` commands.
- **Terminal & Multiplexer**: Ghostty (Catppuccin Frappe, IBM Plex Mono / BlexMono font) + Herdr (`ctrl+b` keybindings) autostarting on terminal launch.
- **Launcher & Utilities**: Raycast with tracked `.rayconfig` backup (Ghostty terminal alias, `Cmd+Shift+V` Clipboard History).
- **Editor**: Modular Neovim (Treesitter, LSP, Conform format-on-save, Oil, Snacks, Rose-Pine Moon theme).
- **Shell**: Zsh + Starship prompt, `zoxide` (smart cd), `eza` (ls), `bat` (cat), `delta` (diff), `lazygit`, `direnv`, `mise`, and Antigravity CLI aliases (`ag`, `aga`).
- **AI Integration**: Canonical `AGENTS.md` mirrored to Claude Code, Codex, OpenCode, and Gemini/Antigravity; Antigravity CLI custom status bar and Pi Agent extensions.

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
   *This checks Xcode Command Line Tools, installs Homebrew, provisions workspace directories, stows all configurations, installs all Brewfile packages and Nerd Fonts, applies macOS system defaults, enables Touch ID for sudo, and opens the Raycast configuration wizard.*

## Daily Workflow

Because all configuration files in `$HOME` are live symlinks to `~/.dotfiles/stow/`, you can edit them directly in place:

```bash
nvim ~/.config/ghostty/config  # Edits ~/.dotfiles/stow/ghostty/.config/ghostty/config
```

Any modification is instantly reflected in Git inside `~/.dotfiles`.

### Command Runner (`just`)

Use `just` to manage and synchronize your environment:

```bash
just sync        # Mirror all stow packages to $HOME
just brew        # Install/update packages from Brewfile
just macos       # Re-apply macOS system settings
just touchid     # Ensure Touch ID for sudo is active
just upgrade     # Full upgrade: Homebrew packages + Mise runtimes + Stow sync
just status      # Inspect git status and stow package health
```

### AWDL / AirDrop Controls (Gaming)

```bash
awdl status  # Check current state
awdl on      # Enable AirDrop / AirPlay
awdl off     # Disable AWDL (Low-Latency Gaming Mode)
awdl toggle  # Toggle state
```
