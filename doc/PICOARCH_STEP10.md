# PicoArch / MinUI Legacy — Step 10: System Files, BIOS, Special Cases and ROM Formats

This document records the validated runtime requirements and special cases for the PicoArch PAKs targeting MinUI Legacy on the Trimui Model S.

## Status

Step 10 technical validation: **COMPLETE**

One non-technical point remains open before public redistribution:

- **fMSX bundled ROM files: redistribution rights must be verified before release.**

---

## General runtime layout

Each PicoArch PAK uses the system ROM directory as `HOME`.

PicoArch therefore creates and uses a per-core system directory of the form:

```text
/mnt/SDCARD/Roms/<System>/.picoarch-<core>/
```

Examples:

```text
/mnt/SDCARD/Roms/Famicom Disk System/.picoarch-fceumm/
/mnt/SDCARD/Roms/Sega CD/.picoarch-picodrive/
/mnt/SDCARD/Roms/TurboGrafx-CD/.picoarch-beetle-pce-fast/
/mnt/SDCARD/Roms/PlayStation/.picoarch-pcsx_rearmed/
/mnt/SDCARD/Roms/Doom/.picoarch-prboom/
```

MinUI Legacy hides entries whose names begin with `.`, so these directories do not appear in the game list.

MinUI Legacy does **not** whitelist ROM extensions. Any normal file that is not hidden is listed as a ROM entry.

`.m3u` files receive special handling in MinUI and are used for multi-disc navigation.

---

# Required external system files

## Famicom Disk System

PAK:

```text
Famicom Disk System (FCEUmm).pak
```

Core:

```text
fceumm_libretro.so
```

ROM directory:

```text
/mnt/SDCARD/Roms/Famicom Disk System/
```

Required BIOS:

```text
disksys.rom
```

Expected size:

```text
8192 bytes
```

Destination:

```text
/mnt/SDCARD/Roms/Famicom Disk System/.picoarch-fceumm/disksys.rom
```

The BIOS is required for FDS content and is not distributed with the package.

Supported FDS content:

```text
.fds
```

---

## Sega CD / Mega CD

PAK:

```text
Sega CD (PicoArch).pak
```

Core:

```text
picodrive_libretro.so
```

ROM directory:

```text
/mnt/SDCARD/Roms/Sega CD/
```

System directory:

```text
/mnt/SDCARD/Roms/Sega CD/.picoarch-picodrive/
```

PicoDrive accepts several BIOS base names.

### USA

```text
us_scd2_9306
SegaCDBIOS9303
us_scd1_9210
bios_CD_U
```

### Europe

```text
eu_mcd2_9306
eu_mcd2_9303
eu_mcd1_9210
bios_CD_E
```

### Japan

```text
jp_mcd2_921222
jp_mcd1_9112
jp_mcd1_9111
bios_CD_J
```

Recommended filenames for this package:

```text
bios_CD_U.bin
bios_CD_E.bin
bios_CD_J.bin
```

Example:

```text
/mnt/SDCARD/Roms/Sega CD/
├── Sonic CD.cue
├── Sonic CD.bin
└── .picoarch-picodrive/
    ├── bios_CD_U.bin
    ├── bios_CD_E.bin
    └── bios_CD_J.bin
```

Only the BIOS corresponding to the game region is required.

The BIOS files are not distributed with the package.

Relevant content formats supported by the core include:

```text
.cue
.iso
.chd
.m3u
```

---

## TurboGrafx-CD / PC Engine CD

PAK:

```text
TurboGrafx-CD (PicoArch).pak
```

Core:

```text
beetle-pce-fast_libretro.so
```

ROM directory:

```text
/mnt/SDCARD/Roms/TurboGrafx-CD/
```

Default CD BIOS:

```text
syscard3.pce
```

Destination:

```text
/mnt/SDCARD/Roms/TurboGrafx-CD/.picoarch-beetle-pce-fast/syscard3.pce
```

Other BIOS options supported by the core include:

```text
syscard2.pce
syscard1.pce
gexpress.pce
syscard3u.pce
syscard2u.pce
```

For this package, `syscard3.pce` is the recommended/default BIOS.

The BIOS is not distributed with the package.

Supported content includes:

```text
.pce
.cue
.ccd
.chd
.toc
.m3u
```

---

## Satellaview / BS-X

