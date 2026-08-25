#!/bin/sh
set -eu

PICOARCH_OUTPUT="/workspace/output/picoarch"
PICOARCH_BUILD="/workspace/build/picoarch"
TOOL_OUTPUT="/workspace/output/picoarch-tool"
PAK="$TOOL_OUTPUT/Tools/PicoArch.pak"

TOTAL_CORES=27

rm -rf "$TOOL_OUTPUT"

mkdir -p "$PAK/cores"

test -x "$PICOARCH_OUTPUT/picoarch"

SKIN_DIR=$(
    find "$PICOARCH_BUILD" \
        -type f \
        -path '*/skin/font.png' \
        -printf '%h\n' \
        | head -n 1
)

if [ -z "$SKIN_DIR" ] || [ ! -f "$SKIN_DIR/font.png" ] || [ ! -f "$SKIN_DIR/selector.png" ]; then
    echo "ERROR: missing PicoArch/libpicofe skin under $PICOARCH_BUILD" >&2
    exit 1
fi

cp "$PICOARCH_OUTPUT/picoarch" "$PAK/picoarch"

# launch.sh runs PicoArch from the cores directory so the skin must be there.
mkdir -p "$PAK/cores/skin"
cp -a "$SKIN_DIR/." "$PAK/cores/skin/"

find "$PICOARCH_OUTPUT/cores" \
    -maxdepth 1 \
    -type f \
    -name '*_libretro.so' \
    ! -name 'fake08_libretro.so' \
    -exec cp {} "$PAK/cores/" \;

cat > "$PAK/launch.sh" <<'EOF'
#!/bin/sh

PAK_DIR="$(dirname "$0")"
LOG_DIR="/mnt/SDCARD/.minui/logs"
LOG="$LOG_DIR/PicoArch-Tool.txt"

mkdir -p "$LOG_DIR"

exec >"$LOG" 2>&1

echo "=== PicoArch Tool ==="
echo "PAK_DIR=$PAK_DIR"
echo "PWD before cd=$(pwd)"

cd "$PAK_DIR/cores"

echo "PWD after cd=$(pwd)"
echo
echo "=== skin ==="
ls -lah "$PAK_DIR/cores/skin" 2>&1
echo
echo "=== cores ==="
ls -lah "$PAK_DIR/cores" 2>&1
echo
echo "=== starting PicoArch ==="

"$PAK_DIR/picoarch"
EOF

chmod +x "$PAK/launch.sh"
chmod +x "$PAK/picoarch"

CORE_COUNT=$(
    find "$PAK/cores" \
        -maxdepth 1 \
        -type f \
        -name '*_libretro.so' \
        | wc -l
)

if [ "$CORE_COUNT" -ne "$TOTAL_CORES" ]; then
    echo "ERROR: expected $TOTAL_CORES PicoArch cores, found $CORE_COUNT" >&2
    exit 1
fi

echo
echo "PicoArch Tool PAK complete:"
echo "  $PAK"
echo "  cores: $CORE_COUNT"
