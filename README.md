# Trimui Model S — MinUI Legacy + PicoArch build

This repository orchestrates the builds and releases for the Trimui Model S. MinUI, the standalone emulators, PicoArch, its libretro cores, and their packaging rules remain in their respective source repositories.

Releases use **pinned Git revisions**, not arbitrary modifications in `/workspace/sources`.

## Build a release

From `/workspace` inside the `builder` container:

```sh
make help
make preflight
make release-fresh WITH_GMENUNX=1
```

`release-fresh` removes and rebuilds `/workspace/libs`, `/workspace/build`, and `/workspace/output`. It does **not** reset developer checkouts under `/workspace/sources`.

It produces both the MinUI-only and MinUI + PicoArch variants under `/workspace/output/minui-release/`.

`WITH_GMENUNX=1` includes the GMenuNX tool in the releases; `WITH_GMENUNX=0` omits it. Use `make help-release` or `make help-dev` to find narrower targets that avoid rebuilding everything.

## Git revisions and ownership

- `make/minui.mk` → `MINUI_COMMIT`: the MinUI revision used for release source checkouts.
- MinUI `third-party/gngeo`: the **standalone** GnGeo submodule (based on `trimui-model-s`).
- MinUI `third-party/picoarch`: the PicoArch submodule (based on `trimui-model-s`).
- PicoArch `Makefile` → `gngeo_REVISION`: the **libretro** GnGeo revision (branch `libretro`).
- GnGeo `libretro` receives shared fixes by merging `trimui-model-s`; do not maintain duplicate copies of common fixes.

A change to a child repository will **not** reach the next pinned release until the relevant parent reference has been updated.

## Documentation

- [Current systems, PAKs, and cores](doc/TRIMUI_MODEL_S_SYSTEMS.md)
- [Runtime paths, BIOS files, and special cases](doc/PICOARCH_STEP10.md)
- [Build and hardware validation status](doc/VALIDATED.md)
- [Open toolchain tasks](todo.md)

**Sources of truth:** the MinUI `makefile`, MinUI `scripts/picoarch/package-paks.sh`, MinUI `scripts/picoarch/package-tool.sh`, the PicoArch `Makefile`, and this repository's `make/*.mk`. These documents summarize their behavior; they do not define it.
