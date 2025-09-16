#!/usr/bin/env bash
# deps: jq

aw="$(hyprctl -j activewindow 2>/dev/null)"
if [[ -z "$aw" || "$aw" == "null" ]]; then
  echo '{"text":"", "alt":"none", "class":"no-window"}'
  exit 0
fi

# Normalize fields (fullscreen may be bool/int across versions)
fullscreen_val=$(jq -r '
  if .fullscreen==true then 2
  elif .fullscreen==false or .fullscreen==null then 0
  else (.fullscreen|tonumber)
  end
' <<<"$aw")

floating=$(jq -r '.floating // false' <<<"$aw")
pseudo=$(jq -r '.pseudo // false' <<<"$aw")
title=$(jq -r '.title // ""' <<<"$aw")
workspace=$(jq -r '.workspace.name // (.workspace.id|tostring)' <<<"$aw")

# Priority:
# 2: fullscreen
# 1 + pseudo: pseudo-maximized (pseudotiled + maximized)
# 1: maximized
# floating (+ optional pseudo): floating / pseudo-floating (rare but possible)
# pseudo: pseudotiled
# else: tiled
mode="tiled"; class="tiled"

if [[ "$fullscreen_val" -eq 2 ]]; then
  mode="fullscreen"; class="fullscreen"
elif [[ "$fullscreen_val" -eq 1 && "$pseudo" == "true" ]]; then
  mode="pseudo-maximized"; class="pseudo-maximized"
elif [[ "$fullscreen_val" -eq 1 ]]; then
  mode="maximized"; class="maximized"
elif [[ "$floating" == "true" && "$pseudo" == "true" ]]; then
  mode="pseudo-floating"; class="pseudo-floating"
elif [[ "$floating" == "true" ]]; then
  mode="floating"; class="floating"
elif [[ "$pseudo" == "true" ]]; then
  mode="pseudotiled"; class="pseudotiled"
fi

short=" ${mode}"
tooltip=$(printf "window: %s\nworkspace: %s\nmode: %s\nfullscreen: %s\npseudo: %s\nfloating: %s" \
  "$title" "$workspace" "$mode" "$fullscreen_val" "$pseudo" "$floating")

jq -cn --arg t "$short" --arg tt "$tooltip" --arg c "$class" \
  '{text:$t, tooltip:$tt, class:$c, alt:$c}'
