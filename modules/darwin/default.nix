# Settings for every Mac: Nix itself, the shell, and the primary user's Home Manager config.
{
  flake,
  config,
  pkgs,
  ...
}:
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

  # fish is the login shell. nix-darwin only sets the shell of users it creates, so it is
  # set once with `chsh` (README); /etc/shells must list it first. /etc/fish puts the Nix
  # profiles on PATH. zsh stays as a fallback with the same PATH (/etc/zshenv).
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];
  programs.zsh.enable = true;

  # The Wi-Fi name in tmux's status line: since macOS 14.4 `ipconfig getsummary` shows it
  # as "<redacted>" unless IPConfiguration's verbose mode is on (which also logs more).
  # Turned on at every boot; retried until it succeeds.
  launchd.daemons.ipconfig-verbose.serviceConfig = {
    ProgramArguments = [
      "/usr/sbin/ipconfig"
      "setverbose"
      "1"
    ];
    RunAtLoad = true;
    KeepAlive.SuccessfulExit = false;
  };
}
