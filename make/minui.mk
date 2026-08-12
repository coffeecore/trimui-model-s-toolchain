# ==============================================================================
# MinUI Legacy - Trimui Model S
# ==============================================================================
# MinUI is kept completely upstream-clean. Compatibility fixes live here in the
# orchestration layer instead of modifying MinUI or its submodules.

MINUI_DIR := $(WORKSPACE)/sources/minui
MINUI_PICODRIVE_DIR := $(MINUI_DIR)/third-party/picodrive
MINUI_BUILD_DIR := $(MINUI_DIR)/build
MINUI_PAYLOAD_DIR := $(MINUI_BUILD_DIR)/PAYLOAD
MINUI_ROMS_DIR := $(MINUI_BUILD_DIR)/Roms

.PHONY: build-minui clean-build-minui

# Reproduce the upstream build order. The only manually expanded emulator target
# is PicoDrive (`gen`) because MinUI references platform/trimui/skin, while the
# pinned PicoDrive commit actually provides platform/opendingux/data/skin.
build-minui:
	$(MAKE) -C $(MINUI_DIR) readme
	$(MAKE) -C $(MINUI_DIR) sys

	$(MAKE) -C $(MINUI_DIR) gb
	$(MAKE) -C $(MINUI_DIR) pm
	$(MAKE) -C $(MINUI_DIR) ngp
	$(MAKE) -C $(MINUI_DIR) gg
	$(MAKE) -C $(MINUI_DIR) snes
	$(MAKE) -C $(MINUI_DIR) ps
	$(MAKE) -C $(MINUI_DIR) gba
	$(MAKE) -C $(MINUI_DIR) nes

	# PicoDrive equivalent of MinUI's `gen` target.
	mkdir -p "$(MINUI_ROMS_DIR)/Genesis"
	mkdir -p "$(MINUI_PAYLOAD_DIR)/Emus"

	@if [ ! -f "$(MINUI_PICODRIVE_DIR)/config.mak" ]; then \
		cd "$(MINUI_PICODRIVE_DIR)" && \
		CROSS_COMPILE=$(COMPAT_BIN)/$(COMPAT_TARGET)- \
			./configure --platform=trimui; \
	fi

	# PicoDrive's Makefile uses PWD directly, therefore `cd && make` is required.
	# `make -C` produces incorrect internal include paths for this revision.
	cd "$(MINUI_PICODRIVE_DIR)" && $(MAKE) -j$(JOBS)

	rm -rf "$(MINUI_PAYLOAD_DIR)/Emus/Genesis.pak"
	cp -R \
		"$(MINUI_DIR)/paks/Genesis.pak" \
		"$(MINUI_PAYLOAD_DIR)/Emus"
	cp \
		"$(MINUI_PICODRIVE_DIR)/PicoDrive" \
		"$(MINUI_PAYLOAD_DIR)/Emus/Genesis.pak"

	# MinUI expects a Trimui skin directory that does not exist in the pinned
	# PicoDrive commit. Copy the equivalent OpenDingux skin into the generated
	# payload only; the upstream checkout remains untouched.
	mkdir -p "$(MINUI_PAYLOAD_DIR)/Emus/Genesis.pak/skin"
	cp -R \
		"$(MINUI_PICODRIVE_DIR)/platform/opendingux/data/skin/." \
		"$(MINUI_PAYLOAD_DIR)/Emus/Genesis.pak/skin/"

	$(MAKE) -C $(MINUI_DIR) pce
	$(MAKE) -C $(MINUI_DIR) swan
	$(MAKE) -C $(MINUI_DIR) lynx

	$(MAKE) -C $(MINUI_DIR) tools
	$(MAKE) -C $(MINUI_DIR) zip

# MinUI's upstream global clean is not fully idempotent (notably Oswan), and it
# omits Handy. Clean each verified component explicitly instead of suppressing
# arbitrary errors with `-make` or `|| true`.
clean-build-minui:
	# MinUI system
	$(MAKE) -C $(MINUI_DIR)/src/libmmenu clean
	$(MAKE) -C $(MINUI_DIR)/src/MinUI clean
	$(MAKE) -C $(MINUI_DIR)/src/show clean
	$(MAKE) -C $(MINUI_DIR)/src/confirm clean
	$(MAKE) -C $(MINUI_DIR)/src/flipbook clean
	$(MAKE) -C $(MINUI_DIR)/TrimuiUpdate clean

	# libmsettings and keymon are not cleaned by upstream clean-sys.
	rm -f \
		$(MINUI_DIR)/src/libmsettings/msettings.o \
		$(MINUI_DIR)/src/libmsettings/libmsettings.so \
		$(MINUI_DIR)/src/keymon/keymon

	# Embedded SDL: upstream tries `make distclean`. It is only valid after SDL
	# has generated a Makefile, so call it conditionally. Remove the three known
	# generated leftovers as well (verified with `git clean -ndx`).
	@if [ -f "$(MINUI_DIR)/third-party/SDL-1.2/Makefile" ]; then \
		cd "$(MINUI_DIR)/third-party/SDL-1.2" && $(MAKE) distclean; \
	fi
	rm -f \
		$(MINUI_DIR)/third-party/SDL-1.2/SDL.spec \
		$(MINUI_DIR)/third-party/SDL-1.2/include/SDL_config.h \
		$(MINUI_DIR)/third-party/SDL-1.2/sdl.pc

	# Tools
	$(MAKE) -C $(MINUI_DIR)/third-party/DinguxCommander clean

	# Emulators with reliable upstream clean targets
	$(MAKE) -C $(MINUI_DIR)/third-party/gambatte-dms clean
	$(MAKE) -C $(MINUI_DIR)/third-party/pokemini/platform/trimui clean
	$(MAKE) -C $(MINUI_DIR)/third-party/race clean
	$(MAKE) -C $(MINUI_DIR)/third-party/sms_sdl clean
	$(MAKE) -C $(MINUI_DIR)/third-party/snes9x2002 clean
	$(MAKE) -C $(MINUI_DIR)/third-party/pcsx_rearmed clean
	$(MAKE) -C $(MINUI_DIR)/third-party/picogpsp clean
	$(MAKE) -C $(MINUI_DIR)/third-party/fceux clean

	# PicoDrive again requires `cd && make` because of its PWD usage.
	cd "$(MINUI_PICODRIVE_DIR)" && $(MAKE) clean

	$(MAKE) -C $(MINUI_DIR)/third-party/temper/SDL clean

	# Oswan's clean uses plain `rm` and fails when files are already absent.
	# Delete exactly the artifacts listed by that clean rule, but idempotently.
	rm -f \
		$(MINUI_DIR)/third-party/oswan/main/sdl/main.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/menu.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/input.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/game_input.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/cpu/nec.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/WS.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/WSFileio.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/WSRender.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/WSApu.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/gui_drawing.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/drawing.o \
		$(MINUI_DIR)/third-party/oswan/oswan

	# Handy has a verified idempotent `rm -f` clean target.
	$(MAKE) -C $(MINUI_DIR)/third-party/handy-rs97 clean

	# Generated MinUI package trees.
	rm -rf $(MINUI_DIR)/build
	rm -rf $(MINUI_DIR)/release
