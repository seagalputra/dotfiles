#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Zsh config (zsh ships with macOS)"
CONFIG="zsh"

is_installed() { true; }
install() { :; }

main "$@"
