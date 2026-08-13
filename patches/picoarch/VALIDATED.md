# PicoArch - validated Trimui Model S builds

PicoArch:

- commit: 53e0e6b2b72b8c50e6b9fceb437dfa8c650d05c5
- libpicofe: dd11f2d723162eb1cf8e6db9f40de7db0d0b6bba
- libretro-common: 76a3d54feb0ee0ce9d59b90aa24694f3782063d3

Target:

- Trimui Model S
- CPU: ARM926EJ-S
- architecture: ARMv5TEJ
- ABI: EABI5
- float ABI: soft
- endian: little

## Validated cores

### FCEUmm

Commit:

    b5e3566515c27dc66c9c20572171673126532e06

Patches:

    picoarch upstream: 1000-trimui-build.patch

Status:

    validated


### Gambatte

Commit:

    96174369b3c30d9fc57c926fa3379c273dc6a9a5

Patches:

    picoarch upstream: 0001-ghosting-fastest.patch
    picoarch upstream: 1000-trimui-build.patch

Notes:

    Explicit ARM cross CXX is required.

Status:

    validated


### gpSP

Commit:

    5b6e751f4abf368509146cd143c949c1946ac1ae

Patches:

    picoarch upstream: 1000-trimui-build.patch
    picoarch upstream: 1002-frameskip-changes.patch

Status:

    validated


### PicoDrive

Commit:

    6248b51ffbe212ce441de023ccea6b10fa4d7082

Patches:

    picoarch upstream: 0001-frameskip-interval.patch
    picoarch upstream: 1000-trimui-build.patch

Notes:

    cpu/cyclone/cyclone_gen is a host build tool.
    Cyclone.s must therefore be generated natively with host gcc/g++
    before cross-compiling the libretro core.

Status:

    validated


### MAME 2000

Commit:

    f099ba44c7664906fd7e01cbed89d13a7e32dee1

Patches:

    picoarch upstream: 0002-arm-generic-target.patch
    external port: patches/picoarch/mame2000/0004-rotation.patch
    picoarch upstream: 1000-trimui-build.patch
    picoarch upstream: 1002-reduce-vector-game-res.patch

Notes:

    The original rotation patch no longer applied because modern
    core options moved to src/libretro/libretro_core_options.h.
    The external patch is the port to the current core.

Status:

    validated


### PCSX-ReARMed

Commit:

    da2cb8ecd17fd0932ab6d94774c0522beebce6e3

Submodule:

    frontend/libpicofe:
    dd11f2d723162eb1cf8e6db9f40de7db0d0b6bba

Patch:

    patches/picoarch/pcsx_rearmed/1000-trimui-support.patch

Notes:

    Modern Trimui port keeps:
    - Trimui Makefile.libretro platform
    - ARM926EJ-S
    - GPU UNAI
    - ari64 dynarec
    - Trimui dithering default
    - Trimui frontend/main.c behaviour

    Old PSX clock-specific changes were intentionally not carried
    forward because the current core already implements modern
    automatic clock handling.

Status:

    validated


### Beetle PCE Fast

Commit:

    b211204c7026dff6e86e79b00185512e2421fff8

Patches:

    external port:
    patches/picoarch/beetle-pce-fast/0001-frameskip-interval.patch

    picoarch upstream:
    1000-trimui-build.patch

Notes:

    Upstream renamed libretro.cpp to libretro.c.
    The external frameskip patch only adapts this filename;
    all hunks otherwise apply to the current core.

Status:

    validated

### blueMSX

Commit:

    0f32f52c48d3e772bfdf0379756f81f00b4e08bc

Patch:

    picoarch upstream: 1000-trimui-build.patch

Notes:

    Current upstream patch applies cleanly with line offsets only.
    Build emits a non-fatal aggressive-loop-optimizations warning
    in Src/SoundChips/Fmopl.c.

Status:

    validated

### fMSX

Commit:

    f013e213458e06d9df718e4bc4b09d46f88aa899

Patch:

    picoarch upstream: 1000-trimui-build.patch

Notes:

    Current upstream patch applies cleanly with line offsets only.

Status:

    validated

### GME

Commit:

    1562f6207a066e9807243c89648d1cb44e411971

Patch:

    picoarch upstream: 1000-trimui-build.patch

Notes:

    Current upstream patch applies cleanly with a line offset.
    Resulting shared object is stripped by the current build.

Status:

    validated

### Mednafen NGP

Commit:

    a50d5ac288a81f2104ddf43195a4efdd15c72227

Patch:

    external:
    patches/picoarch/mednafen_ngp/1000-trimui-build.patch

Notes:

    No Trimui support existed upstream in the current core.
    Added a minimal Trimui platform block using:
    - ARM926EJ-S
    - ARMv5TEJ
    - soft-float
    - no NEON
    - no ARMv6/ARMv7-specific flags

Status:

    validated

### Mednafen WonderSwan

Commit:

    4b01295838ea89e3f1355bbe4cb5cf98aa6108cd

Patch:

    external:
    patches/picoarch/mednafen_wswan/1000-trimui-build.patch

Notes:

    Current upstream already contains a Miyoo ARMv5TE/ARM926EJ-S platform.
    The Trimui port reuses the same architecture assumptions while using
    the project CROSS_COMPILE toolchain and targeting ARM926EJ-S explicitly.

Status:

    validated

### PokeMini

Commit:

    132111b76343559860532a1ccc094f93f1ed5650

Patch:

    external:
    patches/picoarch/pokemini/1000-trimui-build.patch

Notes:

    Current upstream already provides a Miyoo ARMv5TE / ARM926EJ-S target.
    The Trimui port reuses the same architecture assumptions but uses
    CROSS_COMPILE and removes Dingux/RS90-specific defines.

Status:

    validated
