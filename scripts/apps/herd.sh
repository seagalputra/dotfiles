#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Laravel Herd (PHP)"

# Also counts a copy installed from the website (brew would refuse to overwrite it).
is_installed() { has_cask herd || has_app Herd; }
install() { brew_install_cask herd; }

main "$@"
