#!/usr/bin/env bash

set -euo pipefail

PICOARCH_PAK_COUNT_EXPECTED=27

ROOT="/workspace"
MODE="${1:-full}"

MINUI="$ROOT/build/release-sources/minui"

BASE_RELEASE=$(find "$MINUI/release" \
    -maxdepth 1 \
    -type f \
    -name 'MinUI-*.zip' \
    -printf '%T@ %p\n' \
    | sort -nr \
    | head -n 1 \
    | cut -d' ' -f2-)

SOURCE_UPDATE="$MINUI/paks/System.pak/update.sh"

PICOARCH="$ROOT/output/picoarch-paks"
PICOARCH_TOOL="$ROOT/output/picoarch-tool/Tools/PicoArch.pak"

BUILD="$ROOT/build/minui-release-$MODE"
OUTER="$BUILD/outer"
INNER="$BUILD/inner"

RELEASE_NAME="MinUI-$(TZ=Europe/Paris date +%Y%m%d)-0"

INCLUDE_PICOARCH=0

case "$MODE" in
    only)
        OUTPUT="$ROOT/output/minui-only"
        OUTPUT_ZIP="$OUTPUT/${RELEASE_NAME}-minui-only.zip"
        ;;

    full)
        INCLUDE_PICOARCH=1

        OUTPUT="$ROOT/output/minui-release"
        OUTPUT_ZIP="$OUTPUT/${RELEASE_NAME}-custom.zip"
        ;;

    *)
        echo "ERROR: unknown release mode: $MODE" >&2
        echo "Expected: only, standalone, picoarch or full" >&2
        exit 1
        ;;
esac

# ---------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

count_paks()
{
    find "$1" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -name '*.pak' \
        | wc -l
}

