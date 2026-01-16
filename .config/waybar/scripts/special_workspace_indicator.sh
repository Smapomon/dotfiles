#!/usr/bin/env bash
# deps: jq
# Shows an icon indicator when there are clients in special workspaces (starting with "special:")

ICON="⭐"

# Get all clients and filter those in special workspaces
clients_json="$(hyprctl -j clients 2>/dev/null)"

if [[ -z "$clients_json" || "$clients_json" == "null" ]]; then
  echo '{"text":"", "tooltip":"", "class":"empty"}'
  exit 0
fi

# Count clients in special workspaces and collect workspace names
special_info=$(jq -r '
  [.[] | select(.workspace.name | startswith("special:"))]
  | if length == 0 then
      {count: 0, workspaces: []}
    else
      {
        count: length,
        workspaces: (group_by(.workspace.name) | map({name: .[0].workspace.name, count: length}))
      }
    end
' <<<"$clients_json")

count=$(jq -r '.count' <<<"$special_info")

if [[ "$count" -eq 0 ]]; then
  # Output empty text so waybar hides the module
  echo '{"text":"", "tooltip":"", "class":"empty"}'
else
  # Build tooltip with details about each special workspace
  tooltip=$(jq -r '
    .workspaces | map("\(.name): \(.count) client(s)") | join("\n")
  ' <<<"$special_info")
  tooltip_escaped=$(printf '%s' "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')
  
  jq -cn --arg icon "$ICON" --arg count "$count" --arg tooltip "$tooltip_escaped" \
    '{text: "\($icon) \($count)", tooltip: $tooltip, class: "has-special"}'
fi
