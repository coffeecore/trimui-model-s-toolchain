# PicoArch / MinUI Legacy — current runtime paths and system files

This document **replaces the former Step 10 planning notes**. It describes the current Trimui Model S package layout, not the old prototype that stored BIOS files beneath `Roms/<System>/.picoarch-<core>/`.

Sources of truth: MinUI `scripts/picoarch/package-paks.sh`, MinUI `scripts/picoarch/package-tool.sh`, the `trimui-model-s` branch of PicoArch, and each core's configuration.

## Runtime directories

PicoArch emulator PAK launchers set:

```text
HOME=/mnt/SDCARD/.minui/picoarch
PICOARCH_SAVE_ROOT=/mnt/SDCARD/Saves/picoarch
PICOARCH_SYSTEM_ROOT=/mnt/SDCARD/Bios/picoarch
PICOARCH_CACHE_ROOT=/mnt/SDCARD/.minui/picoarch/cache
```

Launchers also create their core-specific system directory, for example:

```text
/mnt/SDCARD/Bios/picoarch/gngeo/
/mnt/SDCARD/Bios/picoarch/gpsp/
/mnt/SDCARD/Bios/picoarch/pcsx_rearmed/
```

The launcher for `Tools/PicoArch.pak` sets the first three variables but does **not** explicitly set `PICOARCH_CACHE_ROOT`. Keep this difference in mind when auditing runtime paths.

The separate **GnGeo standalone** PAK uses `/mnt/SDCARD/Bios/gngeo/` (including `neogeo.zip`), not the libretro core's system directory.

## BIOS files and system assets

| System | PicoArch core directory | Requirements / behavior |
|---|---|---|
| PlayStation (`PS`) | `pcsx_rearmed` | If missing, the launcher copies `scph5502.bin` from `/usr/trimui/bin/pcsx_rearmed/bios/scph5502.bin` when available; the core may otherwise use HLE |
| Game Boy Advance (`GBA`) | `gpsp` | `gba_bios.bin` is optional depending on core configuration |
| Sega CD (`SCD`) | `picodrive` | Supply a Sega/Mega CD BIOS matching the game's region |
| PC Engine CD (`PCECD`) | `beetle-pce-fast` | Supply the appropriate System Card BIOS, commonly `syscard3.pce` |
| Neo Geo (`NEOGEO`) | `gngeo` | Supply the appropriate Neo Geo BIOS; do not confuse this with the standalone BIOS directory |
| ColecoVision, SG-1000, MSX | `bluemsx` | `Machines/` and `Databases/` are packaged and installed on first launch |

The packaging script adds `needs-swap` to `GBA`, `PS`, and `NEOGEO`. Do not redistribute copyrighted BIOS or system ROM files without verifying the necessary rights.

## Cores available only in Tools

`fmsx`, `quicknes`, and `snes9x2002` are compiled and included in `Tools/PicoArch.pak`, but have **no dedicated emulator PAK** in the current release.

Although older documents listed bundled fMSX system ROMs, the **current Tools packaging does not copy those ROMs**. Any future redistribution must verify licensing and the required files.

## Content formats and navigation

- ROM, ZIP, and GNO support depends on the selected launcher, libretro core, and ROMset format.
- `.m3u` and disc switching have dedicated code paths, but end-to-end behavior through the in-game menu still needs hardware validation.
- Current ROM folders use **short system names** (`PS`, `SCD`, `PCECD`, `NEOGEO`, etc.), not the descriptive folder names in the older Step 10 notes.
- The Trimui release currently includes **neither FBA 2012 nor MAME 2003 Plus**. Its arcade PAKs target MAME 2000 (0.37b5) and MAME 2003 (0.78).

## Remaining hardware checks

- PlayStation BIOS copy/fallback and Sega CD / PC Engine CD BIOS loading.
- Saves, resumes, and BIOS directory handling for both GnGeo variants and other cores.
- `.m3u` navigation and actual disc switching.
- Regressions from the global horizontal overscan correction in GnGeo, using ZIP and GNO games.

**Passing a packaging check does not mean a feature has been validated on the device.**
