# Everything the user gets, on every OS. One file per area.
{
  imports = [
    ./packages.nix
    ./nvim
    ./fish.nix
    ./tmux.nix
    ./starship.nix
    ./ghostty.nix
    ./direnv.nix
    ./opencode.nix
  ];
}