PAK:

```text
Satellaview (Snes9x 2010).pak
```

Core:

```text
snes9x2010_libretro.so
```

ROM directory:

```text
/mnt/SDCARD/Roms/Satellaview/
```

Recommended BIOS filename:

```text
BS-X.bin
```

Fallback filename supported by the core:

```text
BS-X.bios
```

Destination:

```text
/mnt/SDCARD/Roms/Satellaview/.picoarch-snes9x2010/BS-X.bin
```

The BIOS is not distributed with the package.

---

## Sufami Turbo

PAK:

```text
Sufami Turbo (Snes9x 2010).pak
```

Core:

```text
snes9x2010_libretro.so
```

ROM directory:

```text
/mnt/SDCARD/Roms/Sufami Turbo/
```

Required BIOS:

```text
STBIOS.bin
```

Destination:

```text
/mnt/SDCARD/Roms/Sufami Turbo/.picoarch-snes9x2010/STBIOS.bin
```

### Current PicoArch limitation

SNES9x2010 supports the libretro Sufami Turbo subsystem with separate cartridge A/B slots, but the current PicoArch frontend always uses the normal `retro_load_game()` path.

Therefore this package currently supports:

```text
combined Sufami Turbo images
```

Separate A/B cartridge loading is not supported by the current frontend.

No PicoArch frontend patch is planned for this release.

---

# Special automatic system-file handling

## PlayStation

PAK:

```text
PlayStation (PicoArch).pak
```

Core:

```text
pcsx_rearmed_libretro.so
```

ROM directory:

```text
/mnt/SDCARD/Roms/PlayStation/
```

System directory:

```text
/mnt/SDCARD/Roms/PlayStation/.picoarch-pcsx_rearmed/
```

The launcher checks for the stock Trimui BIOS:

```text
/usr/trimui/bin/pcsx_rearmed/bios/scph5502.bin
```

and copies it when needed to:

```text
/mnt/SDCARD/Roms/PlayStation/.picoarch-pcsx_rearmed/scph5502.bin
```

The PAK also requires:

```text
needs-swap
```

This path still requires confirmation on real Trimui Model S hardware during the hardware-test phase.

PCSX-ReARMed also has an HLE BIOS fallback.

Supported content includes:

```text
.bin
.cue
.img
.mdf
.pbp
.toc
.cbn
.m3u
.chd
```

---

# Optional BIOS files

## Game Boy Advance / gpSP

PAK:

```text
Game Boy Advance (PicoArch).pak
```

Core:

```text
gpsp_libretro.so
```

Optional BIOS:

```text
gba_bios.bin
```

The core can use its built-in open BIOS when an external BIOS is absent or invalid.

No external BIOS is required by this package.

The PAK requires:

```text
needs-swap
```

Supported content:

```text
.gba
.bin
.zip
```

---

## Pokemon Mini

PAK:

```text
Pokemon Mini (PicoArch).pak
```

Core:

```text
pokemini_libretro.so
```

Optional BIOS:

```text
bios.min
```

The core provides an internal FreeBIOS.

No external BIOS is required.

---

## Sega 32X

PAK:

```text
Sega 32X (PicoArch).pak
```

Core:

```text
picodrive_libretro.so
```

PicoDrive contains support for external 32X BIOS files, including:

```text
32X_M_BIOS.BIN
32X_S_BIOS.BIN
```

They are not required for the normal configuration used by this package.

---

# Bundled support assets

## blueMSX

PAKs:

```text
MSX (blueMSX).pak
ColecoVision (blueMSX).pak
SG-1000 (blueMSX).pak
```

Core:

```text
bluemsx_libretro.so
```

Each PAK embeds:

```text
assets/Machines/
assets/Databases/
```

At first launch, these are copied into the system-specific directory.

Runtime destinations:

```text
/mnt/SDCARD/Roms/MSX/.picoarch-bluemsx/
/mnt/SDCARD/Roms/ColecoVision/.picoarch-bluemsx/
/mnt/SDCARD/Roms/SG-1000/.picoarch-bluemsx/
```

The assets are intentionally duplicated between the three PAKs so each package is self-contained.

No additional user-supplied blueMSX system files are required.

---

## fMSX

PAK:

```text
MSX (fMSX).pak
```

Core:

```text
fmsx_libretro.so
```

