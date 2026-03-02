#!/bin/bash
# Toggle monocle layout for the current workspace only
MONOCLE_DIR="/tmp/hypr_monocle"
mkdir -p "$MONOCLE_DIR"

ws_id=$(hyprctl activeworkspace -j | jq -r '.id')

if [ -f "$MONOCLE_DIR/$ws_id" ]; then
    hyprctl keyword workspace "$ws_id",layout:master
    rm "$MONOCLE_DIR/$ws_id"
else
    hyprctl keyword workspace "$ws_id",layout:monocle
    touch "$MONOCLE_DIR/$ws_id"
fi