copy_paks()
{
    local source="$1"

    for pak in "$source"/*.pak; do
        local name
        name=$(basename "$pak")

        if [ -e "$INNER/Emus/$name" ]; then
            die "PAK already exists in MinUI payload: $name"
        fi

        cp -a "$pak" "$INNER/Emus/"
    done
}

# ---------------------------------------------------------------------
# Validate base release
# ---------------------------------------------------------------------

[ -f "$BASE_RELEASE" ] ||
    die "missing MinUI release"

if [ "$INCLUDE_PICOARCH" -eq 1 ]; then
    [ -d "$PICOARCH" ] ||
        die "missing PicoArch PAK output"

    [ "$(count_paks "$PICOARCH")" -eq "$PICOARCH_PAK_COUNT_EXPECTED" ] ||
        die "expected $PICOARCH_PAK_COUNT_EXPECTED PicoArch PAKs"

    [ -d "$PICOARCH_TOOL" ] ||
        die "missing PicoArch Tool PAK"

    [ -f "$SOURCE_UPDATE" ] ||
        die "missing source update.sh: $SOURCE_UPDATE"
fi

# ---------------------------------------------------------------------
# Prepare MinUI release
# ---------------------------------------------------------------------

rm -rf "$BUILD" "$OUTPUT"

mkdir -p "$OUTER" "$OUTPUT"

unzip -q "$BASE_RELEASE" -d "$OUTER"

mkdir -p "$OUTER/Bios/gngeo"

if [ "$INCLUDE_PICOARCH" -eq 1 ]; then
    mkdir -p "$OUTER/Bios/picoarch"
    mkdir -p "$OUTER/Roms"
    mkdir -p "$OUTER/Saves/picoarch"

    for pak in "$PICOARCH"/*-picoarch.pak; do
        # Derive the system name directly from the PicoArch PAK name.
        #
        # Example:
        #   /workspace/output/picoarch-paks/Game Boy-picoarch.pak
        #       -> Game Boy-picoarch.pak
        #       -> Game Boy
        SYSTEM_NAME=$(basename "$pak")
        SYSTEM_NAME=${SYSTEM_NAME%-picoarch.pak}

        mkdir -p "$OUTER/Roms/$SYSTEM_NAME"
    done
fi

[ -f "$OUTER/TrimuiUpdate_MinUI.zip" ] ||
    die "MinUI release has no TrimuiUpdate_MinUI.zip"

# MinUI-only requires no modification of the inner update.
if [ "$MODE" != "only" ]; then
    mkdir -p "$INNER"

    unzip -q "$OUTER/TrimuiUpdate_MinUI.zip" -d "$INNER"

    [ -d "$INNER/Emus" ] ||
        die "inner update has no Emus directory"

    BASE_PAK_COUNT=$(count_paks "$INNER/Emus")

    echo "Base MinUI PAKs: $BASE_PAK_COUNT"

    # -----------------------------------------------------------------
    # Validate PicoArch-aware updater
    # -----------------------------------------------------------------

    if [ "$INCLUDE_PICOARCH" -eq 1 ]; then
        [ -f "$INNER/System/System.pak/update.sh" ] ||
            die "inner update has no System/System.pak/update.sh"

        # The release must contain the updater from our MinUI source tree.
        cmp -s \
            "$INNER/System/System.pak/update.sh" \
            "$SOURCE_UPDATE" ||
            die "release update.sh differs from sources/minui version"

        # Make sure PicoArch PAKs map back to the normal ROM directory.
        #
        # Example:
        #   Game Boy-picoarch.pak
        #       -> Roms/Game Boy
        grep -Fq 'ROM_DIR=${ROM_DIR%-picoarch}' \
            "$INNER/System/System.pak/update.sh" ||
            die "release update.sh has no PicoArch ROM mapping"
    fi

    # -----------------------------------------------------------------
    # Add requested PAKs
    # -----------------------------------------------------------------

    ADDED_PAK_COUNT=0

    if [ "$INCLUDE_PICOARCH" -eq 1 ]; then
        copy_paks "$PICOARCH"
        ADDED_PAK_COUNT=$((ADDED_PAK_COUNT + PICOARCH_PAK_COUNT_EXPECTED))

        mkdir -p "$INNER/Tools"

        rm -rf "$INNER/Tools/PicoArch.pak"

        cp -a \
            "$PICOARCH_TOOL" \
            "$INNER/Tools/"
    fi

    FINAL_PAK_COUNT=$(count_paks "$INNER/Emus")
    EXPECTED_PAK_COUNT=$((BASE_PAK_COUNT + ADDED_PAK_COUNT))

    [ "$FINAL_PAK_COUNT" -eq "$EXPECTED_PAK_COUNT" ] ||
        die "expected $EXPECTED_PAK_COUNT total PAKs, got $FINAL_PAK_COUNT"

    # -----------------------------------------------------------------
    # Rebuild inner update
    # -----------------------------------------------------------------

    rm -f "$OUTER/TrimuiUpdate_MinUI.zip"

    (
        cd "$INNER"

        zip -qr \
            "$OUTER/TrimuiUpdate_MinUI.zip" \
            System \
            Emus \
            Tools \
            updater \
            launch.sh \
            TrimuiUpdate_MinUI.zip
    )

    unzip -t "$OUTER/TrimuiUpdate_MinUI.zip" >/dev/null ||
        die "inner TrimuiUpdate_MinUI.zip validation failed"
fi

# ---------------------------------------------------------------------
# Firmware 0.108 expects this exact update ZIP name
# ---------------------------------------------------------------------

mv \
    "$OUTER/TrimuiUpdate_MinUI.zip" \
    "$OUTER/trimui_Minui.zip"

# ---------------------------------------------------------------------
# Rebuild outer release
# ---------------------------------------------------------------------

(
    cd "$OUTER"

    mapfile -d '' entries < <(
        find . \
            -mindepth 1 \
            -maxdepth 1 \
            -printf '%P\0' \
            | sort -z
    )

    zip -qr "$OUTPUT_ZIP" "${entries[@]}"
)

unzip -t "$OUTPUT_ZIP" >/dev/null ||
    die "final MinUI ZIP validation failed"

unzip -p \
    "$OUTPUT_ZIP" \
    trimui_Minui.zip \
    > "$BUILD/final-inner.zip"

unzip -t "$BUILD/final-inner.zip" >/dev/null ||
    die "nested ZIP validation failed"

# ---------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------

echo
echo "MinUI release packaging complete."
echo "Mode: $MODE"

if [ "$MODE" != "only" ]; then
    echo
    echo "Base PAKs       : $BASE_PAK_COUNT"
    echo "Added PAKs      : $ADDED_PAK_COUNT"
    echo "Total PAKs      : $FINAL_PAK_COUNT"
fi

echo
echo "Release:"
echo "  $OUTPUT_ZIP"
