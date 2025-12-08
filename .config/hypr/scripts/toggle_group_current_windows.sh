#!/usr/bin/env bash
# Group active workspace windows or ungroup them
# Usage: toggle_group_current_windows.sh

set -Eeuo pipefail

active_json="$(hyprctl -j activewindow)"

# If the active window already belongs to a group, just toggle it (ungroup)
if echo "$active_json" | jq -e '.grouped | length > 0' >/dev/null 2>&1; then
  hyprctl dispatch togglegroup
  exit 0
fi

# Active workspace ID and active window address
ws_id="$(echo "$active_json" | jq -r '.workspace.id')"
orig_addr="$(echo "$active_json" | jq -r '.address')"

# Collect all tiled (non-floating) windows on this workspace
mapfile -t windows < <(
  hyprctl -j clients \
  | jq -r --argjson ws "$ws_id" '
      .[]
      | select(.workspace.id == $ws)
      | select(.floating == false)
      | .address
    '
)

# If 0 or 1 tiled windows, just do a normal togglegroup on the active window
if [ "${#windows[@]}" -le 1 ]; then
  hyprctl dispatch togglegroup
  exit 0
fi

# Ensure the original window is the base of the group
base="$orig_addr"

batch=""

# Focus base and create the group
batch+="dispatch focuswindow address:$base; dispatch togglegroup; "

# Helper: append passes that try to shove each window into the group
add_pass() {
  for addr in "${windows[@]}"; do
    [ "$addr" = "$base" ] && continue
    batch+="dispatch focuswindow address:$addr; "
    # Try from all directions
    batch+="dispatch moveintogroup l; "
    batch+="dispatch moveintogroup r; "
    batch+="dispatch moveintogroup u; "
    batch+="dispatch moveintogroup d; "
  done
}

# Run two passes to catch deeper layouts
add_pass
add_pass

# Return focus to original window at the end
batch+="dispatch focuswindow address:$orig_addr;"

# Execute everything in one shot
hyprctl --batch "$batch"
