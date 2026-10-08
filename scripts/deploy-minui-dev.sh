#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
SOURCE="$ROOT/output/dev/minui"
SYSTEM_SOURCE="$SOURCE/System"
CLOCK_SOURCE="$SOURCE/Tools/Clock.pak"

ADB="${ADB:-adb}"
STAGE="/mnt/SDCARD/.minui-dev"
DEVICE_SYSTEM="/mnt/SDCARD/System"
DEVICE_TOOLS="/mnt/SDCARD/Tools"
DEVICE_CLOCK="$DEVICE_TOOLS/Clock.pak"

[ -d "$SYSTEM_SOURCE" ] || {
    echo "ERROR: missing MinUI System output: $SYSTEM_SOURCE" >&2
    echo "Build it in Docker first with: make dev-minui" >&2
    exit 1
}

[ -x "$CLOCK_SOURCE/clock" ] || {
    echo "ERROR: missing Clock.pak output: $CLOCK_SOURCE" >&2
    echo "Build it in Docker first with: make dev-minui" >&2
    exit 1
}

command -v "$ADB" >/dev/null 2>&1 || {
    echo "ERROR: adb not found on host" >&2
    exit 1
}

"$ADB" get-state >/dev/null 2>&1 || {
    echo "ERROR: Trimui Model S is not connected through ADB" >&2
    exit 1
}

echo "Staging MinUI System and Clock.pak..."
"$ADB" shell rm -rf "$STAGE"
"$ADB" shell mkdir -p "$STAGE/Tools"
"$ADB" push -a "$SYSTEM_SOURCE" "$STAGE/"
"$ADB" push -a "$CLOCK_SOURCE" "$STAGE/Tools/"

echo "Installing MinUI System and Clock.pak..."
"$ADB" shell "
set -e
SRC='$STAGE/System'
DST='$DEVICE_SYSTEM'

find \"\$SRC\" -type d | while IFS= read -r path; do
    rel=\"\${path#\$SRC}\"
    mkdir -p \"\$DST\$rel\"
done

find \"\$SRC\" ! -type d | while IFS= read -r path; do
    rel=\"\${path#\$SRC}\"
    mkdir -p \"\$(dirname \"\$DST\$rel\")\"
    mv -f \"\$path\" \"\$DST\$rel\"
done

mkdir -p '$DEVICE_TOOLS'
rm -rf '$DEVICE_CLOCK'
mv '$STAGE/Tools/Clock.pak' '$DEVICE_CLOCK'
rm -rf '$STAGE'
sync
"

echo "Deployment complete. Reboot the console before testing the fake RTC startup path."
