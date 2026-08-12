# -----------------------------------------------------------------------------
# Retro8 / PICO-8
# -----------------------------------------------------------------------------

RETRO8_REPO := https://github.com/coffeecore/retro8.git
RETRO8_BRANCH := trimui-model-s
RETRO8_COMMIT := 6ff2acc19079b07e9aecb20e3cf5e0144d4b8338

RETRO8_DIR := /workspace/sources/retro8

RETRO8_OUTPUT_DIR := $(OUTPUT_DIR)/retro8
RETRO8_PAK := $(RETRO8_OUTPUT_DIR)/PICO-8.pak

.PHONY: \
	retro8 \
	source-retro8 \
	build-retro8 \
	clean-build-retro8 \
	install-retro8 \
	clean-install-retro8 \
	clean-source-retro8

source-retro8:
	@if [ ! -d "$(RETRO8_DIR)/.git" ]; then \
		mkdir -p "$(dir $(RETRO8_DIR))"; \
		git clone \
			--branch "$(RETRO8_BRANCH)" \
			--single-branch \
			"$(RETRO8_REPO)" \
			"$(RETRO8_DIR)"; \
	fi
	cd "$(RETRO8_DIR)" && git checkout --detach "$(RETRO8_COMMIT)"

build-retro8: source-retro8
	cd "$(RETRO8_DIR)" && $(MAKE) -j$(JOBS)
	test -x "$(RETRO8_DIR)/retro8"

clean-build-retro8:
	@if [ -f "$(RETRO8_DIR)/Makefile" ]; then \
		cd "$(RETRO8_DIR)" && $(MAKE) clean; \
	fi

clean-source-retro8:
	rm -rf "$(RETRO8_DIR)"

install-retro8:
	test -x "$(RETRO8_DIR)/retro8"
	rm -rf "$(RETRO8_OUTPUT_DIR)"
	mkdir -p "$(RETRO8_PAK)"
	cp "$(RETRO8_DIR)/retro8" "$(RETRO8_PAK)/retro8"
	printf '%s\n' \
		'#!/bin/sh' \
		'# PICO-8.pak/launch.sh' \
		'' \
		'EMU_EXE=retro8' \
		'EMU_DIR=$$(dirname "$$0")' \
		'ROM_DIR=$${EMU_DIR/.pak/}' \
		'ROM_DIR=$${ROM_DIR/Emus/Roms}' \
		'EMU_NAME=$${ROM_DIR/\/mnt\/SDCARD\/Roms\//}' \
		'ROM=$${1}' \
		'' \
		'HOME="$$ROM_DIR"' \
		'cd "$$EMU_DIR"' \
		'SDL_NOMOUSE=1' \
		'' \
		'"$$EMU_DIR/$$EMU_EXE" "$$ROM" &> "/mnt/SDCARD/.minui/logs/$$EMU_NAME.txt"' \
		> "$(RETRO8_PAK)/launch.sh"
	chmod +x "$(RETRO8_PAK)/launch.sh"

clean-install-retro8:
	rm -rf "$(RETRO8_OUTPUT_DIR)"

retro8:
	$(MAKE) clean-install-retro8
	$(MAKE) clean-build-retro8
	$(MAKE) build-retro8
	$(MAKE) install-retro8
