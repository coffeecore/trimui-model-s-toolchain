# ==============================================================================
# MinUI release variants
# ==============================================================================

MINUI_RELEASE_OUTPUT := $(WORKSPACE)/output/minui-release

MINUI_RELEASE_DATE := $(shell TZ=Europe/Paris date +%Y%m%d)
MINUI_RELEASE_BASE := MinUI-$(MINUI_RELEASE_DATE)-0

MINUI_ONLY_ZIP := $(MINUI_DIR)/release/$(MINUI_RELEASE_BASE)-minui.zip
MINUI_PICOARCH_ZIP := $(MINUI_DIR)/release/$(MINUI_RELEASE_BASE)-picoarch.zip

MINUI_PICOARCH_RELEASE_ARGS = \
	PICOARCH_BUILD="$(PICOARCH_BUILD)" \
	PICOARCH_OUTPUT="$(PICOARCH_OUTPUT)" \
	PICOARCH_PAKS_OUTPUT="$(PICOARCH_PAKS_OUTPUT)" \
	PICOARCH_TOOL_OUTPUT="$(PICOARCH_TOOL_OUTPUT)" \
	CROSS_COMPILE="$(CROSS_COMPILE)" \
	SYSROOT="$(TOOLCHAIN_SYSROOT)" \
	MINUI_MMENU_BUILD="$(MINUI_MMENU_BUILD)"


.PHONY: minui-only-release
minui-only-release: build-minui
	$(MAKE) -C "$(MINUI_DIR)" release-minui

	mkdir -p "$(MINUI_RELEASE_OUTPUT)"
	rm -f "$(MINUI_RELEASE_OUTPUT)"/*-minui.zip

	test -f "$(MINUI_ONLY_ZIP)"
	cp "$(MINUI_ONLY_ZIP)" "$(MINUI_RELEASE_OUTPUT)/"


.PHONY: minui-picoarch-release
minui-picoarch-release: build-minui
	$(MAKE) -C "$(MINUI_DIR)" release-picoarch \
		$(MINUI_PICOARCH_RELEASE_ARGS)

	mkdir -p "$(MINUI_RELEASE_OUTPUT)"
	rm -f "$(MINUI_RELEASE_OUTPUT)"/*-picoarch.zip

	test -f "$(MINUI_PICOARCH_ZIP)"
	cp "$(MINUI_PICOARCH_ZIP)" "$(MINUI_RELEASE_OUTPUT)/"


# Keep the historical name for the complete/PicoArch release.
.PHONY: minui-release
minui-release: minui-picoarch-release


.PHONY: minui-releases
minui-releases: build-minui
	$(MAKE) -C "$(MINUI_DIR)" release-all \
		$(MINUI_PICOARCH_RELEASE_ARGS)

	rm -rf "$(MINUI_RELEASE_OUTPUT)"
	mkdir -p "$(MINUI_RELEASE_OUTPUT)"

	test -f "$(MINUI_ONLY_ZIP)"
	test -f "$(MINUI_PICOARCH_ZIP)"

	cp \
		"$(MINUI_ONLY_ZIP)" \
		"$(MINUI_PICOARCH_ZIP)" \
		"$(MINUI_RELEASE_OUTPUT)/"


.PHONY: clean-minui-release
clean-minui-release:
	rm -rf "$(MINUI_RELEASE_OUTPUT)"
	rm -f "$(MINUI_DIR)"/release/*-minui.zip
	rm -f "$(MINUI_DIR)"/release/*-picoarch.zip
