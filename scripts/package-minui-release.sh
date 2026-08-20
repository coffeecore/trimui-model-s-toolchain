#!/usr/bin/env bash

set -euo pipefail

ROOT="/workspace"
MODE="${1:-full}"

BASE_RELEASE=$(find "$ROOT/sources/minui/release" \
    -maxdepth 1 \
    -type f \
    -name 'MinUI-*.zip' \
    | sort \
    | tail -n 1)

MINUI_EXTRA="$ROOT/output/minui-extra-paks"
STANDALONE="$ROOT/output/standalone-paks"
PICOARCH="$ROOT/output/picoarch-paks"
PICOARCH_TOOL="$ROOT/output/picoarch-tool/Tools/PicoArch.pak"

PATCH="$ROOT/patches/minui/0001-update-use-system-metadata.patch"
SOURCE_UPDATE="$ROOT/sources/minui/paks/System.pak/update.sh"

BUILD="$ROOT/build/minui-release-$MODE"
OUTER="$BUILD/outer"
INNER="$BUILD/inner"
PATCH_ROOT="$BUILD/patch-root"

RELEASE_NAME=$(basename "$BASE_RELEASE" .zip)

INCLUDE_EXTRA=0
INCLUDE_STANDALONE=0
INCLUDE_PICOARCH=0

case "$MODE" in
    only)
        OUTPUT="$ROOT/output/minui-only"
        OUTPUT_ZIP="$OUTPUT/${RELEASE_NAME}-minui-only.zip"
        ;;

    standalone)
        INCLUDE_EXTRA=1
        INCLUDE_STANDALONE=1

        OUTPUT="$ROOT/output/minui-standalone"
        OUTPUT_ZIP="$OUTPUT/${RELEASE_NAME}-standalone.zip"
        ;;

    picoarch)
        INCLUDE_PICOARCH=1

        OUTPUT="$ROOT/output/minui-picoarch"
        OUTPUT_ZIP="$OUTPUT/${RELEASE_NAME}-picoarch.zip"
        ;;

    full)
        INCLUDE_EXTRA=1
        INCLUDE_STANDALONE=1
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

if [ "$INCLUDE_EXTRA" -eq 1 ]; then
    [ -d "$MINUI_EXTRA" ] ||
        die "missing MinUI extra PAK output"

    [ "$(count_paks "$MINUI_EXTRA")" -eq 5 ] ||
        die "expected 5 MinUI extra PAKs"
fi

if [ "$INCLUDE_STANDALONE" -eq 1 ]; then
    [ -d "$STANDALONE" ] ||
        die "missing standalone PAK output"

    [ "$(count_paks "$STANDALONE")" -eq 4 ] ||
        die "expected 4 standalone PAKs"
fi

if [ "$INCLUDE_PICOARCH" -eq 1 ]; then
    [ -d "$PICOARCH" ] ||
        die "missing PicoArch PAK output"

    # [ "$(count_paks "$PICOARCH")" -eq 38 ] ||
    [ "$(count_paks "$PICOARCH")" -eq 37 ] ||
        die "expected 37 PicoArch PAKs"

    [ -d "$PICOARCH_TOOL" ] ||
        die "missing PicoArch Tool PAK"

    [ -f "$PATCH" ] ||
        die "missing MinUI patch: $PATCH"

    [ -f "$SOURCE_UPDATE" ] ||
        die "missing source update.sh: $SOURCE_UPDATE"

    for pak in "$PICOARCH"/*-picoarch.pak; do
        [ -s "$pak/system" ] ||
            die "missing system metadata: $pak/system"
    done
fi

# ---------------------------------------------------------------------
# Prepare MinUI release
# ---------------------------------------------------------------------

rm -rf "$BUILD" "$OUTPUT"

mkdir -p "$OUTER" "$OUTPUT"

unzip -q "$BASE_RELEASE" -d "$OUTER"

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
    # Patch updater when PicoArch metadata support is required
    # -----------------------------------------------------------------

    if [ "$INCLUDE_PICOARCH" -eq 1 ]; then
        [ -f "$INNER/System/System.pak/update.sh" ] ||
            die "inner update has no System/System.pak/update.sh"

        cmp -s \
            "$INNER/System/System.pak/update.sh" \
            "$SOURCE_UPDATE" ||
            die "release update.sh differs from sources/minui version"

        mkdir -p "$PATCH_ROOT/paks/System.pak"

        cp \
            "$SOURCE_UPDATE" \
            "$PATCH_ROOT/paks/System.pak/update.sh"

        (
            cd "$PATCH_ROOT"
            git apply "$PATCH"
        )

        cp \
            "$PATCH_ROOT/paks/System.pak/update.sh" \
            "$INNER/System/System.pak/update.sh"

        grep -q 'DST/system' "$INNER/System/System.pak/update.sh" ||
            die "system metadata patch was not applied"
    fi

    # -----------------------------------------------------------------
    # Add requested PAKs
    # -----------------------------------------------------------------

    ADDED_PAK_COUNT=0

    if [ "$INCLUDE_EXTRA" -eq 1 ]; then
        copy_paks "$MINUI_EXTRA"
        ADDED_PAK_COUNT=$((ADDED_PAK_COUNT + 5))
    fi

    if [ "$INCLUDE_STANDALONE" -eq 1 ]; then
        copy_paks "$STANDALONE"
        ADDED_PAK_COUNT=$((ADDED_PAK_COUNT + 4))
    fi

    if [ "$INCLUDE_PICOARCH" -eq 1 ]; then
        copy_paks "$PICOARCH"
        # ADDED_PAK_COUNT=$((ADDED_PAK_COUNT + 38))
        ADDED_PAK_COUNT=$((ADDED_PAK_COUNT + 37))

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
