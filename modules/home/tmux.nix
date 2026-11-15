# tmux. Ghostty opens every window in its session "base" (ghostty.nix).
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    focusEvents = true; # Claude Code: away detection for notifications
    clock24 = true; # tmux's own default; Home Manager's is 12-hour
    mouse = true; # click windows in the status bar, select and resize panes

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
    '';
  };
}
