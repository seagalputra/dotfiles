# tmux. Ghostty attaches every window to the last used session (ghostty.nix).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;
    # Not $SHELL: an app started before the login shell changed still passes the old one.
    shell = lib.getExe config.programs.fish.package;
    terminal = "tmux-256color";
    focusEvents = true; # Claude Code: away detection for notifications
    clock24 = true; # tmux's own default; Home Manager's is 12-hour
    mouse = true; # click windows in the status bar, select and resize panes

    # Sessions survive a restart: prefix C-s saves, prefix C-r restores (~/.tmux/resurrect).
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        # Nix's nvim is saved as /nix/store/.../nvim --cmd ...vim-pack-dir, which the default
        # `nvim` entry never matches; restart it as plain `nvim` (open files are not reopened).
        # claude picks up the pane directory's latest conversation.
        extraConfig = ''
          set -g @resurrect-processes 'lazygit "~vim-pack-dir->nvim" "claude->claude --continue"'
        '';
      }
      {
        plugin = continuum; # after resurrect
        # Saves every 15 minutes; restores when the tmux server starts
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];

    extraConfig = ''
      set -as terminal-features ",xterm-ghostty:RGB:extkeys"

      # Claude Code: Shift+Enter newline
      set -s extended-keys on

      # Terminal palette only (no hex) so tmux follows the Ghostty theme
      set -g status-style                 "bg=default,fg=brightblack"
      set -g status-left-style            "fg=blue,bold"
      set -g status-right-style           "fg=brightblack"
      set -g window-status-style          "fg=brightblack"
      set -g window-status-current-style  "fg=blue,bold"
      set -g pane-border-style            "fg=brightblack"
      set -g pane-active-border-style     "fg=blue"
      # fill= stops the ─ row showing through behind the prompt
      set -g message-style                "bg=yellow,fg=black,fill=yellow"
      set -g message-command-style        "bg=yellow,fg=black,fill=yellow"
      set -g mode-style                   "bg=blue,fg=black"
      set -g clock-mode-colour            blue

      # Default length 10 cuts off the trailing gap
      set -g status-left        "[#{session_name}] "
      set -g status-left-length 40

      # Row 1: ─── separator; row 2: normal status line (prompt drawn here too)
      set -gu status-format
      set -gF status-format[1] "#{status-format[0]}"
      set -g  status-format[0] "#[fg=brightblack]#{R:─,#{client_width}}"
      set -g  status 2
      set -g  message-line 1

      # $HOME is expanded when the config is read
      set -g set-titles on
      set -g set-titles-string "[#W] #{s|^$HOME|~|:pane_current_path}"
      set -g status-interval 5

      set -g detach-on-destroy off

      bind '"' split-window -v -c "#{pane_current_path}"
      bind %   split-window -h -c "#{pane_current_path}"
      bind c   new-window      -c "#{pane_current_path}"
      # Floating panes, centred: -X/-Y = (100% - size) / 2
      bind *   new-pane        -c "#{pane_current_path}" -x 50% -y 25% -X 25% -Y 37%
      # Model and effort flags apply to this session only; saved settings stay as they are.
      bind a   new-pane        -c "#{pane_current_path}" -x 80% -y 80% -X 10% -Y 10% "claude --model haiku --effort low"

      # Popups default to the session's directory; `popup` (prompt or shell) uses the pane's.
      # A later -d still wins.
      set -s command-alias[100] 'popup=display-popup -d "#{pane_current_path}"'
    '';
  };
}
