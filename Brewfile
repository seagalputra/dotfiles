# Tools used by these dotfiles. Install with: make brew  (or: brew bundle)
#
# Not listed on purpose:
#   mise — installed by `make bootstrap` via the official installer (Homebrew lags releases)
#   Rust — install with https://rustup.rs (creates ~/.cargo/env, which .zshrc loads)

# Core
brew "stow"            # symlinks this repo into ~
brew "tmux"            # tmux/.tmux.conf
brew "neovim"          # $EDITOR
brew "starship"        # prompt
brew "lazygit"         # git TUI

# Toolchains referenced by zsh/.zshrc (skipped quietly when missing)
brew "go"
brew "deno"
brew "bun"
brew "kubernetes-cli"  # kubectl + completion

# Apps
cask "ghostty"         # terminal; tmux config is tuned for it
cask "docker-desktop"
cask "herd"            # PHP (Laravel Herd)
