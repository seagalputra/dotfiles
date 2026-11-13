#!/bin/bash
# Attaches to a running session, or creates a new one if none exists.
# Ghostty runs this with the minimal macOS PATH, so look for tmux where it can be
# installed: Nix (home-manager, nix-darwin, nix profile) first, then Homebrew.
PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$HOME/.nix-profile/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# No tmux (e.g. while migrating): open a plain login shell instead of closing the window.
command -v tmux >/dev/null || exec "${SHELL:-/bin/zsh}" -l

tmux attach-session -t base || tmux new-session -s base
