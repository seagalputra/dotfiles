# Everything the user gets, on every OS. One file per area.
{
  imports = [
    ./packages.nix
    ./languages.nix
    ./nvim
    ./zsh.nix
    ./tmux.nix
    ./starship.nix
    ./ghostty.nix
    ./direnv.nix
  ];
}
