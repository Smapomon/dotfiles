#!/usr/bin/env bash
exec 2>|"$XDG_RUNTIME_DIR/waybar-updates.log"
export LC_ALL=C.UTF-8 LANG=C.UTF-8
IFS=$'\n\t'

PIDFILE="$XDG_RUNTIME_DIR/waybar-updates.pid"
echo $$ > "$PIDFILE"

INTERVAL=$((10*60))  # 10 minutes
last_check=0
updates=0

escape_json() {
  local s=$1
  s=${s//\\/\\\\}; s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}; s=${s//$'\r'/\\r}; s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

check_updates() {
  # If paru exits nonzero, keep previous values and don't update timestamp
  if updates_out="$(paru -Qu 2>/dev/null)"; then
    updates="$(wc -l <<<"$updates_out")"
    last_check="$(date +%s)"
    return 0
  else
    return 1
  fi
}

print_json() {
  local time_str
  if (( last_check > 0 )); then
    time_str="$(date +'%H:%M' -d @"$last_check")"
  else
    time_str="–"
  fi

  local text="$updates ($time_str)"
  local tooltip="Updates: $updates  Last checked: $time_str"

  printf '{"text":"  %s","tooltip":"%s"}\n' \
    "$(escape_json "$text")" \
    "$(escape_json "$tooltip")"
}

# Initial check + print once at startup
check_updates
print_json

# Only update the timestamp/output when an actual check runs
while :; do
  now="$(date +%s)"
  if (( now - last_check >= INTERVAL || last_check == 0 )); then
    if check_updates; then
      print_json
    fi
  fi
  sleep 10
done
