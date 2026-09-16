#!/bin/bash
set -euo pipefail

DUMPER="/usr/local/bin/gngeo-gno-dump"
FORCE="${FORCE:-0}"

usage()
{
    echo "Usage:"
    echo "  gno-convert single /roms/game.zip"
    echo "  gno-convert dir /roms"
}

convert_rom()
{
    local rom="$1"
    local dir
    local base
    local output

    dir="$(dirname "$rom")"
    base="$(basename "$rom")"

    if [[ "${base,,}" == "neogeo.zip" ]]; then
        return
    fi

    if [[ ! -f "$rom" ]]; then
        echo "ERROR: ROM not found: $rom" >&2
        exit 1
    fi

    if [[ ! -f "$dir/neogeo.zip" ]]; then
        echo "ERROR: neogeo.zip not found in: $dir" >&2
        exit 1
    fi

    output="${rom%.*}.gno"

    if [[ -f "$output" && "$FORCE" != "1" ]]; then
        echo "Skipping existing: $output"
        return
    fi

    echo
    echo "Converting: $base"

    "$DUMPER" "$rom"
}

if [[ $# -lt 2 ]]; then
    usage
    exit 1
fi

case "$1" in
    single)
        convert_rom "$2"
        ;;

    dir)
        ROM_DIR="$2"

        if [[ ! -d "$ROM_DIR" ]]; then
            echo "ERROR: directory not found: $ROM_DIR" >&2
            exit 1
        fi

        if [[ ! -f "$ROM_DIR/neogeo.zip" ]]; then
            echo "ERROR: neogeo.zip not found in: $ROM_DIR" >&2
            exit 1
        fi

        shopt -s nullglob nocaseglob

        count=0

        for rom in "$ROM_DIR"/*.zip; do
            if [[ "$(basename "${rom,,}")" == "neogeo.zip" ]]; then
                continue
            fi

            convert_rom "$rom"
            count=$((count + 1))
        done

        echo
        echo "Processed ROMs: $count"
        ;;

    *)
        usage
        exit 1
        ;;
esac
