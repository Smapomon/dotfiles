#!/usr/bin/env bash
# Toggle active workspace's gaps_out between two values (default 20 ↔ 100)
# Usage: toggle_gaps_out.sh [LOW HIGH]

set -Eeuo pipefail

DEFAULT_GAPS="20"
ZEN_GAPS="100 500 100 500"

# Get active workspace id
id=$(hyprctl -j activeworkspace | jq ".id")

# Set range variable in order to match the workspace (not working by id only)
rid="r[$id-$id]"

# Current gaps for active workspace
gaps_out_current=$(hyprctl workspacerules -j | jq --arg rid "$rid" '[.[] | select(.workspaceString | startswith($rid)) | .gapsOut[0]] | .[0]')

echo "gaps_out_current: $gaps_out_current"

# toggle gaps for the active workspace
set_gaps_out_to=$DEFAULT_GAPS
zen_mode_msg="Zen mode is off..."

if [[ ("$gaps_out_current" == "null") || ("$gaps_out_current" == "$DEFAULT_GAPS") ]]; then
  set_gaps_out_to=$ZEN_GAPS
  zen_mode_msg="Zen mode is on..."
fi

notify-send -u normal "ZEN MODE" "$zen_mode_msg"
hyprctl keyword workspace $rid f[1], gapsin:5, gapsout:$set_gaps_out_to
hyprctl keyword workspace $rid w[tv1], gapsin:5, gapsout:$set_gaps_out_to

