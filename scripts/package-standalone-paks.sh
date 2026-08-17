#!/usr/bin/env bash

set -euo pipefail

ROOT="/workspace"

ARNOLD="$ROOT/output/arnold/GX4000.pak"
STELLA="$ROOT/output/stella/Atari2600.pak"
GNGEO="$ROOT/output/gngeo/NEOGEO.pak"
RETRO8="$ROOT/output/retro8/PICO-8.pak"

OUTPUT="$ROOT/output/standalone-paks"

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

validate_pak()
{
    local pak="$1"

    [ -d "$pak" ] ||
        die "missing PAK: $pak"

    [ -f "$pak/launch.sh" ] ||
        die "missing launcher: $pak/launch.sh"

    sh -n "$pak/launch.sh" ||
        die "invalid launcher: $pak/launch.sh"
}

validate_pak "$ARNOLD"
validate_pak "$STELLA"
validate_pak "$GNGEO"
validate_pak "$RETRO8"

rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"

# Arnold
cp -a \
    "$ARNOLD" \
    "$OUTPUT/GX4000.pak"

# Stella
cp -a \
    "$STELLA" \
    "$OUTPUT/Atari 2600.pak"

sed -i \
    's/# Atari2600\.pak\/launch\.sh/# Atari 2600.pak\/launch.sh/' \
    "$OUTPUT/Atari 2600.pak/launch.sh"

# GnGeo
cp -a \
    "$GNGEO" \
    "$OUTPUT/Neo Geo.pak"

sed -i \
    -e 's/# NEOGEO\.pak\/launch\.sh/# Neo Geo.pak\/launch.sh/' \
    -e 's|^BIOSPATH=.*$|BIOSPATH="/mnt/SDCARD/Emus/Neo Geo.pak/bios/"|' \
    "$OUTPUT/Neo Geo.pak/launch.sh"

# Retro8
cp -a \
    "$RETRO8" \
    "$OUTPUT/PICO-8.pak"

# Validate generated launchers too.
for pak in "$OUTPUT"/*.pak; do
    sh -n "$pak/launch.sh" ||
        die "invalid packaged launcher: $pak/launch.sh"
done

pak_count=$(
    find "$OUTPUT" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -name '*.pak' \
        | wc -l
)

[ "$pak_count" -eq 4 ] ||
    die "expected 4 standalone PAKs, got $pak_count"

echo
echo "Standalone PAK packaging complete."
echo "Output:"
echo "  $OUTPUT"
echo
echo "PAKs: $pak_count"
