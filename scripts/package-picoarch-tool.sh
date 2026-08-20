#!/bin/sh
set -eu

PICOARCH_OUTPUT="/workspace/output/picoarch"
TOOL_OUTPUT="/workspace/output/picoarch-tool"
PAK="$TOOL_OUTPUT/Tools/PicoArch.pak"

rm -rf "$TOOL_OUTPUT"

mkdir -p "$PAK/cores"

test -x "$PICOARCH_OUTPUT/picoarch"

cp "$PICOARCH_OUTPUT/picoarch" "$PAK/picoarch"

find "$PICOARCH_OUTPUT/cores" \
    -maxdepth 1 \
    -type f \
    -name '*_libretro.so' \
    ! -name 'fake08_libretro.so' \
    -exec cp {} "$PAK/cores/" \;

cat > "$PAK/launch.sh" <<'EOF'
#!/bin/sh

PAK_DIR="$(dirname "$0")"

cd "$PAK_DIR/cores"

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

if [ "$CORE_COUNT" -ne 23 ]; then
    echo "ERROR: expected 23 PicoArch cores, found $CORE_COUNT" >&2
    exit 1
fi

echo
echo "PicoArch Tool PAK complete:"
echo "  $PAK"
echo "  cores: $CORE_COUNT"
