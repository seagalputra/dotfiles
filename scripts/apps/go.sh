#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Go toolchain"

is_installed() { has_formula go || has_cmd go; }
install() { brew_install go; }

main "$@"
