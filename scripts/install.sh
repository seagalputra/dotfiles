#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/lib.sh"

usage() {
  cat <<EOF
Usage: scripts/install.sh [options]

Pick apps to install. Configs of the picked apps and of apps that are
already installed are linked into $(tilde "$TARGET").

Options:
  --all        Install every missing app without asking; back up files in the way
  --no-config  Only install apps, don't link configs
  --dry-run    Show what would happen without changing anything
  -h, --help   Show this help

One app at a time: scripts/apps/<app>.sh [install|link|info]
EOF
}

ALL=0 NO_CONFIG=0 DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --all) ALL=1 ;;
    --no-config) NO_CONFIG=1 ;;
    --dry-run | -n) DRY_RUN=1 ;;
    -h | --help) usage; exit 0 ;;
    *) die "Unknown option: $arg (see --help)" ;;
  esac
done

contains() {
  local needle="$1" x
  shift
  for x in "$@"; do [ "$x" = "$needle" ] && return 0; done
  return 1
}

list() {
  [ $# -gt 0 ] || { printf '(nothing)'; return; }
  local out="$1" x
  shift
  for x in "$@"; do out="$out, $x"; done
  printf '%s' "$out"
}

[ "$(uname -s)" = Darwin ] || die "These dotfiles are for macOS."
require_brew
if [ "$ALL" = 0 ]; then
  { [ -t 0 ] && [ -t 1 ]; } || die "Not running in a terminal. Use --all to install everything without prompts."
  if [ "$DRY_RUN" = 1 ]; then
    has_cmd gum || die "The picker needs gum: brew install gum (or try --all --dry-run)"
  else
    ensure_gum
  fi
fi

IDS=() DESCS=() CONFIGS=() DEPSS=() INSTALLED=()
for script in "$APPS_DIR"/*.sh; do
  id="$(basename "$script" .sh)"
  info="$(bash "$script" info)" || { warn "Skipping $id: 'scripts/apps/$id.sh info' failed"; continue; }
  IFS='|' read -r desc config deps installed <<<"$info"
  IDS+=("$id") DESCS+=("$desc") CONFIGS+=("$config") DEPSS+=("$deps") INSTALLED+=("$installed")
done
[ ${#IDS[@]} -gt 0 ] || die "No app scripts in $(tilde "$APPS_DIR")"

idx() {
  local i=0
  while [ $i -lt ${#IDS[@]} ]; do
    [ "${IDS[$i]}" = "$1" ] && { echo $i; return 0; }
    i=$((i + 1))
  done
  return 1
}

label() {
  local i
  i="$(idx "$1")"
  printf '%-9s %s' "$1" "${DESCS[$i]}"
  [ -n "${CONFIGS[$i]}" ] && printf '  [+config]'
}

for dir in "$REPO"/*/; do
  pkg="$(basename "$dir")"
  [ "$pkg" = scripts ] && continue
  contains "$pkg" "${CONFIGS[@]}" || warn "Folder '$pkg' is not the CONFIG of any app in scripts/apps/, so it is not linked"
done

present=() missing=()
for i in "${!IDS[@]}"; do
  if [ "${INSTALLED[$i]}" = 1 ]; then present+=("${IDS[$i]}"); else missing+=("${IDS[$i]}"); fi
done

if [ ${#present[@]} -gt 0 ]; then
  lines=()
  for id in "${present[@]}"; do lines+=("✓ $(label "$id")"); done
  if has_cmd gum; then
    gum style --border rounded --padding "0 1" --border-foreground 8 \
      "Already installed" "" "${lines[@]}"
  else
    log "Already installed"
    printf '  %s\n' "${lines[@]}"
  fi
fi

picked=()
if [ "$ALL" = 1 ]; then
  picked=("${missing[@]}")
elif [ ${#missing[@]} -gt 0 ]; then
  options=()
  for id in "${missing[@]}"; do options+=("$(label "$id")"); done
  chosen="$(gum choose --no-limit --height 20 \
    --header "Pick apps to install (none = only link configs, esc = cancel)" \
    "${options[@]}")" || { log "Cancelled."; exit 1; }
  while IFS= read -r line; do
    [ -n "$line" ] && picked+=("${line%% *}")
  done <<<"$chosen"
fi

ORDER=() SEEN=()
add_app() {  # $1 = app id, $2 = app that needs it (empty when picked)
  local id="$1" i dep
  contains "$id" "${SEEN[@]}" && return 0
  SEEN+=("$id")
  i="$(idx "$id")" || { warn "Unknown app '$id'${2:+ (needed by $2)}"; return 0; }
  [ "${INSTALLED[$i]}" = 1 ] && return 0
  for dep in ${DEPSS[$i]}; do add_app "$dep" "$id"; done
  if [ -n "$2" ] && ! contains "$id" "${picked[@]}"; then log "Adding $id (needed by $2)"; fi
  ORDER+=("$id")
}
for id in "${picked[@]}"; do add_app "$id" ""; done

LINK=()
if [ "$NO_CONFIG" = 0 ]; then
  for i in "${!IDS[@]}"; do
    [ -n "${CONFIGS[$i]}" ] || continue
    if [ "${INSTALLED[$i]}" = 1 ] || contains "${IDS[$i]}" "${ORDER[@]}"; then LINK+=("${IDS[$i]}"); fi
  done
fi
link_names=()
for id in "${LINK[@]}"; do link_names+=("${CONFIGS[$(idx "$id")]}"); done

echo
log "Install: $(list "${ORDER[@]}")"
log "Link:    $(list "${link_names[@]}")  → $(tilde "$TARGET")"
if [ ${#ORDER[@]} -eq 0 ] && [ ${#LINK[@]} -eq 0 ]; then
  log "Nothing to do."
  exit 0
fi
if [ "$DRY_RUN" = 1 ]; then
  log "Dry run: nothing was changed."
  exit 0
fi
if [ "$ALL" = 0 ]; then
  gum confirm "Continue?" || { log "Cancelled."; exit 1; }
fi

export DOTFILES_TARGET="$TARGET" DOTFILES_BACKUP_DIR="$BACKUP_DIR"
DOTFILES_STATE_DIR="$(mktemp -d)"
export DOTFILES_STATE_DIR
trap 'rm -rf "$DOTFILES_STATE_DIR"' EXIT
[ "$ALL" = 1 ] && export DOTFILES_AUTO_BACKUP=1

done_install=() failed_install=()
for id in "${ORDER[@]}"; do
  echo
  if bash "$APPS_DIR/$id.sh" install; then done_install+=("$id"); else failed_install+=("$id"); fi
done

linked=() skipped=() failed_link=() aborted=0
for id in "${LINK[@]}"; do
  name="${CONFIGS[$(idx "$id")]}"
  if contains "$id" "${failed_install[@]}"; then
    skipped+=("$name")
    continue
  fi
  echo
  bash "$APPS_DIR/$id.sh" link
  case $? in
    0) linked+=("$name") ;;
    2) skipped+=("$name") ;;
    3) aborted=1; break ;;
    *) failed_link+=("$name") ;;
  esac
done

echo
log "Summary"
[ ${#done_install[@]} -gt 0 ] && ok "Installed: $(list "${done_install[@]}")"
[ ${#linked[@]} -gt 0 ] && ok "Linked: $(list "${linked[@]}")"
[ ${#skipped[@]} -gt 0 ] && warn "Not linked: $(list "${skipped[@]}")"
[ ${#failed_install[@]} -gt 0 ] && warn "Failed to install: $(list "${failed_install[@]}")"
[ ${#failed_link[@]} -gt 0 ] && warn "Failed to link: $(list "${failed_link[@]}")"
[ "$aborted" = 1 ] && warn "Aborted: the remaining configs were not linked."
[ -d "$BACKUP_DIR" ] && log "Backed-up files: $(tilde "$BACKUP_DIR")"
log "Open a new terminal (or run: exec zsh -l)."

[ ${#failed_install[@]} -eq 0 ] && [ ${#failed_link[@]} -eq 0 ] && [ "$aborted" = 0 ]
