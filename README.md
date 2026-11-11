# dotfiles

Personal configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory (except `scripts/`) is a Stow package that mirrors `$HOME`, so configs are symlinked from this repository.

## Installation

Requires [Homebrew](https://brew.sh) and Git.

```sh
git clone git@github.com:seagalputra/dotfiles.git
cd dotfiles
make install
```

The installer asks which apps to install, then links the configs of the picked and already installed apps into `~`. Use `make bootstrap` to install and link everything without prompts.

Then open a new terminal, or run `exec zsh -l`.
