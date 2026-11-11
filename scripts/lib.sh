# shellcheck shell=bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(dirname "$SCRIPTS_DIR")"
APPS_DIR="$SCRIPTS_DIR/apps"
TARGET="${DOTFILES_TARGET:-$HOME}"
BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$TARGET/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"

DESC=""
CONFIG=""
DEPS=""
post_link() { :; }

# "Back up all remaining conflicts" must outlive this process: scripts/install.sh
# runs one process per app and shares a state dir between them.
if [ -n "${DOTFILES_STATE_DIR:-}" ] && [ -f "$DOTFILES_STATE_DIR/backup-all" ]; then
  DOTFILES_AUTO_BACKUP=1
fi

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_BLUE=$'\033[1;34m' C_GREEN=$'\033[1;32m' C_YELLOW=$'\033[1;33m' C_RED=$'\033[1;31m' C_RESET=$'\033[0m'
else
  C_BLUE="" C_GREEN="" C_YELLOW="" C_RED="" C_RESET=""
fi
log()  { printf '%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '%s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()  { printf '%s✗%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

tilde() {
  case "$1" in
    "$HOME" | "$HOME"/*) printf '~%s' "${1#"$HOME"}" ;;
    *) printf '%s' "$1" ;;
  esac
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Homebrew can be installed but not on PATH yet (fresh machine, ~/.zshrc not linked).
load_brew() {
  local b
  if ! has_cmd brew; then
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [ -x "$b" ] && eval "$("$b" shellenv)" && break
    done
  fi
  has_cmd brew || return 1
  [ -n "${HOMEBREW_PREFIX:-}" ] || HOMEBREW_PREFIX="$(brew --prefix)"
}
require_brew() { load_brew || die "Homebrew is required first: https://brew.sh"; }

# Checking Cellar/Caskroom directly is much faster than `brew list`.
has_formula() { load_brew && [ -d "$HOMEBREW_PREFIX/Cellar/$1" ]; }
has_cask()    { load_brew && [ -d "$HOMEBREW_PREFIX/Caskroom/$1" ]; }
has_app()     { [ -d "/Applications/$1.app" ] || [ -d "$HOME/Applications/$1.app" ]; }

brew_install()      { require_brew; brew install "$@"; }
brew_install_cask() { require_brew; brew install --cask "$@"; }

ensure_gum() {
  has_cmd gum && return 0
  log "Installing gum (used for the interactive prompts)"
  brew_install gum || die "Could not install gum"
}

ensure_stow() {
  has_cmd stow && return 0
  load_brew && has_cmd stow && return 0
  log "Installing GNU Stow"
  brew_install stow || die "Could not install GNU Stow"
}

# True when $1 is a symlink into this repo, i.e. made by stow.
_owned() {
  local real
  real="$(readlink -f "$1" 2>/dev/null)" || return 1
  case "$real" in "$REPO"/*) return 0 ;; esac
  return 1
}

# Print the path under $TARGET that stops stow from linking $1 (a file path
# relative to the package root), or nothing when the way is clear.
_blocker() {
  local rest="$1" path="$TARGET" part
  while :; do
    part="${rest%%/*}"
    path="$path/$part"
    if [ -L "$path" ]; then
      _owned "$path" || printf '%s\n' "$path"  # ours (file or folded dir) is fine
      return 0
    fi
    [ -e "$path" ] || return 0
    if [ "$rest" = "$part" ] || [ ! -d "$path" ]; then
      printf '%s\n' "$path"
      return 0
    fi
    rest="${rest#*/}"
  done
}

_backup() {
  local dest="$BACKUP_DIR/${1#"$TARGET"/}"
  mkdir -p "$(dirname "$dest")" && mv "$1" "$dest" || return 1
  ok "Backed up $(tilde "$1") → $(tilde "$dest")"
}

# Returns 0 moved away, 1 failed, 2 skip this config, 3 abort everything.
_resolve_conflict() {
  local path="$1" src choice
  src="$REPO/$CONFIG/${path#"$TARGET"/}"
  while :; do
    if [ "${DOTFILES_AUTO_BACKUP:-0}" = 1 ]; then
      _backup "$path" || return 1
      return 0
    fi
    [ -t 0 ] || die "$(tilde "$path") already exists. Run in a terminal to choose, or set DOTFILES_AUTO_BACKUP=1."
    ensure_gum
    choice="$(gum choose --header "$(tilde "$path") already exists and is not linked to these dotfiles" \
      "Back up and continue" \
      "Back up all remaining conflicts" \
      "Show diff" \
      "Skip the $CONFIG config" \
      "Abort")" || return 3
    case "$choice" in
      "Back up and continue")
        _backup "$path" || return 1
        return 0 ;;
      "Back up all remaining conflicts")
        DOTFILES_AUTO_BACKUP=1
        [ -n "${DOTFILES_STATE_DIR:-}" ] && touch "$DOTFILES_STATE_DIR/backup-all" ;;
      "Show diff")
        diff -ru "$path" "$src" | less -FRX ;;
      "Skip the $CONFIG config") return 2 ;;
      *) return 3 ;;
    esac
  done
}

