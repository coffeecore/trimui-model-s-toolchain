#!/bin/sh
# Famicom Disk System.pak/launch.sh

REMAP_FROM="Famicom Disk System"
REMAP_ONTO="Nintendo"
EMU_DIR=$(dirname "$0")
EMU_DIR=${EMU_DIR/$REMAP_FROM/$REMAP_ONTO}
ROM=${1}

"$EMU_DIR/launch.sh" "$ROM"
