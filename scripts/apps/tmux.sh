#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Terminal multiplexer"
CONFIG="tmux"

# Only the Homebrew build counts: ghostty-tmux.sh runs /opt/homebrew/bin/tmux.
is_installed() { has_formula tmux; }
install() { brew_install tmux; }

main "$@"
