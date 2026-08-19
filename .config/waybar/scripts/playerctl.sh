#!/usr/bin/env bash
exec 2>"$XDG_RUNTIME_DIR/waybar-playerctl.log"
export LC_ALL=C.UTF-8 LANG=C.UTF-8   # ensure UTF-8 output
IFS=$'\n\t'

# Longest "artist - title" we render before ellipsising. The timing is appended
# after this, so keeping the trim here (rather than leaning on waybar's
# max-length) is what guarantees the clock never gets cut off.
MAX_META=40

escape_json() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

# We ask playerctl for raw metadata and escape it ourselves, because trimming a
# pre-escaped string can slice an entity in half ("&amp;" -> "&am") and any
# malformed markup makes waybar drop the whole module.
escape_pango() {
  local s=$1
  # The backslashes matter: since bash 5.2 a bare & in a replacement expands to
  # the matched text, which would yield "<lt;" instead of "&lt;".
  s=${s//&/\&amp;}
  s=${s//</\&lt;}
  s=${s//>/\&gt;}
  printf '%s' "$s"
}

# Character-aware under the UTF-8 locale set above, so this never splits a
# multi-byte character.
truncate_meta() {
  local s=$1
  if (( ${#s} > MAX_META )); then
    printf '%s…' "${s:0:MAX_META-1}"
  else
    printf '%s' "$s"
  fi
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

while true; do
  if read -r playing position length name artist title album arturl hpos hlen < <(
    playerctl --player playerctld metadata --format \
      $':{{emoji(status)}}\t:{{position}}\t:{{mpris:length}}\t:{{playerName}}\t:{{artist}}\t:{{title}}\t:{{album}}\t:{{mpris:artUrl}}\t:{{duration(position)}}\t:{{duration(mpris:length)}}'
  ); then
    playing=${playing:1}; position=${position:1}; length=${length:1}; name=${name:1}
    artist=${artist:1}; title=${title:1}; album=${album:1}; arturl=${arturl:1}
    hpos=${hpos:1}; hlen=${hlen:1}

    # Always render a clock, even before the player reports position/length.
    meta="$(escape_pango "$(truncate_meta "${artist:+$artist${title:+ - }}${title}")")"
    timing="${hpos:-0:00}/${hlen:-0:00}"
    line="${meta:+$meta  }${timing}"

    (( percentage = length ? (100 * position) / length : 0 ))
    bar="$(progress_bar "$percentage" 16)"

    case $playing in
      ⏸️|Paused)  class="paused"
                  text="<span foreground=\"#6B6B6B\" size=\"smaller\">⏸️ ${line}</span>" ;;
      ▶️|Playing) class="playing"
                  text="<small>▶️ ${line}</small>" ;;
      *)          class="stopped"
                  text="<span foreground=\"#073642\">No Audio</span>" ;;
    esac

    tooltip=$(
      printf '%s\n' \
        "<b>$(escape_pango "${playing}")</b> — <i>$(escape_pango "${name}")</i>" \
        "<b>$(escape_pango "${artist}")</b>${title:+ — $(escape_pango "${title}")}" \
        "${album:+Album: $(escape_pango "${album}")}" \
        "Time: ${hpos:-0:00} / ${hlen:-0:00}  (${percentage}%)" \
        "${bar}"
    )

    printf '{"text":"%s","tooltip":"%s","class":"%s","percentage":%s}\n' \
      "$(escape_json "$text")" \
      "$(escape_json "$tooltip")" \
      "$class" \
      "$percentage" || break
  else
    printf '%s\n' \
      '{"text":"<span foreground=\"#dc322f\">No Audio</span>","class":"stopped","percentage":0}' \
      || break
  fi

  sleep 1
done
