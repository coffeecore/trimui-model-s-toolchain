# ==============================================================================
# Common configuration
# ==============================================================================
# Shared paths and settings used by every build fragment.

WORKSPACE := /workspace

# Source trees are deliberately split by purpose:
# - sources/ is owned by the developer and is never modified by release targets.
# - build/release-sources/ contains disposable, pinned checkouts used for releases.
DEV_SOURCES_DIR := $(WORKSPACE)/sources
RELEASE_SOURCES_DIR := $(WORKSPACE)/build/release-sources

# Number of parallel jobs. Keep a conservative default for the Trimui build
# environment, while allowing command-line overrides (e.g. `JOBS=8`).
JOBS ?= 6

TARGET := arm-buildroot-linux-gnueabi

TOOLCHAIN := /opt/trimui-toolchain
TOOLCHAIN_BIN := $(TOOLCHAIN)/bin
TOOLCHAIN_SYSROOT := $(TOOLCHAIN)/usr/arm-buildroot-linux-gnueabi/sysroot

# The vendor Buildroot sysroot is the base SDK used by upstream MinUI. Our
# rebuilt common libraries live in BUILD_SYSROOT so they cannot replace the SDK's
# libc/SDL/libpng stack. Upstream MinUI may install its own msettings/mmenu there.
BUILD_SYSROOT := $(WORKSPACE)/build/sysroot

CROSS_COMPILE := $(TOOLCHAIN_BIN)/$(TARGET)-
SYSROOT := $(BUILD_SYSROOT)

# Reserved for final packaged artifacts. Once every standalone emulator and
# PicoArch is handled, a global release target can collect their packages here.
OUTPUT_DIR := $(WORKSPACE)/output
DEV_OUTPUT_DIR := $(OUTPUT_DIR)/dev
FINAL_RELEASE_DIR := $(OUTPUT_DIR)/release