Bundled files:

```text
DISK.ROM
KANJI.ROM
MSX.ROM
MSX2.ROM
MSX2EXT.ROM
MSX2P.ROM
MSX2PEXT.ROM
```

Runtime destination:

```text
/mnt/SDCARD/Roms/MSX/.picoarch-fmsx/
```

The launcher copies missing files individually on first launch.

### Release blocker

The files come from the pinned fMSX source tree and work technically.

However:

```text
Redistribution rights for these ROM files must be verified before public release.
```

They may be used for the private/test package while this point is unresolved.

---

# Doom / Heretic / Hexen

PAKs:

```text
Doom (PrBoom).pak
Heretic (PrBoom).pak
Hexen (PrBoom).pak
```

Core:

```text
prboom_libretro.so
```

The current core reports support for:

```text
.wad
.iwad
.pwad
.lmp
.m3u
.pk3
.ipk3
.zip
```

MinUI Legacy displays these extensions because it does not filter ROM files by extension.

---

## Doom

Typical IWAD filenames include:

```text
doom.wad
doomu.wad
doom1.wad
doom2.wad
doom2f.wad
plutonia.wad
tnt.wad
freedoom.wad
freedoom1.wad
freedoom2.wad
```

For add-on PWADs, the core attempts to detect whether the maps target Doom 1 (`ExMy`) or Doom 2 (`MAPxx`) and locate a matching IWAD.

IWAD lookup includes:

1. next to the loaded content;
2. `system_dir/prboom/`;
3. `system_dir/`.

Example:

```text
/mnt/SDCARD/Roms/Doom/
├── doom2.wad
└── my_mod.wad
```

An `.m3u` may also explicitly specify the desired IWAD and additional files.

---

## Heretic

Known IWAD candidates include:

```text
heretic.wad
heretic1.wad
blasphem.wad
```

The core contains Heretic-specific PWAD detection so Heretic add-ons are not accidentally paired with Doom IWADs.

Example:

```text
/mnt/SDCARD/Roms/Heretic/
├── heretic.wad
└── my_mod.wad
```

An `.m3u` can be used for explicit IWAD/mod pairing.

---

## Hexen

The core contains actual Hexen game logic, including Hexen game detection, MAPINFO handling, controls and ACS support.

A base game may be launched directly:

```text
/mnt/SDCARD/Roms/Hexen/hexen.wad
```

### Mod limitation

The current automatic PWAD classifier defines:

```text
DOOM1
DOOM2
HERETIC
```

but no dedicated `HEXEN` PWAD classification.

Therefore for Hexen mods, an `.m3u` is recommended.

Example:

```text
hexen-mod.m3u
hexen.wad
my_mod.wad
```

`hexen-mod.m3u`:

```text
hexen.wad
my_mod.wad
```

---

# PICO-8 / Fake-08

PAK:

```text
PICO-8 (Fake-08).pak
```

Core:

```text
fake08_libretro.so
```

ROM directory:

```text
/mnt/SDCARD/Roms/PICO-8/
```

Supported formats:

```text
.p8
.png
```

No external BIOS is required.

The same ROM directory is shared with the standalone Retro8 PAK:

```text
PICO-8.pak
```

This avoids duplicating cartridges.

---

# Arcade

All three PicoArch arcade PAKs use:

```text
/mnt/SDCARD/Roms/Arcade/
```

Arcade ROMs remain zipped.

BIOS/system ROMsets such as:

```text
neogeo.zip
pgm.zip
```

belong in the same Arcade ROM directory.

No generic separate BIOS directory is used.

Whether parent ROM ZIPs are required depends on whether the user's ROM collection is split, merged or non-merged.

---

## MAME 2000

PAK:

```text
Arcade (MAME 2000).pak
```

Core:

```text
mame2000_libretro.so
```

Expected ROMset:

```text
MAME 0.37b5
```

Format:

```text
.zip
```

---

## MAME 2003 Plus

PAK:

```text
Arcade (MAME 2003 Plus).pak
```

Core:

```text
mame2003_plus_libretro.so
```

Base ROMset generation:

```text
MAME 0.78
```

Recommended ROM collection:

```text
MAME 2003-Plus romset matching the core
```

Do not assume that an arbitrary plain MAME 0.78 collection is identical to the current MAME 2003-Plus set, since MAME 2003 Plus contains additions and backports.

