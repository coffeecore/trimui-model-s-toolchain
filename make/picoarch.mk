# -----------------------------------------------------------------------------
# PicoArch - Trimui Model S
# -----------------------------------------------------------------------------
PICOARCH_BUILD := $(WORKSPACE)/build/picoarch

# -----------------------------------------------------------------------------
# Common PicoArch build arguments
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# PicoArch source/build tree and frontend (MinUI)
# -----------------------------------------------------------------------------

# Keep a pinned pristine-ish release checkout under build/release-sources/. The working tree in
# build/picoarch is a full copy of that checkout (including the top-level
# Makefile and upstream patches), so the core targets such as
# The complete PicoArch working tree is used for frontend and core builds.
.PHONY: prepare-picoarch \
	picoarch-frontend picoarch-clean-frontend

prepare-picoarch: source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-prepare \
		PICOARCH_BUILD="$(PICOARCH_BUILD)"

# The frontend and every core now share the same complete PicoArch working tree.
# This is required because the root Makefile owns the *_libretro.so targets.
picoarch-frontend: source-minui minui-libs prepare-picoarch
	$(MAKE) -C "$(MINUI_DIR)" picoarch-frontend \
		PICOARCH_BUILD="$(PICOARCH_BUILD)" \
		SYSROOT="$(TOOLCHAIN_SYSROOT)" \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		MINUI_MMENU_BUILD="$(MINUI_MMENU_BUILD)"

	test -x "$(PICOARCH_BUILD)/picoarch"

# Removing the PicoArch working tree also removes all built cores.
picoarch-clean-frontend:
	rm -rf $(PICOARCH_BUILD)

# -----------------------------------------------------------------------------
# PicoArch output
# -----------------------------------------------------------------------------

PICOARCH_OUTPUT := /workspace/output/picoarch

.PHONY: picoarch-output
picoarch-output: libs source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-output \
		PICOARCH_BUILD="$(PICOARCH_BUILD)" \
		PICOARCH_OUTPUT="$(PICOARCH_OUTPUT)" \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		SYSROOT="$(SYSROOT)"

.PHONY: picoarch-clean-output
picoarch-clean-output: source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-clean-output \
		PICOARCH_OUTPUT="$(PICOARCH_OUTPUT)"

# -----------------------------------------------------------------------------
# PicoArch cores
# -----------------------------------------------------------------------------

.PHONY: picoarch-validated
picoarch-validated: libs source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-validated \
		PICOARCH_BUILD="$(PICOARCH_BUILD)" \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		SYSROOT="$(SYSROOT)"

.PHONY: picoarch-clean-validated
picoarch-clean-validated: source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-clean-validated \
		PICOARCH_BUILD="$(PICOARCH_BUILD)" \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		SYSROOT="$(SYSROOT)"
