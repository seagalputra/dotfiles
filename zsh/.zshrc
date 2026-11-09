# ~/.zshrc — the only zsh config file.
# Ghostty and tmux start login+interactive shells, so this covers everything
# typed into a terminal. Tools like Claude Code may source it non-interactively,
# hence the interactive-only block at the bottom.

# ── Environment & PATH ────────────────────────────────────────────────────
eval "$(/opt/homebrew/bin/brew shellenv)"
. "$HOME/.cargo/env"

export PATH="$HOME/.local/bin:$PATH"        # mise, uv, claude, pipx, …
export PATH="$PATH:$HOME/.docker/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/.risc0/bin"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
. "$HOME/.deno/env"

# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/seagalputra/Library/Application Support/Herd/config/php/84/"

# Herd injected PHP binary.
export PATH="/Users/seagalputra/Library/Application Support/Herd/bin/":$PATH

# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="/Users/seagalputra/Library/Application Support/Herd/config/php/85/"

export EDITOR=nvim

# mise: node, python, ruby, java, erlang, elixir (config: ~/.config/mise/config.toml)
eval "$(mise activate zsh)"

# ── Interactive only ──────────────────────────────────────────────────────
[[ -o interactive ]] || return

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt share_history extended_history hist_ignore_dups hist_ignore_space \
       hist_verify hist_expire_dups_first

# Navigation
setopt auto_cd auto_pushd pushd_ignore_dups
alias ..='cd ..' ...='cd ../..'
alias l='ls -lah' ll='ls -lh' la='ls -lAh'
export CLICOLOR=1

# Completion
fpath=("$HOME/.zsh/completions" $fpath)    # deno
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
source <(kubectl completion zsh)

# Keys: emacs mode; up/down search history by what's already typed
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for k in '^[[A' '^[OA'; do bindkey "$k" up-line-or-beginning-search; done
for k in '^[[B' '^[OB'; do bindkey "$k" down-line-or-beginning-search; done

# Prompt
eval "$(starship init zsh)"
