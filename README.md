# dotfiles
My personal development environment for macOS. Managed with GNU Stow

# Installation
To set up your development environment, clone this repository and run the installation script.
```bash
git clone https://github.com/your-user/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

This script will:
- Install Homebrew and essential packages.
- Install NVM (Node Version Manager) and SDKMAN! (Software Development Kit Manager).
- Stow your dotfiles to the appropriate locations.
