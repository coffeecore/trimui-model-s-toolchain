# TODO — Trimui Model S build orchestration

This file tracks **open toolchain-level work only**. MinUI-specific issues belong in the MinUI project, while PicoArch frontend and core issues belong in PicoArch.

## Open items

- [ ] **On-device GnGeo validation:** verify the global horizontal overscan fix on the standalone emulator and libretro core, using ZIP and GNO games, and check for regressions in other Neo Geo titles.
- [ ] **Release binary validation:** check packaged executables and shared libraries for ELF32, ARM, EABI5, expected architecture flags, and runtime dependencies. Keep this separate from packaging behavior.
- [ ] **Release traceability:** emit a manifest recording the exact commits used for the toolchain, MinUI, its submodules, PicoArch, and the GnGeo libretro core.
- [ ] **On-device multi-disc validation:** test `.m3u` files and disc switching through PicoArch/libmmenu on PlayStation, Sega CD, and PC Engine CD before planning any changes.
- [ ] **fMSX redistribution review, if applicable:** confirm the rights to bundle system ROMs before distributing a future release that contains them. The current individual-PAK and Tools packaging does not bundle those ROMs.

## Closed historical items

The old patch migration tasks for `patches/minui`, `patches/gngeo`, and `patches/picoarch` are obsolete: those directories no longer exist in the current toolchain repository. Shared changes now belong in their owning source repositories.

Do not recreate external patches for fixes already integrated upstream in our forks. Refer to the actual Git history when investigating an earlier implementation.
