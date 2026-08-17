#!/usr/bin/env bash

set -euo pipefail

ROOT="/workspace"

PICOARCH_OUTPUT="$ROOT/output/picoarch"
PICOARCH_BIN="$PICOARCH_OUTPUT/picoarch"
CORES_DIR="$PICOARCH_OUTPUT/cores"

OUTPUT="$ROOT/output/picoarch-paks"

BLUEMSX_ASSETS="$ROOT/build/picoarch-sources/bluemsx/system/bluemsx"
FMSX_ROMS="$ROOT/build/picoarch-sources/fmsx/fMSX/ROMs"

# ---------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------

if [ ! -f "$PICOARCH_BIN" ]; then
    echo "ERROR: missing PicoArch binary:"
    echo "  $PICOARCH_BIN"
    exit 1
fi

if [ ! -d "$CORES_DIR" ]; then
    echo "ERROR: missing PicoArch cores directory:"
    echo "  $CORES_DIR"
    exit 1
fi

required_cores=(
    beetle-pce-fast_libretro.so
    bluemsx_libretro.so
    fake08_libretro.so
    fbalpha2012_libretro.so
    fceumm_libretro.so
    fmsx_libretro.so
    gambatte_libretro.so
    gme_libretro.so
    gpsp_libretro.so
    mame2000_libretro.so
    mame2003_plus_libretro.so
    mednafen_ngp_libretro.so
    mednafen_wswan_libretro.so
    pcsx_rearmed_libretro.so
    picodrive_libretro.so
    pokemini_libretro.so
    prboom_libretro.so
    quicknes_libretro.so
    smsplus-gx_libretro.so
    snes9x2002_libretro.so
    snes9x2005_libretro.so
    snes9x2005_plus_libretro.so
    snes9x2010_libretro.so
    stella2014_libretro.so
)

for core in "${required_cores[@]}"; do
    if [ ! -f "$CORES_DIR/$core" ]; then
        echo "ERROR: missing core:"
        echo "  $CORES_DIR/$core"
        exit 1
    fi
done

if [ ! -d "$BLUEMSX_ASSETS/Machines" ]; then
    echo "ERROR: missing blueMSX Machines:"
    echo "  $BLUEMSX_ASSETS/Machines"
    exit 1
fi

if [ ! -d "$BLUEMSX_ASSETS/Databases" ]; then
    echo "ERROR: missing blueMSX Databases:"
    echo "  $BLUEMSX_ASSETS/Databases"
    exit 1
fi

fmsx_roms=(
    MSX.ROM
    MSX2.ROM
    MSX2EXT.ROM
    MSX2P.ROM
    MSX2PEXT.ROM
    DISK.ROM
    KANJI.ROM
)

for rom in "${fmsx_roms[@]}"; do
    if [ ! -f "$FMSX_ROMS/$rom" ]; then
        echo "ERROR: missing fMSX system ROM:"
        echo "  $FMSX_ROMS/$rom"
        exit 1
    fi
done

# ---------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------

rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"


create_pak()
{
    local pak_name="$1"
    local core_file="$2"
    local rom_dir_name="$3"
    local mode="${4:-normal}"

    local pak_dir="$OUTPUT/$pak_name-picoarch.pak"
    local core_name="${core_file%_libretro.so}"

    mkdir -p "$pak_dir"

    printf '%s\n' "$rom_dir_name" > "$pak_dir/system"

    cp "$PICOARCH_BIN" "$pak_dir/picoarch"
    cp "$CORES_DIR/$core_file" "$pak_dir/$core_file"

    cat > "$pak_dir/launch.sh" <<EOF_LAUNCH
#!/bin/sh

EMU_EXE="picoarch"
EMU_DIR=\$(dirname "\$0")

ROM_DIR="/mnt/SDCARD/Roms/$rom_dir_name"
SYSTEM_DIR="\$ROM_DIR/.picoarch-$core_name"

EMU_NAME="$pak_name"
ROM="\$1"

mkdir -p "\$SYSTEM_DIR"
mkdir -p "/mnt/SDCARD/.minui/logs"
EOF_LAUNCH

    case "$mode" in
        swap)
            cat >> "$pak_dir/launch.sh" <<'EOF_LAUNCH'

needs-swap
EOF_LAUNCH
            ;;

        psx)
            cat >> "$pak_dir/launch.sh" <<'EOF_LAUNCH'

# Use the PlayStation BIOS provided by the Trimui firmware when available.
if [ ! -f "$SYSTEM_DIR/scph5502.bin" ] && \
   [ -f "/usr/trimui/bin/pcsx_rearmed/bios/scph5502.bin" ]; then
    cp "/usr/trimui/bin/pcsx_rearmed/bios/scph5502.bin" \
       "$SYSTEM_DIR/scph5502.bin"