# Returns 0 linked, 1 failed, 2 skipped, 3 aborted.
link_config() {
  [ -n "$CONFIG" ] || return 0
  [ -d "$REPO/$CONFIG" ] || { warn "Config folder '$CONFIG' not found in $(tilde "$REPO")"; return 1; }
  ensure_stow

  local files=() blockers=() f b seen rc
  while IFS= read -r f; do
    [ -n "$f" ] && files+=("$f")
  done <<EOF
$(cd "$REPO/$CONFIG" && find . \( -type f -o -type l \) ! -name .DS_Store | sed 's|^\./||' | sort)
EOF

  # Several files can share one blocker (e.g. a real ~/.config/ghostty dir).
  for f in "${files[@]}"; do
    b="$(_blocker "$f")"
    [ -n "$b" ] || continue
    for seen in "${blockers[@]}"; do [ "$seen" = "$b" ] && continue 2; done
    blockers+=("$b")
  done

  for b in "${blockers[@]}"; do
    _resolve_conflict "$b"
    rc=$?
    [ $rc -eq 0 ] || return $rc
  done

  stow -d "$REPO" -t "$TARGET" --ignore='\.DS_Store' "$CONFIG" || { warn "stow failed for $CONFIG"; return 1; }
  ok "Linked config: $CONFIG → $(tilde "$TARGET")"
  post_link || { warn "Post-link step for $CONFIG failed"; return 1; }
}

do_install() {
  if is_installed; then
    ok "$APP is already installed"
    return 0
  fi
  log "Installing $APP"
  install || { warn "Failed to install $APP"; return 1; }
  ok "Installed $APP"
}

_install_deps() {
  local dep
  for dep in $DEPS; do
    bash "$APPS_DIR/$dep.sh" || return
  done
}

main() {
  APP="$(basename "$0" .sh)"
  case "${1:-}" in
    "")      _install_deps && do_install && link_config ;;
    install) do_install ;;
    link)    link_config ;;
    info)    printf '%s|%s|%s|%s\n' "$DESC" "$CONFIG" "$DEPS" "$(is_installed && echo 1 || echo 0)" ;;
    -h | --help)
      printf 'Usage: %s [install|link|info]\n' "$0"
      printf '  (no command)  install %s%s, then link its config\n' "$APP" "${DEPS:+ and $DEPS}"
      printf '  install       install %s if missing\n' "$APP"
      printf '  link          link its config into %s\n' "$(tilde "$TARGET")"
      printf '  info          print desc|config|deps|installed\n' ;;
    *) die "Unknown command: $1 (see --help)" ;;
  esac
}
