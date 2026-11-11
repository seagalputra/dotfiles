#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Bun JavaScript runtime"

is_installed() { has_formula bun || has_cmd bun; }
install() { brew_install bun; }

main "$@"