fi

needs-swap
EOF_LAUNCH
            ;;

        bluemsx)
            mkdir -p "$pak_dir/assets"

            cp -a "$BLUEMSX_ASSETS/Machines" \
                  "$pak_dir/assets/Machines"

            cp -a "$BLUEMSX_ASSETS/Databases" \
                  "$pak_dir/assets/Databases"

            cat >> "$pak_dir/launch.sh" <<'EOF_LAUNCH'

# Install blueMSX machine definitions and databases on first use.
if [ ! -d "$SYSTEM_DIR/Machines" ]; then
    cp -R "$EMU_DIR/assets/Machines" "$SYSTEM_DIR/Machines"
fi

if [ ! -d "$SYSTEM_DIR/Databases" ]; then
    cp -R "$EMU_DIR/assets/Databases" "$SYSTEM_DIR/Databases"
fi
EOF_LAUNCH
            ;;

        fmsx)
            mkdir -p "$pak_dir/assets"

            for rom in "${fmsx_roms[@]}"; do
                cp "$FMSX_ROMS/$rom" "$pak_dir/assets/$rom"
            done

            cat >> "$pak_dir/launch.sh" <<'EOF_LAUNCH'

# Install the system ROMs supplied with the pinned fMSX source.
for FILE in \
    MSX.ROM \
    MSX2.ROM \
    MSX2EXT.ROM \
    MSX2P.ROM \
    MSX2PEXT.ROM \
    DISK.ROM \
    KANJI.ROM

do
    if [ ! -f "$SYSTEM_DIR/$FILE" ]; then
        cp "$EMU_DIR/assets/$FILE" "$SYSTEM_DIR/$FILE"
    fi
done
EOF_LAUNCH
            ;;

        normal)
            ;;

        *)
            echo "ERROR: unknown PAK mode: $mode"
            exit 1
            ;;
    esac

    cat >> "$pak_dir/launch.sh" <<EOF_LAUNCH

HOME="\$ROM_DIR"

cd "\$EMU_DIR"

"\$EMU_DIR/\$EMU_EXE" "./$core_file" "\$ROM" \
    &> "/mnt/SDCARD/.minui/logs/\$EMU_NAME.txt"
EOF_LAUNCH

    chmod +x "$pak_dir/launch.sh"
}


# ---------------------------------------------------------------------
# Nintendo
# ---------------------------------------------------------------------

create_pak \
    "Nintendo (FCEUmm)" \
    "fceumm_libretro.so" \
    "Nintendo"

create_pak \
    "Nintendo (QuickNES)" \
    "quicknes_libretro.so" \
    "Nintendo"

create_pak \
    "Famicom Disk System (FCEUmm)" \
    "fceumm_libretro.so" \
    "Famicom Disk System"


# ---------------------------------------------------------------------
# Game Boy
# ---------------------------------------------------------------------

create_pak \
    "Game Boy" \
    "gambatte_libretro.so" \
    "Game Boy"

create_pak \
    "Game Boy Color" \
    "gambatte_libretro.so" \
    "Game Boy Color"

create_pak \
    "Game Boy Advance" \
    "gpsp_libretro.so" \
    "Game Boy Advance" \
    "swap"


# ---------------------------------------------------------------------
# Sega 8-bit / ColecoVision
# ---------------------------------------------------------------------

create_pak \
    "Game Gear" \
    "smsplus-gx_libretro.so" \
    "Game Gear"

create_pak \
    "Master System" \
    "smsplus-gx_libretro.so" \
    "Master System"

create_pak \
    "ColecoVision (blueMSX)" \
    "bluemsx_libretro.so" \
    "ColecoVision" \
    "bluemsx"

create_pak \
    "SG-1000 (blueMSX)" \
    "bluemsx_libretro.so" \
    "SG-1000" \
    "bluemsx"


# ---------------------------------------------------------------------
# Sega 16/32-bit / CD
# ---------------------------------------------------------------------

create_pak \
    "Genesis" \
    "picodrive_libretro.so" \
    "Genesis"

create_pak \
    "Sega CD" \
    "picodrive_libretro.so" \
    "Sega CD"

create_pak \
    "Sega 32X" \
    "picodrive_libretro.so" \
    "Sega 32X"


# ---------------------------------------------------------------------
# Super Nintendo
# ---------------------------------------------------------------------

create_pak \
    "Super Nintendo (Snes9x 2002)" \
    "snes9x2002_libretro.so" \
    "Super Nintendo"

