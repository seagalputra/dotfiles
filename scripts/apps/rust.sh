#!/usr/bin/env bash
# Installed with rustup, not Homebrew. rustup creates ~/.cargo/env, which ~/.zshrc loads.
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Rust toolchain via rustup"

is_installed() { has_cmd rustup || [ -x "$HOME/.cargo/bin/rustup" ]; }
install() { curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path; }

main "$@"