Format:

```text
.zip
```

---

## FB Alpha 2012

PAK:

```text
Arcade (FBA 2012).pak
```

Core:

```text
fbalpha2012_libretro.so
```

The compiled core reports:

```text
FB Alpha 2012
v0.2.97.29
```

Pinned source revision:

```text
0ce31536bef3162fe7e69ff5f555334ec4913cef
```

Expected ROMset:

```text
FB Alpha 0.2.97.29
```

Format:

```text
.zip
```

---

# MinUI ROM visibility

MinUI Legacy's ROM browser does not use a per-system extension whitelist.

Normal files are inserted as ROM entries regardless of extension.

Therefore the custom PAKs can expose all formats supported by their cores, including:

```text
.p8
.png
.bsx
.wad
.iwad
.pwad
.pk3
.ipk3
.zip
.cue
.chd
.m3u
```

without modifying MinUI.

Directories beginning with `.` are hidden, which keeps all `.picoarch-*` runtime directories out of the game browser.

---

# Multi-disc support

MinUI Legacy has explicit `.m3u` handling.

The following PicoArch cores support `.m3u` content:

```text
beetle-pce-fast
bluemsx
pcsx_rearmed
picodrive
prboom
```

PicoArch implements the libretro disk-control callbacks.

Actual disc switching through the MinUI/mmenu integration still requires validation on real Trimui Model S hardware.

---

# Systems with no required external BIOS identified

No required external system file is currently identified for the following PicoArch PAKs:

```text
Nintendo (FCEUmm)
Nintendo (QuickNES)
Game Boy
Game Boy Color
Game Boy Advance
Game Gear
Master System
Genesis
Sega 32X
Super Nintendo (Snes9x 2002)
Super Nintendo (Snes9x 2005)
Super Nintendo (Snes9x 2005 Plus)
Super Nintendo (Snes9x 2010)
Neo Geo Pocket
Neo Geo Pocket Color
WonderSwan
WonderSwan Color
Pokemon Mini
MSX (blueMSX)
ColecoVision (blueMSX)
SG-1000 (blueMSX)
Atari 2600
Game Music
PICO-8 (Fake-08)
Doom
Heretic
Hexen
Arcade (MAME 2000)
Arcade (MAME 2003 Plus)
Arcade (FBA 2012)
```

Notes:

- GBA may optionally use `gba_bios.bin`.
- Pokemon Mini may optionally use `bios.min`.
- Sega 32X may use external BIOS files, but they are not required by the selected configuration.
- blueMSX support assets are bundled inside the PAKs.
- Doom/Heretic/Hexen IWADs are game content, not emulator BIOS files.
- Arcade BIOS ZIPs are part of the corresponding ROMsets.

---

# Open items for later steps

## Before public release

- Verify redistribution rights for the ROM files bundled with fMSX.

## Hardware validation

Confirm on a real Trimui Model S:

- PS1 NAND BIOS path and automatic copy;
- `needs-swap` behavior for gpSP;
- `needs-swap` behavior for PCSX-ReARMed;
- MinUI/mmenu exit behavior for PicoArch;
- save/config/system directory behavior;
- `.m3u` multi-disc navigation and disc switching;
- FDS BIOS loading;
- Sega CD BIOS loading for supported regions;
- TurboGrafx-CD `syscard3.pce`;
- Satellaview `BS-X.bin`;
- Sufami Turbo combined-image loading;
- representative games from each arcade romset.

---

# Step 10 result

```text
[OK] FDS BIOS
[OK] Sega CD BIOS
[OK] TurboGrafx-CD BIOS
[OK] PS1 BIOS copy strategy
[OK] GBA BIOS fallback
[OK] Satellaview
[OK] Sufami Turbo combined-image limitation documented
[OK] blueMSX assets
[OK] fMSX technically packaged
[OPEN] fMSX ROM redistribution rights
[OK] PICO-8 / Fake-08
[OK] Doom / Heretic / Hexen
[OK] MAME 2000 romset
[OK] MAME 2003 Plus romset guidance
[OK] FB Alpha 2012 romset version
[OK] MinUI extension visibility
[OK] hidden .picoarch-* directories
[OK] MinUI .m3u handling
```

**Step 10 technical validation is complete.**
