#!/usr/bin/env bash

# Prints Waybar JSON with the number of available pacman/AUR updates via paru.
# Shows only the number in the bar; tooltip includes the number and last-checked time.

set -u

ICON="󰏔"

while :; do
  # Count updates (repo + AUR). Suppress errors if paru is updating databases, etc.
  updates_raw="$(paru -Qu 2>/dev/null | wc -l || echo 0)"
  # Trim spaces just in case
  updates="$(echo "$updates_raw" | tr -d '[:space:]')"

  # Fallback to 0 if parsing fails
  if ! printf '%s' "$updates" | grep -qE '^[0-9]+$'; then
    updates="0"
  fi

  last_run="$(date '+%Y-%m-%d %H:%M:%S')"

  # Class for styling (optional): "has-updates" if > 0, otherwise "up-to-date"
  if [ "$updates" -gt 0 ] 2>/dev/null; then
    klass="has-updates"
  else
    klass="up-to-date"
  fi

  # Tooltip with newline; escape newline for JSON
  tooltip="Updates: ${updates}\nLast checked: ${last_run}"
  tooltip_escaped="$(printf '%s' "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')"

  # Emit Waybar JSON (one line)
  printf '{"text":"%s %s","tooltip":"%s","class":"%s"}\n' "$ICON" "$updates" "$tooltip_escaped" "$klass"

  sleep 600
done
