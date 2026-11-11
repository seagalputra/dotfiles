#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Kubernetes CLI"

is_installed() { has_formula kubernetes-cli || has_cmd kubectl; }
install() { brew_install kubernetes-cli; }

main "$@"
