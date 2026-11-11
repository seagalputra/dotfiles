#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Deno JavaScript runtime"

is_installed() { has_formula deno || has_cmd deno; }
install() { brew_install deno; }

main "$@"
