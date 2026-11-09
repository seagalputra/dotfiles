# dotfiles

Personal macOS configuration for **zsh**, **tmux**, and **mise**, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a Stow *package* that mirrors the layout of `$HOME`. Installing a package creates symlinks from your home directory into this repository, so every change is tracked in Git.

## What's included

| Package | Links to | Purpose |
|---------|----------|---------|
| `zsh`   | `~/.zshrc` | Single, fast (~0.15s) zsh config: plain zsh (no framework), [Starship](https://starship.rs) prompt, case-insensitive completion, shared history, prefix history search |
| `tmux`  | `~/.tmux.conf` | Minimal tmux config tuned for [Ghostty](https://ghostty.org): true color, extended keys (Shift+Enter works in Claude Code), new panes/windows open in the current directory |
| `mise`  | `~/.config/mise/config.toml` | Global language versions via [mise](https://mise.jdx.dev): Node, Python, Ruby, Java, Erlang, Elixir |

## Requirements

- macOS (Apple Silicon)
- [Homebrew](https://brew.sh)
- Git

`make bootstrap` installs GNU Stow and mise for you if they are missing.

## Installation

```sh
git clone git@github.com:seagalputra/dotfiles.git ~/Documents/sources/dotfiles
cd ~/Documents/sources/dotfiles
make bootstrap
```

`bootstrap` will:

1. Install GNU Stow (via Homebrew) and mise (via the [official installer](https://mise.jdx.dev/installing-mise.html)) if missing
2. Symlink every package into `$HOME`
3. Install the tool versions listed in `mise/.config/mise/config.toml`
4. Enable `pnpm` through Corepack

Then open a new terminal, or run `exec zsh -l`.

> The clone location does not matter: `.stowrc` sets the Stow target to `~`.

### Existing files

Stow will not overwrite real files. If `~/.zshrc` (or another target) already exists, `make install` stops with a conflict. Back it up or remove it, then run the command again:

```sh
mv ~/.zshrc ~/.zshrc.bak
make install
```

## Usage

| Command | Description |
|---------|-------------|
| `make` / `make help` | List available targets and detected packages |
| `make bootstrap` | Full setup on a new machine |
| `make install` | Symlink all packages into `~` |
| `make uninstall` | Remove all symlinks created by this repo |
| `make restow` | Re-link everything (cleans up stale links after adding/removing files) |
| `make dry-run` | Preview what `install` would do without changing anything |

To work with a single package, call Stow directly from the repository root:

```sh
stow tmux        # link one package
stow -D tmux     # unlink one package
```

### Adding a new package

Create a directory named after the tool and mirror the path relative to `$HOME`, then restow:

```sh
mkdir -p git
mv ~/.gitconfig git/
make restow
```

New directories are picked up automatically; no Makefile changes are needed.

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
