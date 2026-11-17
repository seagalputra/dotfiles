# tmux. Ghostty attaches every window to the last used session (ghostty.nix).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  # The network and battery segments of status-right, run by tmux every status-interval.
  # Nerd Font icons as $'\U...' escapes (code points from nerd-fonts' glyphnames.json).

  # Sets dev (the default route's interface; empty when offline), wifi (the Wi-Fi
  # interface) and name. Reads local state only; nothing is sent over the network.
  readNetwork =
    if isDarwin then
      ''
        dev=$(/sbin/route -n get default 2>/dev/null | awk '/interface:/ { print $2 }' || true)
        wifi=$(/usr/sbin/networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/ { getline; print $2 }')
        name=
        if [[ -n $dev && $dev == "$wifi" ]]; then
          # "<redacted>" unless IPConfiguration's verbose mode is on (modules/darwin)
          name=$(/usr/sbin/ipconfig getsummary "$dev" | awk -F ' SSID : ' '/ SSID : / { print $2; exit }' || true)
        elif [[ $dev == utun* ]]; then
          # The connected VPN configuration, if the tunnel is one
          name=$(/usr/sbin/scutil --nc list | awk -F '"' '/\(Connected\)/ { print $2; exit }' || true)
        fi
      ''
    else
      ''
        dev=$(awk '$2 == "00000000" { print $1; exit }' /proc/net/route)
        wifi=
        name=
        if [[ -n $dev && -d /sys/class/net/$dev/wireless ]]; then
          wifi=$dev
          name=$(iw dev "$dev" link | awk '/SSID:/ { sub(/^[ \t]*SSID: /, ""); print; exit }' || true)
        fi
      '';

  # Sets pct (empty without a battery) and state: charging, ac or discharging.
  readBattery =
    if isDarwin then
      ''
        pct=
        line=$(/usr/bin/pmset -g batt | awk '/InternalBattery/' || true)
        if [[ $line =~ ([0-9]+)% ]]; then
          pct=''${BASH_REMATCH[1]}
          case $line in
            *"; discharging"*) state=discharging ;;
            *"; charging"* | *"finishing charge"*) state=charging ;;
            *) state=ac ;; # charged, or held below full by optimised charging
          esac
        fi
      ''
    else
      ''
        pct=
        for bat in /sys/class/power_supply/BAT*; do
          [[ -r $bat/capacity ]] || continue
          pct=$(<"$bat/capacity")
          case $(<"$bat/status") in
            Discharging) state=discharging ;;
            Charging) state=charging ;;
            *) state=ac ;;
          esac
          break
        done
      '';

  statusRight = pkgs.writeShellApplication {
    name = "tmux-status-right";
    runtimeInputs = [ pkgs.gawk ] ++ lib.optional (!isDarwin) pkgs.iw;
    text = ''
      # Powerline segments, leading into the date's colour (brightblack): network magenta,
      # battery cyan, either red when offline or low. Neighbours of the same colour are
      # split by the thin arrow, others by the solid one.
      prev=default
      sep() { # bg, fg of the segment that follows
        if [[ $1 == "$prev" ]]; then
          printf '#[fg=%s,bg=%s]%s' "$2" "$1" $'\U0000E0B3'
        else
          printf '#[fg=%s,bg=%s]%s' "$1" "$prev" $'\U0000E0B2'
        fi
        prev=$1
      }
      segment() { # bg, fg, text
        sep "$1" "$2"
        printf '#[fg=%s,bg=%s] %s ' "$2" "$1" "''${3//\#/##}" # tmux reads # in the output
      }

      ${readNetwork}
      if [[ -z $dev ]]; then
        segment red black $'\U000F05AA Offline' # wifi_off
      else
        case $dev in
          "$wifi") icon=$'\U000F05A9' label=Wi-Fi ;; # wifi
          utun* | tun* | wg* | tailscale*) icon=$'\U000F0582' label=VPN ;; # vpn
          *) icon=$'\U000F0200' label=Ethernet ;; # ethernet
        esac
        if [[ -z $name || $name == "<redacted>" ]]; then name=$label; fi
        if ((''${#name} > 20)); then name=''${name:0:19}…; fi
        segment magenta black "$icon $name"
      fi

      ${readBattery}
      if [[ -n $pct ]]; then
        # battery_10 .. battery_90, battery (full); the same in battery_charging_*
        levels=($'\U000F007A' $'\U000F007B' $'\U000F007C' $'\U000F007D' $'\U000F007E'
          $'\U000F007F' $'\U000F0080' $'\U000F0081' $'\U000F0082' $'\U000F0079')
        charging=($'\U000F089C' $'\U000F0086' $'\U000F0087' $'\U000F0088' $'\U000F089D'
          $'\U000F0089' $'\U000F089E' $'\U000F008A' $'\U000F008B' $'\U000F0085')
        i=$(((pct + 5) / 10 - 1))
        i=$((i < 0 ? 0 : i))
        case $state in
          charging) icon=''${charging[i]} ;;
          ac) icon=$'\U000F06A5' ;; # power_plug
          *) icon=''${levels[i]} ;;
        esac
        if [[ $state == discharging ]] && ((pct <= 20)); then
          segment red black "$icon $pct%"
        else
          segment cyan black "$icon $pct%"
        fi
      fi

      sep brightblack white
    '';
  };
