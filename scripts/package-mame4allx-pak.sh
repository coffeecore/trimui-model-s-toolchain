#!/usr/bin/env bash

set -euo pipefail

ROOT="/workspace"

FIRMWARE="$ROOT/trimui_V0.108.zip"

BUILD="$ROOT/build/mame4allx"
OUTPUT="$ROOT/output/mame4allx"
PAK="$OUTPUT/Arcade (MAME4ALLX).pak"

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

# ---------------------------------------------------------------------
# Validate firmware
# ---------------------------------------------------------------------

[ -f "$FIRMWARE" ] ||
    die "missing firmware: $FIRMWARE"

unzip -l "$FIRMWARE" bin/mame4allx >/dev/null 2>&1 ||
    die "firmware has no bin/mame4allx"

unzip -l "$FIRMWARE" lib/libtmenu.so >/dev/null 2>&1 ||
    die "firmware has no lib/libtmenu.so"

# ---------------------------------------------------------------------
# Prepare PAK
# ---------------------------------------------------------------------

rm -rf "$BUILD" "$OUTPUT"

mkdir -p \
    "$BUILD" \
    "$PAK/lib"

unzip -q \
    "$FIRMWARE" \
    bin/mame4allx \
    lib/libtmenu.so \
    -d "$BUILD"

cp \
    "$BUILD/bin/mame4allx" \
    "$PAK/mame4allx"

cp \
    "$BUILD/lib/libtmenu.so" \
    "$PAK/lib/libtmenu.so"

# Canonical MinUI ROM directory.
printf '%s\n' "Arcade" > "$PAK/system"

# ---------------------------------------------------------------------
# Launcher
# ---------------------------------------------------------------------

cat > "$PAK/launch.sh" <<'EOF'
#!/bin/sh

PAK_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

ROM="${1:-}"

USERDATA="/mnt/SDCARD/.userdata/mame4allx"
LOG_DIR="/mnt/SDCARD/.minui/logs"
LOG="$LOG_DIR/MAME4ALLX.txt"

mkdir -p \
    "$LOG_DIR" \
    "$USERDATA/.mame4all/saves" \
    "$USERDATA/.mame4all/configs" \
    "$USERDATA/.mame4all/previews" \
    "$USERDATA/.mame4all/samples" \
    "$USERDATA/.mame4all/hiscore"

export HOME="$USERDATA"

# Keep the stock libtmenu private to this PAK.
export LD_LIBRARY_PATH="$PAK_DIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Everything below is written to MAME4ALLX.txt.
exec >"$LOG" 2>&1

echo "=== MAME4ALLX ==="
echo "PAK_DIR=$PAK_DIR"
echo "ROM=$ROM"
echo "HOME=$HOME"
echo "PWD before cd=$(pwd)"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

if [ -z "$ROM" ]; then
    echo "ERROR: no ROM argument"
    exit 1
fi

if [ ! -f "$ROM" ]; then
    echo "ERROR: ROM does not exist:"
    echo "  $ROM"
    exit 1
fi

# mame4allx uses both HOME/.mame4all and relative ./.mame4all paths.
# Making PWD == HOME makes both resolve to the same persistent directory.
cd "$USERDATA"

echo "PWD after cd=$(pwd)"
echo
echo "=== starting MAME4ALLX ==="

"$PAK_DIR/mame4allx" "$ROM"
STATUS=$?

echo
echo "=== MAME4ALLX exited ==="
echo "status=$STATUS"

exit "$STATUS"
EOF

chmod +x \
    "$PAK/launch.sh" \
    "$PAK/mame4allx"

# ---------------------------------------------------------------------
# Validate generated PAK
# ---------------------------------------------------------------------

[ -x "$PAK/mame4allx" ] ||
    die "missing MAME4ALLX executable"

[ -f "$PAK/lib/libtmenu.so" ] ||
    die "missing libtmenu.so"

[ -s "$PAK/system" ] ||
    die "missing system metadata"

sh -n "$PAK/launch.sh" ||
    die "invalid launcher"

echo
echo "MAME4ALLX PAK packaging complete."
echo "Output:"
echo "  $PAK"
