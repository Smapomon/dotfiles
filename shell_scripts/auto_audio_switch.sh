#!/bin/bash

TOGGLE=false
[[ "$1" == "-t" || "$1" == --toggle ]] && TOGGLE=true

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

SSL_SINK_ID=$(get_sink_id_by_name "alsa_output.usb-Solid_State_Logic_SSL_2_-00.HiFi__Line1__sink [Audio/Sink]")
SSL_MIC_SOURCE_ID=$(get_sink_id_by_name "alsa_input.usb-Solid_State_Logic_SSL_2_-00.HiFi__Mic2__source [Audio/Source]")

if [[ -z "$HEADSET_SINK_ID" || -z "$SSL_SINK_ID" ]]; then
  echo "❌ Headset function failed"
  exit 1
fi


DEFAULT_SINK=$(get_current_default "Audio/Sink")
DEFAULT_SOURCE=$(get_current_default "Audio/Source")
DEFAULT_SINK_ID=$(get_sink_id_by_name "$DEFAULT_SINK [Audio/Sink]")
DEFAULT_SOURCE_ID=$(get_sink_id_by_name "$DEFAULT_SOURCE [Audio/Source]")

HIFI_STATUS="🎧"

if [[ "$DEFAULT_SINK_ID" == "$SSL_SINK_ID" ]]; then
  if $TOGGLE; then
    wpctl set-default "$HEADSET_SINK_ID"
    wpctl set-default "$MIC_SOURCE_ID"
  else
    HIFI_STATUS="🎧🔌"
  fi
else
  if $TOGGLE; then
    wpctl set-default "$SSL_SINK_ID"
    wpctl set-default "$SSL_MIC_SOURCE_ID"
    HIFI_STATUS="🎧🔌"
  fi
fi

echo "$HIFI_STATUS"
