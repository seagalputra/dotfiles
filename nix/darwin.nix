# System level: Nix itself and the shell. User packages and dotfiles live in home.nix.
{ self, user, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.${user}.home = "/Users/${user}";
  system.primaryUser = user;

  # /etc/zshenv puts the Nix profiles on PATH for every zsh. ~/.zshrc runs its own
  # compinit (after extending fpath) and starship draws the prompt, so skip both here.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    promptInit = "";
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 7;
}
