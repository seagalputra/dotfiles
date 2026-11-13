#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Terminal multiplexer"
CONFIG="tmux"

is_installed() { has_formula tmux || has_cmd tmux; }
install() { brew_install tmux; }

main "$@"
