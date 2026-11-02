# Validation status — Trimui Model S

This document distinguishes **build configuration**, **automated packaging checks**, and **hardware validation**. The previous 24-core inventory was a historical snapshot and included cores since removed from the Trimui selection.

Core revisions are pinned in the PicoArch `Makefile`; **do not duplicate their commit hashes in this document**.

## Current release inventory

- **21 libretro cores** selected by the PicoArch `Makefile` for `platform=trimui`, checked by MinUI `scripts/picoarch/package-tool.sh`.
- **27 PicoArch emulator PAKs**, checked by MinUI `scripts/picoarch/package-paks.sh`.
- **23 base MinUI emulator PAKs**, for **50 Emus PAKs** in the combined release, checked by MinUI packaging rules.
- Separate `Tools/PicoArch.pak` launcher; optional GMenuNX integration with `WITH_GMENUNX=1`.

## Checks already implemented

- Required executables, `.so` cores, skin files, and bundled assets are present; expected PAK/core counts match.
- The release payload has the expected structure, including base remapping PAKs and required directories.
- Each generated release archive passes `unzip -t`.
- `release-fresh` rebuilds from clean `/workspace/libs`, `/workspace/build`, and `/workspace/output` directories without resetting developer-owned sources in `/workspace/sources`.

These checks are **not** exhaustive validation of ARM ABI compatibility, performance, inputs, audio, menus, BIOS loading, save states, ROMsets, or disc switching on the Trimui Model S.

## Open validation work

- Test and document on-device regressions, particularly GnGeo standalone/libretro and horizontally scrolling games.
- Test `.m3u` and disc switching through PicoArch/libmmenu.
- Add automated ELF32/ARM/EABI5/dependency checks for release binaries and a manifest of pinned build revisions (see [`todo.md`](../todo.md)).

See [current systems and PAKs](TRIMUI_MODEL_S_SYSTEMS.md) for the exact selection and [runtime paths and system files](PICOARCH_STEP10.md) for BIOS and directory behavior.
