#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Terminal (every window opens in tmux)"
CONFIG="ghostty"
DEPS="tmux"  # the config starts each window with ghostty-tmux.sh

is_installed() { has_cask ghostty || has_app Ghostty; }
install() { brew_install_cask ghostty; }

main "$@"
