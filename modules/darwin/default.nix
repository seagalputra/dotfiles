# Settings for every Mac: Nix itself, the shell, and the primary user's Home Manager config.
{ flake, config, ... }:
let
  inherit (flake) self;
  user = config.system.primaryUser;
in
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.${user}.home = "/Users/${user}";
  home-manager.users.${user}.imports = [ (self + /configurations/home/${user}.nix) ];
  # Files that are in the way are moved aside, not overwritten.
  home-manager.backupFileExtension = "before-nix";

  # /etc/zshenv puts the Nix profiles on PATH for every zsh. ~/.zshrc (Home Manager) runs
  # its own compinit and starship draws the prompt, so skip both here.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    promptInit = "";
  };
}
