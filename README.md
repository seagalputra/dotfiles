# dotfiles

Personal macOS setup, managed with Nix: [nix-darwin](https://github.com/nix-darwin/nix-darwin) for the system and [Home Manager](https://github.com/nix-community/home-manager) for packages and dotfiles. Packages are listed in `nix/home.nix`.

Each config directory mirrors `$HOME` (for example `nvim/.config/nvim`). Home Manager symlinks those files from this repository, so edits apply without a rebuild.

## Installation

Requires [Nix](https://nixos.org/download/) (the official installer) and Git.

```sh
git clone git@github.com:seagalputra/dotfiles.git
cd dotfiles
sudo nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin/master#darwin-rebuild -- switch --flake .
```

Clone to the path set as `dotfiles` in `nix/home.nix`, since the config links point there. The host entry in `flake.nix` must match `scutil --get LocalHostName`.

Then open a new terminal, or run `exec zsh -l`.

## Updating

- After changing `nix/` (packages, links): `sudo darwin-rebuild switch --flake .`
- To update packages: `nix flake update`, then the same command.
