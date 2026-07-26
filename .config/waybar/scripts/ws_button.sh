#!/usr/bin/env bash
# Render one workspace button for waybar. Usage: ws_button.sh <workspace-id>
#
# Part of the hyprland/workspaces workaround documented in config.jsonc
# (Alexays/Waybar#5008); delete this script when the native module is restored.
#
# Reads the cache written by hypr_ws_watch.sh, so this stays a pure file read
# (no hyprctl spawn) even though it runs once per workspace on every event.
# Empty text makes waybar hide the module, which reproduces the dynamic
# workspace list of the built-in hyprland/workspaces module.

set -u

id=${1:?usage: ws_button.sh <workspace-id>}
state_file="${XDG_RUNTIME_DIR:-/run/user/$UID}/waybar-workspaces.state"

ICON_ACTIVE=$''   # nf-fa-circle
ICON_INACTIVE=$'' # nf-fa-circle_o

state=""
if [[ -r $state_file ]]; then
  while IFS=$'\t' read -r ws_id ws_state; do
    if [[ $ws_id == "$id" ]]; then
      state=$ws_state
      break
    fi
  done <"$state_file"
fi

case $state in
  active)   printf '{"text":"<sub>%s %s</sub>","class":"active","alt":"active"}\n'     "$ICON_ACTIVE"   "$id" ;;
  occupied) printf '{"text":"<sub>%s %s</sub>","class":"occupied","alt":"occupied"}\n' "$ICON_INACTIVE" "$id" ;;
  *)        printf '{"text":"","class":"empty","alt":"empty"}\n' ;;
esac
