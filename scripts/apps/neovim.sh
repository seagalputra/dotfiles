#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Editor (EDITOR=nvim)"

is_installed() { has_formula neovim || has_cmd nvim; }
install() { brew_install neovim; }

main "$@"
