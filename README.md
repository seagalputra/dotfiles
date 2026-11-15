# dotfiles

Personal Nix setup for macOS, NixOS and other Linux, wired with [nixos-unified](https://nixos-unified.org). The system is managed by [nix-darwin](https://github.com/nix-darwin/nix-darwin) or NixOS, and the user (packages, shell, terminal, Neovim via [nixvim](https://github.com/nix-community/nixvim)) by [Home Manager](https://github.com/nix-community/home-manager). Everything is written in Nix, so the repository can live anywhere.

## Layout

- `configurations/darwin/<host>.nix`, `configurations/nixos/<host>/`: one machine each. The name must match `hostname -s`.
- `configurations/home/<user>.nix`: the user, the same on every OS.
- `modules/{darwin,nixos,home}/`: shared settings, one file per area.
- `modules/flake/`: flake glue.

Flake outputs follow from this layout ([autowiring](https://nixos-unified.org/guide/autowiring)), so a new file needs no extra wiring.

## Installation

Requires [Nix](https://nixos.org/download/) (the official installer) and Git.

```sh
git clone git@github.com:seagalputra/dotfiles.git
cd dotfiles
nix --extra-experimental-features 'nix-command flakes' run
```

`nix run` activates the machine named after `hostname -s`, with `darwin-rebuild` on macOS or `nixos-rebuild` on NixOS, and asks for sudo. For a new machine, first add its file under `configurations/` (for NixOS, together with its `hardware-configuration.nix`).

On other Linux there is only Home Manager: `nix run .#activate <user>@`.

## Updating

- After changing the config: `nix run`
- To update packages: `nix flake update`, then `nix run`
- To format: `nix fmt`
