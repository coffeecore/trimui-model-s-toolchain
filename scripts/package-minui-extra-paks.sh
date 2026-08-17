#!/usr/bin/env bash

set -euo pipefail

ROOT="/workspace"
OUTPUT="$ROOT/output/minui-extra-paks"

CUSTOM="$ROOT/assets/minui-extra-paks"
MINUI="$ROOT/sources/minui/paks"

# ---------------------------------------------------------------------
# Sources
# ---------------------------------------------------------------------

FDS="$CUSTOM/Famicom Disk System.pak"

SEGA_CD="$MINUI/Sega CD.pak"
SEGA_32X="$MINUI/Sega 32X.pak"
TURBOGRAFX_CD="$MINUI/TurboGrafx-CD.pak"
WONDERSWAN_COLOR="$MINUI/WonderSwan Color.pak"

# ---------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------

required_paks=(
    "$FDS"
    "$SEGA_CD"
    "$SEGA_32X"
    "$TURBOGRAFX_CD"
    "$WONDERSWAN_COLOR"
)

for pak in "${required_paks[@]}"; do
    if [ ! -d "$pak" ]; then
        echo "ERROR: missing PAK:"
        echo "  $pak"
        exit 1
    fi

    if [ ! -f "$pak/launch.sh" ]; then
        echo "ERROR: missing launcher:"
        echo "  $pak/launch.sh"
        exit 1
    fi

    if ! sh -n "$pak/launch.sh"; then
        echo "ERROR: invalid launcher:"
        echo "  $pak/launch.sh"
        exit 1
    fi
done

# ---------------------------------------------------------------------
# Packaging
# ---------------------------------------------------------------------

rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"

cp -a "$FDS" "$OUTPUT/Famicom Disk System.pak"

cp -a "$SEGA_CD" "$OUTPUT/Sega CD.pak"
cp -a "$SEGA_32X" "$OUTPUT/Sega 32X.pak"
cp -a "$TURBOGRAFX_CD" "$OUTPUT/TurboGrafx-CD.pak"
cp -a "$WONDERSWAN_COLOR" "$OUTPUT/WonderSwan Color.pak"

# ---------------------------------------------------------------------
# Final validation
# ---------------------------------------------------------------------

pak_count=$(
    find "$OUTPUT" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -name '*.pak' \
        | wc -l
)

if [ "$pak_count" -ne 5 ]; then
    echo "ERROR: expected 5 MinUI extra PAKs, got $pak_count"
    exit 1
fi

echo
echo "MinUI extra PAK packaging complete."
echo "Output:"
echo "  $OUTPUT"
echo
echo "PAKs: $pak_count"
