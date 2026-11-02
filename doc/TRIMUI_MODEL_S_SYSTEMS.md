# Trimui Model S — current systems and PAKs

This document describes the **current release packaging**, not planned systems or cores that merely compile. The authoritative sources are the `picoarch` branch of `coffeecore/MinUI-Legacy-Trimui-Model-S`, especially its `makefile` and `scripts/picoarch/package-paks.sh`.

## Release variants

| Variant | Base MinUI emulator PAKs | Additional PicoArch emulator PAKs | Tools |
|---|---:|---:|---|
| `*-minui.zip` | 23 | — | MinUI tools; optional GMenuNX |
| `*-picoarch.zip` | 23 | 27 | `PicoArch.pak` with 21 cores; optional GMenuNX |

The **23 base PAKs** include the traditional MinUI emulators, extra system remapping launchers, and the standalones added to this fork (GnGeo, Arnold, Stella, and Retro8). Do not confuse the number of emulator PAKs with the number of libretro cores.

## PicoArch emulator PAKs (27)

The names below are ROM directory names. Each generates a PAK named `<system>-picoarch.pak`.

| ROM directory / PAK name | Libretro core | Notes |
|---|---|---|
| `FC` | `fceumm` | |
| `GB`, `GBC` | `gambatte` | Two separate PAKs |
| `GBA` | `gpsp` | `needs-swap` |
| `GG`, `MS` | `smsplus-gx` | Two PAKs |
| `COLECO`, `SG1000` | `bluemsx` | Bundled `Machines/` and `Databases/` assets |
| `MD`, `SCD`, `32X` | `picodrive` | Three PAKs |
| `SFC` | `snes9x2005` | |
| `PS` | `pcsx_rearmed` | Optional firmware BIOS copy; `needs-swap` |
| `PCE`, `PCECD` | `beetle-pce-fast` | Two PAKs |
| `NGP`, `NGPC` | `mednafen_ngp` | Two PAKs |
| `NEOGEO` | `gngeo` | `needs-swap`; standalone GnGeo remains available |
| `WS`, `WSC` | `mednafen_wswan` | Two PAKs |
| `POKEMINI` | `pokemini` | |
| `MSX` | `bluemsx` | Bundled `Machines/` and `Databases/` assets |
| `ATARI2600` | `stella2014` | |
| `MAME2000` | `mame2000` | MAME 0.37b5 ROMset |
| `MAME2003` | `mame2003` | MAME 0.78 ROMset |
| `LYNX` | `handy` | |
| `GME` | `gme` | |

Rows with multiple system names represent multiple PAKs. Refer to `package-paks.sh` for the precise launcher configuration and names.

## Cores available in `Tools/PicoArch.pak` (21)

`beetle-pce-fast`, `bluemsx`, `fceumm`, `fmsx`, `gambatte`, `gngeo`, `gme`, `gpsp`, `handy`, `mame2000`, `mame2003`, `mednafen_ngp`, `mednafen_wswan`, `pcsx_rearmed`, `picodrive`, `pokemini`, `quicknes`, `smsplus-gx`, `snes9x2002`, `snes9x2005`, `stella2014`.

A core being included in Tools does **not** imply that it has a dedicated emulator PAK. In particular, **fMSX, QuickNES, and Snes9x 2002 are compiled and kept in Tools without individual PAKs**.

## Not included in the current Trimui core selection

`mame2003_plus`, `fbalpha2012` (all variants), `snes9x2005_plus`, `snes9x2010`, `fake-08`, and `prboom` are not in the current `platform=trimui` build. Older planning documents mentioned them, but they should not be listed as packaged cores. This fork already provides the standalone Retro8 emulator for PICO-8.

Always check the live MinUI packaging script and PicoArch `Makefile` before changing the emulator list or counts.
