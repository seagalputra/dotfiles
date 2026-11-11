#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Git TUI"

is_installed() { has_formula lazygit || has_cmd lazygit; }
install() { brew_install lazygit; }

main "$@"