in
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
        # Saves every 15 minutes; restores when the tmux server starts.
        # The saves run from a hook it adds to status-right as it loads, so status-right is
        # set here rather than in extraConfig, which comes after the plugins.
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g status-right "#(${lib.getExe statusRight})#[fg=white,bg=brightblack] %d %b %Y #[fg=blue,bg=brightblack]#[fg=black,bg=blue,bold] %H:%M "
        '';
      }
    ];

    extraConfig = ''
      set -as terminal-features ",xterm-ghostty:RGB:extkeys"

      # Claude Code: Shift+Enter newline
      set -s extended-keys on

      # Terminal palette only (no hex) so tmux follows the Ghostty theme
      set -g status-style                 "bg=default,fg=brightblack"
      set -g pane-border-style            "fg=brightblack"
      set -g pane-active-border-style     "fg=blue"
      # fill= colours the whole prompt row, not just its text
      set -g message-style                "bg=yellow,fg=black,fill=yellow"
      set -g message-command-style        "bg=yellow,fg=black,fill=yellow"
      set -g mode-style                   "bg=blue,fg=black"
      set -g clock-mode-colour            blue

      # Powerline segments:  (U+E0B0) and  (U+E0B2) are the solid arrows, which need a Nerd Font
      # (Ghostty bundles them). The session turns yellow while the prefix is held.
      # A segment that follows plain text opens with a reversed : bg=default has no
      # colour to give fg, but reversed it draws in the terminal background. When the first
      # window is current, the session's arrow leads straight into it instead.
      set -g status-left                  "#[fg=black,bg=#{?client_prefix,yellow,blue},bold] #{session_name} #[fg=#{?client_prefix,yellow,blue},bg=#{?window_start_flag,brightblack,default},nobold]"
      set -g status-left-length           40
      set -g window-status-separator      ""
      set -g window-status-current-style  default # tmux's own is underscore
      set -g window-status-format         "#[fg=brightblack] #I #W#{?window_zoomed_flag, Z,} "
      set -g window-status-current-format "#{?window_start_flag,,#[fg=brightblack]#[bg=default]#[reverse]}#[noreverse,fg=white,bg=brightblack,bold] #I #W#{?window_zoomed_flag, Z,} #[fg=brightblack,bg=default,nobold]"
      # status-right (network, battery, date, time) is set with the continuum plugin above
      set -g status-right-length          80

      # Row 1: blank gap below the panes; row 2: normal status line (prompt drawn here too)
      set -gu status-format
      set -gF status-format[1] "#{status-format[0]}"
      set -g  status-format[0] ""
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
