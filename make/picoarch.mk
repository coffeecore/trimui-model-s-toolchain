# -----------------------------------------------------------------------------
# PicoArch - Trimui Model S
# -----------------------------------------------------------------------------

PICOARCH_BUILD := $(WORKSPACE)/build/picoarch

PICOARCH_PAKS_OUTPUT := $(WORKSPACE)/output/picoarch-paks
PICOARCH_TOOL_OUTPUT := $(WORKSPACE)/output/picoarch-tool

# -----------------------------------------------------------------------------
# PicoArch source/build tree and frontend
# -----------------------------------------------------------------------------

.PHONY: prepare-picoarch \
	picoarch-frontend picoarch-clean-frontend

# MinUI owns the PicoArch source and prepares the shared working tree.
prepare-picoarch: source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-prepare \
		PICOARCH_BUILD="$(PICOARCH_BUILD)"

# MinUI owns the frontend build. The toolchain only provides its environment.
picoarch-frontend: source-minui minui-libs prepare-picoarch
	$(MAKE) -C "$(MINUI_DIR)" picoarch-frontend \
		PICOARCH_BUILD="$(PICOARCH_BUILD)" \
		SYSROOT="$(TOOLCHAIN_SYSROOT)" \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		MINUI_MMENU_BUILD="$(MINUI_MMENU_BUILD)"

	test -x "$(PICOARCH_BUILD)/picoarch"

# Removing the shared working tree also removes its built frontend and cores.
picoarch-clean-frontend:
	rm -rf "$(PICOARCH_BUILD)"

# -----------------------------------------------------------------------------
# PicoArch cores
# -----------------------------------------------------------------------------

.PHONY: picoarch-validated picoarch-clean-validated

picoarch-validated: libs source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-validated \
		PICOARCH_BUILD="$(PICOARCH_BUILD)" \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		SYSROOT="$(SYSROOT)"

picoarch-clean-validated: source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-clean-validated \
		PICOARCH_BUILD="$(PICOARCH_BUILD)" \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		SYSROOT="$(SYSROOT)"
