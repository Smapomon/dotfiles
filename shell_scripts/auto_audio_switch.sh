#!/bin/bash

check_headset_connected() {
  solaar show | awk '
    $0 ~ /PRO X Wireless Gaming Headset/ { in_device = 1; next }
    in_device && /^     / {
      if ($0 ~ /Battery status unavailable/) {
        print "DISCONNECTED"
        exit
      }

      if ($0 ~ /Battery:/ && $0 !~ /unavailable/) {
        print "CONNECTED"
        exit
      }
    }
    in_device && $0 !~ /^     / { exit }'
}

get_sink_id_by_name() {
  local name="$1"
  wpctl status | sed 's/^.*│//' | awk -v n="$name" '
    index($0, n) {
      match($0, /^[[:space:]]*\*?[[:space:]]*([0-9]+)\./, m)
      if (m[1]) {
        print m[1]
        exit
      }
    }
  '
}

get_current_default() {
  local kind="$1"  # "Audio/Sink" or "Audio/Source"
  wpctl status | awk -v k="$kind" '
    $0 ~ "Default Configured Devices:" { in_block = 1; next }
    in_block && $0 ~ k {
      print $NF
      exit
    }
  '
}

HEADSET_SINK_ID=$(get_sink_id_by_name "PRO X Wireless Gaming Headset Analog Stereo")
MIC_SOURCE_ID=$(get_sink_id_by_name "PRO X Wireless Gaming Headset Mono")

SSL_SINK_ID=$(get_sink_id_by_name "alsa_output.usb-Solid_State_Logic_SSL_2_-00.HiFi__Line2__sink [Audio/Sink]")
SSL_MIC_SOURCE_ID=$(get_sink_id_by_name "alsa_input.usb-Solid_State_Logic_SSL_2_-00.HiFi__Mic2__source [Audio/Source]")

if [[ -z "$HEADSET_SINK_ID" || -z "$SSL_SINK_ID" ]]; then
  echo "❌ Headset function failed"
  exit 1
fi

state=$(check_headset_connected)

DEFAULT_SINK=$(get_current_default "Audio/Sink")
DEFAULT_SOURCE=$(get_current_default "Audio/Source")

if [[ "$state" == "DISCONNECTED" ]]; then
  [[ "$DEFAULT_SINK" != "$SSL_SINK_ID" && -n "$SSL_SINK_ID" ]] && wpctl set-default "$SSL_SINK_ID"
  [[ "$DEFAULT_SOURCE" != "$SSL_MIC_SOURCE_ID" && -n "$SSL_MIC_SOURCE_ID" ]] && wpctl set-default "$SSL_MIC_SOURCE_ID"
  echo "🎧🔌 [$(date +'%H:%M')]"
else
  [[ "$DEFAULT_SINK" != "$HEADSET_SINK_ID" && -n "$HEADSET_SINK_ID" ]] && wpctl set-default "$HEADSET_SINK_ID"
  [[ "$DEFAULT_SOURCE" != "$MIC_SOURCE_ID" && -n "$MIC_SOURCE_ID" ]] && wpctl set-default "$MIC_SOURCE_ID"
  echo "🎧 [$(date +'%H:%M')]"
fi

