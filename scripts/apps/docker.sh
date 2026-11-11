#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Docker Desktop"

# Also counts a copy installed from the website (brew would refuse to overwrite it).
is_installed() { has_cask docker-desktop || has_app Docker; }
install() { brew_install_cask docker-desktop; }

main "$@"
