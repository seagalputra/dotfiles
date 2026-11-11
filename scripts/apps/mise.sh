#!/usr/bin/env bash
# Installed with the official installer, not Homebrew (Homebrew lags releases).
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Language versions: node python ruby java erlang elixir"
CONFIG="mise"

MISE="$HOME/.local/bin/mise"  # where the installer puts it; maybe not on PATH yet
has_cmd mise && MISE="$(command -v mise)"

is_installed() { has_cmd mise || [ -x "$HOME/.local/bin/mise" ]; }
install() { curl -fsSL https://mise.run | sh; }

post_link() {
  "$MISE" install --yes &&
    "$MISE" exec -- corepack enable &&
    "$MISE" reshim
}

main "$@"