create_pak \
    "Super Nintendo (Snes9x 2005)" \
    "snes9x2005_libretro.so" \
    "Super Nintendo"

create_pak \
    "Super Nintendo (Snes9x 2005 Plus)" \
    "snes9x2005_plus_libretro.so" \
    "Super Nintendo"

create_pak \
    "Super Nintendo (Snes9x 2010)" \
    "snes9x2010_libretro.so" \
    "Super Nintendo"

create_pak \
    "Satellaview (Snes9x 2010)" \
    "snes9x2010_libretro.so" \
    "Satellaview"

create_pak \
    "Sufami Turbo (Snes9x 2010)" \
    "snes9x2010_libretro.so" \
    "Sufami Turbo"


# ---------------------------------------------------------------------
# PlayStation
# ---------------------------------------------------------------------

create_pak \
    "PlayStation" \
    "pcsx_rearmed_libretro.so" \
    "PlayStation" \
    "psx"


# ---------------------------------------------------------------------
# NEC
# ---------------------------------------------------------------------

create_pak \
    "TurboGrafx-16" \
    "beetle-pce-fast_libretro.so" \
    "TurboGrafx-16"

create_pak \
    "TurboGrafx-CD" \
    "beetle-pce-fast_libretro.so" \
    "TurboGrafx-CD"


# ---------------------------------------------------------------------
# SNK / Bandai
# ---------------------------------------------------------------------

create_pak \
    "Neo Geo Pocket" \
    "mednafen_ngp_libretro.so" \
    "Neo Geo Pocket"

create_pak \
    "Neo Geo Pocket Color" \
    "mednafen_ngp_libretro.so" \
    "Neo Geo Pocket Color"

create_pak \
    "WonderSwan" \
    "mednafen_wswan_libretro.so" \
    "WonderSwan"

create_pak \
    "WonderSwan Color" \
    "mednafen_wswan_libretro.so" \
    "WonderSwan Color"

create_pak \
    "Pokemon Mini" \
    "pokemini_libretro.so" \
    "Pokemon Mini"


# ---------------------------------------------------------------------
# MSX
# ---------------------------------------------------------------------

create_pak \
    "MSX (blueMSX)" \
    "bluemsx_libretro.so" \
    "MSX" \
    "bluemsx"

create_pak \
    "MSX (fMSX)" \
    "fmsx_libretro.so" \
    "MSX" \
    "fmsx"


# ---------------------------------------------------------------------
# Atari
# ---------------------------------------------------------------------

create_pak \
    "Atari 2600" \
    "stella2014_libretro.so" \
    "Atari 2600"


# ---------------------------------------------------------------------
# Arcade
# ---------------------------------------------------------------------

create_pak \
    "Arcade (MAME 2000)" \
    "mame2000_libretro.so" \
    "Arcade"

create_pak \
    "Arcade (MAME 2003 Plus)" \
    "mame2003_plus_libretro.so" \
    "Arcade"

create_pak \
    "Arcade (FBA 2012)" \
    "fbalpha2012_libretro.so" \
    "Arcade"


# ---------------------------------------------------------------------
# Other
# ---------------------------------------------------------------------

create_pak \
    "Game Music" \
    "gme_libretro.so" \
    "Game Music"

create_pak \
    "PICO-8 (Fake-08)" \
    "fake08_libretro.so" \
    "PICO-8"

create_pak \
    "Doom (PrBoom)" \
    "prboom_libretro.so" \
    "Doom"

create_pak \
    "Heretic (PrBoom)" \
    "prboom_libretro.so" \
    "Heretic"

create_pak \
    "Hexen (PrBoom)" \
    "prboom_libretro.so" \
    "Hexen"


# ---------------------------------------------------------------------
# Final validation
# ---------------------------------------------------------------------

pak_count=$(
    find "$OUTPUT" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -name '*-picoarch.pak' \
        | wc -l
)

if [ "$pak_count" -ne 38 ]; then
    echo "ERROR: expected 38 PAKs, got $pak_count"
    exit 1
fi

while IFS= read -r -d '' pak; do
    if [ ! -s "$pak/system" ]; then
        echo "ERROR: missing system metadata:"
        echo "  $pak/system"
        exit 1
    fi

    if ! sh -n "$pak/launch.sh"; then
        echo "ERROR: invalid launcher:"
        echo "  $pak/launch.sh"
        exit 1
    fi
done < <(
    find "$OUTPUT" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -name '*-picoarch.pak' \
        -print0
)

echo
echo "PicoArch PAK packaging complete."
echo "Output:"
echo "  $OUTPUT"
echo
echo "PAKs: $pak_count"
