#!/bin/bash
# Attaches to a running session, or creates a new one if none exists
/opt/homebrew/bin/tmux attach-session -t base || /opt/homebrew/bin/tmux new-session -s base
