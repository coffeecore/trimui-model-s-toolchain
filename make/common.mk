# ==============================================================================
# Common configuration
# ==============================================================================
# Shared paths and settings used by every build fragment.

WORKSPACE := /workspace

# Number of parallel jobs. Defaults to every CPU visible inside the container.
# Override from the command line, e.g. `make build-minui JOBS=4`.
JOBS ?= $(shell nproc)
JOBS := 4

TARGET := arm-buildroot-linux-gnueabi

TOOLCHAIN := /opt/trimui-toolchain
TOOLCHAIN_BIN := $(TOOLCHAIN)/bin
TOOLCHAIN_SYSROOT := $(TOOLCHAIN)/usr/arm-buildroot-linux-gnueabi/sysroot

CROSS_COMPILE := $(TOOLCHAIN_BIN)/$(TARGET)-
SYSROOT := $(TOOLCHAIN_SYSROOT)

# Reserved for final packaged artifacts. Once every standalone emulator and
# PicoArch is handled, a global release target can collect their packages here.
OUTPUT_DIR := $(WORKSPACE)/output
FINAL_RELEASE_DIR := $(OUTPUT_DIR)/release
