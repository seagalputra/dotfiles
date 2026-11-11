# dotfiles

Personal macOS configuration for **zsh**, **tmux**, **Ghostty**, and **mise**, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory (except `scripts/`) is a Stow *package* that mirrors the layout of `$HOME`. Installing a package creates symlinks from your home directory into this repository, so every change is tracked in Git.

An interactive installer (`make install`) lets you pick which apps to install; the config of every app you pick, or already have, is linked for you.

## What's included

| Package | Links to | Purpose |
|---------|----------|---------|
| `zsh`   | `~/.zshrc` | Single, fast (~0.15s) zsh config: plain zsh (no framework), [Starship](https://starship.rs) prompt, case-insensitive completion, shared history, prefix history search |
| `tmux`  | `~/.tmux.conf` | Minimal tmux config tuned for [Ghostty](https://ghostty.org): true color, extended keys (Shift+Enter works in Claude Code), new panes/windows open in the current directory |
| `ghostty` | `~/.config/ghostty/` | Minimal [Ghostty](https://ghostty.org) config; every window opens in tmux via `ghostty-tmux.sh` (attaches to session `base` or creates it) |
| `mise`  | `~/.config/mise/config.toml` | Global language versions via [mise](https://mise.jdx.dev): Node, Python, Ruby, Java, Erlang, Elixir |

## Requirements

- macOS (Apple Silicon)
- [Homebrew](https://brew.sh)
- Git

The installer installs [GNU Stow](https://www.gnu.org/software/stow/) and [gum](https://github.com/charmbracelet/gum) (for the prompts) with Homebrew if they are missing.

## Installation

```sh
git clone git@github.com:seagalputra/dotfiles.git ~/Documents/sources/dotfiles
cd ~/Documents/sources/dotfiles
make install
```

`make install` runs `scripts/install.sh`:

1. Lists the apps that are already installed. They are not offered again, but their configs are still linked.
2. Asks which of the remaining apps to install (`x` to select, `enter` to continue; selecting nothing only links configs).
3. Adds apps that a picked app needs (Ghostty needs tmux, because its config starts every window in tmux).
4. Shows the plan and asks for confirmation, then installs the apps and links the configs.

Then open a new terminal, or run `exec zsh -l`.

> The clone location does not matter: the installer and `.stowrc` both link into `~`.

### Existing files

If a real file is already where a link should go (for example your own `~/.zshrc`), the installer asks what to do:

- **Back up and continue**: move it to `~/.dotfiles-backup/<timestamp>/` and link
- **Back up all remaining conflicts**: same, without asking again in this run
- **Show diff**: compare your file with the one in this repo, then ask again
- **Skip the config** or **Abort**

`make bootstrap` (`--all`) backs up without asking.

## Usage

| Command | Description |
|---------|-------------|
| `make` / `make help` | List available targets and detected packages |
| `make install` | Pick apps to install, link configs of picked and installed apps |
| `make bootstrap` | Install every app and link every config without prompts (new machine) |
| `make brew` | Install every app, link nothing |
| `make link` | Symlink all packages into `~`, install nothing |
| `make uninstall` | Remove all symlinks created by this repo |
| `make restow` | Re-link everything (cleans up stale links after adding/removing files) |
| `make dry-run` | Preview what `link` would do without changing anything |

`scripts/install.sh --dry-run` shows what the installer would install and link, without changing anything.

Each app can also be handled on its own:

```sh
scripts/apps/tmux.sh           # install tmux if missing, then link its config
scripts/apps/tmux.sh install   # install only
scripts/apps/tmux.sh link      # link the config only
```

Or call Stow directly from the repository root:

```sh
stow tmux        # link one package
stow -D tmux     # unlink one package
```

### Apps

| App | Installed with | Config |
|-----|----------------|--------|
| zsh | ships with macOS | `zsh` |
| tmux | Homebrew | `tmux` |
| Ghostty | Homebrew cask (needs tmux) | `ghostty` |
| mise | [official installer](https://mise.jdx.dev/installing-mise.html) (Homebrew lags releases) | `mise`; then installs the versions in `config.toml` and enables `pnpm` through Corepack |
| Starship, Neovim, lazygit, Go, Deno, Bun, kubectl | Homebrew | – |
| Docker Desktop, Laravel Herd | Homebrew cask | – |
| Rust | [rustup](https://rustup.rs) (creates `~/.cargo/env`, which `.zshrc` loads) | – |

An app counts as installed when Homebrew has it or when it is already on your `PATH` or in `/Applications`, so tools installed another way are not installed twice.

### Adding an app

Copy an app script and edit it:

```sh
cp scripts/apps/tmux.sh scripts/apps/fzf.sh
```

```bash
#!/usr/bin/env bash
# shellcheck source=scripts/lib.sh
. "$(dirname "$0")/../lib.sh"

DESC="Fuzzy finder"           # shown in the picker
CONFIG=""                     # stow package to link, if the app has one
DEPS=""                       # other apps it needs, e.g. "tmux"

is_installed() { has_formula fzf || has_cmd fzf; }
install() { brew_install fzf; }
# post_link() { ...; }        # optional, runs after the config is linked

main "$@"
```

Helpers such as `has_formula`, `has_cask`, `has_app`, `brew_install` and `brew_install_cask` are in [`scripts/lib.sh`](scripts/lib.sh). New scripts appear in the picker automatically.

### Adding a config

Create a directory named after the tool and mirror the path relative to `$HOME`, then set `CONFIG` in its app script:

```sh
mkdir -p git
mv ~/.gitconfig git/
```

`make link` and `make restow` pick up new directories automatically; the installer warns about directories that no app script links.

### Managing tool versions

Global versions live in `mise/.config/mise/config.toml`. Per-project versions are read from `mise.toml`, `.tool-versions`, and the usual version files (`.nvmrc`, `.node-version`, `.python-version`, `.ruby-version`, `.java-version`, `.sdkmanrc`).

```sh
mise use -g node@24          # change a global version (updates the tracked config)
mise use python@3.12         # pin a version for the current project
mise ls                      # show active versions
mise self-update             # upgrade mise itself
```

### Reloading configs

```sh
exec zsh -l                  # reload zsh
tmux source-file ~/.tmux.conf
```

## Optional setup

**Java for macOS apps.** Apps that locate Java via `/usr/libexec/java_home` need a link into `/Library/Java/JavaVirtualMachines`. mise prints the exact commands after installing Java, for example:

```sh
sudo mkdir /Library/Java/JavaVirtualMachines/corretto-24.0.2.12.1.jdk
sudo ln -s ~/.local/share/mise/installs/java/corretto-24.0.2.12.1/Contents \
  /Library/Java/JavaVirtualMachines/corretto-24.0.2.12.1.jdk/Contents
```

Repeat this after upgrading to a new Java patch release.
