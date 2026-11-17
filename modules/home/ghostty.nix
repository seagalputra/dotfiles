# Ghostty. Only overrides; everything else uses Ghostty's defaults
# (`ghostty +show-config --default --docs`).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  tmux = lib.getExe config.programs.tmux.package;
  # Every window opens inside tmux: attach to the most recently used session not open
  # in another window, or create "base" when there is none.
  # From the Dock, Ghostty only gets launchd's PATH; the tmux server keeps it, and
  # tmux plugins call `tmux` by name.
  tmuxAttach = pkgs.writeShellScript "ghostty-tmux" ''
    export PATH="${lib.makeBinPath [ config.programs.tmux.package ]}:$PATH"
    ${tmux} attach-session || ${tmux} new-session -s base
  '';
in
{
  programs.ghostty = {
    # A GUI app, so on by default only on macOS. A Linux desktop turns it on in its
    # machine config (`programs.ghostty.enable = true`); servers leave it off.
    enable = lib.mkDefault isDarwin;
    package = if isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    # fish runs inside tmux, where Ghostty doesn't inject its shell integration either.
    enableFishIntegration = false;
    settings = {
      command = "${tmuxAttach}";
      font-size = 15;
    }
    // lib.optionalAttrs isDarwin {
      auto-update = "off"; # updated by Nix
    };
  };
}
