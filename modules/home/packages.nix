# Command-line tools. Tools with their own module (tmux, starship, direnv, ...) are
# installed by it.
{ lib, pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      clang-tools # clang-format
      gh
      kubectl
      lazygit
      ripgrep
      shellcheck
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libimobiledevice # iOS devices
      mole-cleaner # `mo`
      xcodegen
    ];

  home.sessionPath = [ "$HOME/.local/bin" ]; # claude, from its own installer
}
