#!/usr/bin/env bash
exec 2>"$XDG_RUNTIME_DIR/waybar-playerctl.log"
export LC_ALL=C.UTF-8 LANG=C.UTF-8   # ensure UTF-8 output
IFS=$'\n\t'

escape_json() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

progress_bar() {
  # args: percentage (0-100), width
  local pct=${1:-0} width=${2:-16}
  ((pct<0))&&pct=0; ((pct>100))&&pct=100
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  # Use Unicode safely (no tr). If you prefer pure ASCII, see below.
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  printf '%s' "$bar"
}

trap 'kill "$(<"$XDG_RUNTIME_DIR/waybar-playerctl.pid")" 2>/dev/null' EXIT

while true; do
  while read -r playing position length name artist title album arturl hpos hlen; do
    playing=${playing:1}; position=${position:1}; length=${length:1}; name=${name:1}
    artist=${artist:1}; title=${title:1}; album=${album:1}; arturl=${arturl:1}
    hpos=${hpos:1}; hlen=${hlen:1}

    line="${artist:+$artist${title:+ - }}${title:+$title}${hpos:+ ${hpos}${hlen:+|}}${hlen}"
    (( percentage = length ? (100 * (position % length)) / length : 0 ))
    bar="$(progress_bar "$percentage" 16)"

    case $playing in
      ⏸️|Paused)  text="<span foreground=\"#6B6B6B\" size=\"smaller\">⏸️ ${line}</span>" ;;
      ▶️|Playing) text="<small>▶️ ${line}</small>" ;;
      *)          text="<span foreground=\"#073642\">No Audio</span>" ;;
    esac

    tooltip=$(
      printf '%s\n' \
        "<b>${playing}</b> — <i>${name}</i>" \
        "<b>${artist}</b>${title:+ — ${title}}" \
        "${album:+Album: ${album}}" \
        "Time: ${hpos} / ${hlen}  (${percentage}%)" \
        "${bar}"
    )

    printf '{"text":"%s","tooltip":"%s","class":"%s","percentage":%s}\n' \
      "$(escape_json "$text")" \
      "$(escape_json "$tooltip")" \
      "$percentage" \
      "$percentage" || break 2

  done < <(
    playerctl --follow metadata --player playerctld --format \
      $':{{emoji(status)}}\t:{{position}}\t:{{mpris:length}}\t:{{playerName}}\t:{{markup_escape(artist)}}\t:{{markup_escape(title)}}\t:{{markup_escape(album)}}\t:{{mpris:artUrl}}\t:{{duration(position)}}\t:{{duration(mpris:length)}}' &
    echo $! >"$XDG_RUNTIME_DIR/waybar-playerctl.pid"
  )

  echo '<span foreground="#dc322f">No Audio</span>' || break
  sleep 1
done
