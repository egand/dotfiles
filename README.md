# dotfiles

Declarative personal macOS environment managed with **Nix-Darwin**, **Home-Manager**, and **Nix Flakes**.

## What You Get

- **System Settings**: Dark mode, fast key repeat (accent popups disabled for Vim), instant dock, Finder list view with breadcrumbs, screenshot location in Downloads.
- **Gaming Optimization**: `awdl` launcher daemon (AirDrop/AWDL disabled on boot for jitter-free gaming in League of Legends & GeForce NOW) with on-demand `awdl on|off|status|toggle` commands.
- **Declarative Homebrew**: Casks & brews managed in `homebrew.nix` with auto-sync wrapper (`brew install <pkg>` automatically records to Nix).
- **Terminal & Multiplexer**: Ghostty (Catppuccin Frappe, IBM Plex Mono / BlexMono font) + Herdr (`ctrl+b` keybindings).
- **Editor**: Modular Neovim (Treesitter, LSP, Conform format-on-save, Oil, Snacks, Rose-Pine Moon theme).
- **Shell**: Zsh + Starship prompt, `zoxide` (smart cd), `eza` (ls), `bat` (cat), `delta` (diff), `lazygit`, `direnv`, and Antigravity CLI aliases (`ag`, `aga`).
- **AI Integration**: Shared `AGENTS.md` for Claude Code, Codex, and OpenCode, plus Pi Agent extensions.

## Fresh Machine Setup

1. Clone this repository to `~/.dotfiles`:
   ```bash
   git clone https://github.com/egand/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```
2. Run the bootstrap script:
   ```bash
   ./bootstrap.sh
   ```

## Daily Workflow

Edit your config files in place (under `home/` or `*.nix`), then apply changes:

```bash
./rebuild.sh
# or using the shell alias:
rb
```

### AWDL / AirDrop Controls (Gaming)

```bash
awdl status  # Check current state
awdl on      # Enable AirDrop / AirPlay
awdl off     # Disable AWDL (Low-Latency Gaming Mode)
awdl toggle  # Toggle state
```

### Homebrew Auto-Sync

When you install or remove packages with Homebrew:
```bash
brew install <package>
brew install --cask <app>
brew uninstall <package>
```
The shell wrapper automatically updates `homebrew.nix` and rebuilds the system configuration.
