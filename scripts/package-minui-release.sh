#!/usr/bin/env bash

set -euo pipefail

ROOT="/workspace"

OFFICIAL_RELEASE="$ROOT/sources/minui/release/MinUI-20260812-0.zip"

MINUI_EXTRA="$ROOT/output/minui-extra-paks"
STANDALONE="$ROOT/output/standalone-paks"
PICOARCH="$ROOT/output/picoarch-paks"

PATCH="$ROOT/patches/minui/0001-update-use-system-metadata.patch"
SOURCE_UPDATE="$ROOT/sources/minui/paks/System.pak/update.sh"

BUILD="$ROOT/build/minui-release"
OUTER="$BUILD/outer"
INNER="$BUILD/inner"
PATCH_ROOT="$BUILD/patch-root"

OUTPUT="$ROOT/output/minui-release"
OUTPUT_ZIP="$OUTPUT/MinUI-20260812-0-custom.zip"

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

# ---------------------------------------------------------------------
# Validate inputs
# ---------------------------------------------------------------------

[ -f "$OFFICIAL_RELEASE" ] ||
    die "missing official MinUI release: $OFFICIAL_RELEASE"

[ -f "$PATCH" ] ||
    die "missing MinUI patch: $PATCH"

[ -f "$SOURCE_UPDATE" ] ||
    die "missing source update.sh: $SOURCE_UPDATE"

[ -d "$MINUI_EXTRA" ] ||
    die "missing MinUI extra PAK output"

[ -d "$STANDALONE" ] ||
    die "missing standalone PAK output"

[ -d "$PICOARCH" ] ||
    die "missing PicoArch PAK output"

[ "$(count_paks "$MINUI_EXTRA")" -eq 5 ] ||
    die "expected 5 MinUI extra PAKs"

[ "$(count_paks "$STANDALONE")" -eq 4 ] ||
    die "expected 4 standalone PAKs"

[ "$(count_paks "$PICOARCH")" -eq 38 ] ||
    die "expected 38 PicoArch PAKs"

# Every PicoArch PAK must provide canonical system metadata.
for pak in "$PICOARCH"/*-picoarch.pak; do
    [ -s "$pak/system" ] ||
        die "missing system metadata: $pak/system"
done

# ---------------------------------------------------------------------
# Prepare official release
# ---------------------------------------------------------------------

rm -rf "$BUILD" "$OUTPUT"

mkdir -p "$OUTER" "$INNER" "$PATCH_ROOT" "$OUTPUT"

unzip -q "$OFFICIAL_RELEASE" -d "$OUTER"

[ -f "$OUTER/TrimuiUpdate_MinUI.zip" ] ||
    die "official release has no TrimuiUpdate_MinUI.zip"

unzip -q "$OUTER/TrimuiUpdate_MinUI.zip" -d "$INNER"

[ -d "$INNER/Emus" ] ||
    die "inner update has no Emus directory"

[ -f "$INNER/System/System.pak/update.sh" ] ||
    die "inner update has no System/System.pak/update.sh"

# The release updater must correspond exactly to the source updater
# against which our patch was created.
cmp -s \
    "$INNER/System/System.pak/update.sh" \
    "$SOURCE_UPDATE" ||
    die "release update.sh differs from sources/minui version"

BASE_PAK_COUNT=$(count_paks "$INNER/Emus")

echo "Official MinUI PAKs: $BASE_PAK_COUNT"

# ---------------------------------------------------------------------
# Patch MinUI updater
# ---------------------------------------------------------------------

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

# ---------------------------------------------------------------------
# Add PAKs
# ---------------------------------------------------------------------

copy_paks()
{
    local source="$1"

    for pak in "$source"/*.pak; do
        local name
        name=$(basename "$pak")

        if [ -e "$INNER/Emus/$name" ]; then
            die "PAK already exists in official MinUI payload: $name"
        fi

        cp -a "$pak" "$INNER/Emus/"
    done
}

copy_paks "$MINUI_EXTRA"
copy_paks "$STANDALONE"
copy_paks "$PICOARCH"

FINAL_PAK_COUNT=$(count_paks "$INNER/Emus")
EXPECTED_PAK_COUNT=$((BASE_PAK_COUNT + 5 + 4 + 38))

[ "$FINAL_PAK_COUNT" -eq "$EXPECTED_PAK_COUNT" ] ||
    die "expected $EXPECTED_PAK_COUNT total PAKs, got $FINAL_PAK_COUNT"

# ---------------------------------------------------------------------
# Rebuild inner TrimuiUpdate_MinUI.zip
# ---------------------------------------------------------------------

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

# ---------------------------------------------------------------------
# Rebuild outer MinUI release
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

# Validate the nested update directly from the final ZIP.
unzip -p \
    "$OUTPUT_ZIP" \
    TrimuiUpdate_MinUI.zip \
    > "$BUILD/final-inner.zip"

unzip -t "$BUILD/final-inner.zip" >/dev/null ||
    die "nested ZIP validation failed"

# ---------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------

echo
echo "MinUI release packaging complete."
echo
echo "Official PAKs : $BASE_PAK_COUNT"
echo "Extra PAKs    : 5"
echo "Standalone    : 4"
echo "PicoArch      : 38"
echo "Total PAKs    : $FINAL_PAK_COUNT"
echo
echo "Release:"
echo "  $OUTPUT_ZIP"
