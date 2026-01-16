#!/usr/bin/env bash
set -euo pipefail

special="special:magic"

# Get current workspace ID
active_ws_id="$(hyprctl activeworkspace -j | jq -r '.id')"

# Check if any window exists in the special workspace
hidden_window="$(hyprctl -j clients | jq -r --arg ws "$special" '
  .[] | select(.workspace.name == $ws) | .address
' | head -n1)"

if [[ -n "$hidden_window" ]]; then
  # Restore the hidden window to the current workspace and focus it
  hyprctl dispatch movetoworkspacesilent "$active_ws_id,address:$hidden_window"
  hyprctl dispatch focuswindow "address:$hidden_window"
else
  # Hide the active window to the special workspace (silently, no workspace toggle)
  hyprctl dispatch movetoworkspacesilent "$special"
fi
