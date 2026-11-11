#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Shell prompt (used by the zsh config)"

is_installed() { has_formula starship || has_cmd starship; }
install() { brew_install starship; }

main "$@"
