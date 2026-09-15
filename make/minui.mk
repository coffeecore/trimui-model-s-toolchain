# ==============================================================================
# MinUI Legacy - Trimui Model S
# ==============================================================================
# MinUI is kept completely upstream-clean. Compatibility fixes live here in the
# orchestration layer instead of modifying MinUI or its submodules.

MINUI_REPO := https://github.com/coffeecore/MinUI-Legacy-Trimui-Model-S.git
MINUI_BRANCH := picoarch
MINUI_COMMIT := 12382bf83777eeaa333b2f320423047d1d43c18a
MINUI_DIR := $(RELEASE_SOURCES_DIR)/minui

MINUI_PICODRIVE_DIR := $(MINUI_DIR)/third-party/picodrive
MINUI_BUILD_DIR := $(MINUI_DIR)/build
MINUI_PAYLOAD_DIR := $(MINUI_BUILD_DIR)/PAYLOAD
MINUI_ROMS_DIR := $(MINUI_BUILD_DIR)/Roms

MINUI_TOOLCHAIN := $(TOOLCHAIN)
MINUI_SYSROOT := $(TOOLCHAIN_SYSROOT)
MINUI_PREFIX := $(MINUI_SYSROOT)/usr
MINUI_CROSS := $(CROSS_COMPILE)

ADB ?= adb
MINUI_LIBS_TARGET ?= minui-libs

MINUI_DEPLOY_SOURCE ?= $(MINUI_DIR)/build/PAYLOAD/System
MINUI_DEPLOY_STAGE := /mnt/SDCARD/.minui-dev
MINUI_DEVICE_SYSTEM := /mnt/SDCARD/System

.PHONY: build-minui build-minui-system _build-minui _build-minui-system clean-build-minui source-minui clean-source-minui minui deploy-minui

deploy-minui:
	@test -d "$(MINUI_DEPLOY_SOURCE)" || { \
		echo "ERROR: MinUI build not found: $(MINUI_DEPLOY_SOURCE)" >&2; \
		exit 1; \
	}

	@command -v "$(ADB)" >/dev/null || { \
		echo "ERROR: adb not found" >&2; \
		exit 1; \
	}

	@"$(ADB)" get-state >/dev/null 2>&1 || { \
		echo "ERROR: TrimUI not connected through ADB" >&2; \
		exit 1; \
	}

	"$(ADB)" shell rm -rf "$(MINUI_DEPLOY_STAGE)"
	"$(ADB)" shell mkdir -p "$(MINUI_DEPLOY_STAGE)"

	"$(ADB)" push -a \
		"$(MINUI_DEPLOY_SOURCE)" \
		"$(MINUI_DEPLOY_STAGE)/"

	"$(ADB)" shell '\
		set -e; \
		SRC="$(MINUI_DEPLOY_STAGE)/System"; \
		DST="$(MINUI_DEVICE_SYSTEM)"; \
		find "$$SRC" -type d | while IFS= read -r path; do \
			rel="$${path#$$SRC}"; \
			mkdir -p "$$DST$$rel"; \
		done; \
		find "$$SRC" ! -type d | while IFS= read -r path; do \
			rel="$${path#$$SRC}"; \
			mkdir -p "$$(dirname "$$DST$$rel")"; \
			mv -f "$$path" "$$DST$$rel"; \
		done; \
		rm -rf "$(MINUI_DEPLOY_STAGE)"; \
		sync'

minui: source-minui
	$(MAKE) clean-build-minui
	$(MAKE) build-minui

source-minui:
	@if [ ! -d "$(MINUI_DIR)/.git" ]; then \
		mkdir -p "$(dir $(MINUI_DIR))"; \
		git clone \
			--branch "$(MINUI_BRANCH)" \
			$(MINUI_REPO) \
			$(MINUI_DIR); \
		git -C "$(MINUI_DIR)" checkout "$(MINUI_COMMIT)"; \
	fi

	# Certains submodules upstream utilisent des URLs SSH GitHub.
	# On les réécrit temporairement en HTTPS sans modifier .gitmodules.
	cd "$(MINUI_DIR)" && \
		git \
			-c url."https://github.com/".insteadOf="git@github.com:" \
			-c url."https://github.com/".insteadOf="ssh://git@github.com/" \
			submodule update --init --recursive --jobs=$(JOBS)

clean-source-minui:
	rm -rf $(MINUI_DIR)

# Build only MinUI itself and its shared libraries.
# Intended for fast development iterations without rebuilding bundled emulators.
build-minui-system: source-minui
	$(MAKE) _build-minui-system

_build-minui-system: libs
	$(MAKE) -C $(MINUI_DIR) readme

	# Keep upstream MinUI system/SDL on the vendor SDK sysroot.
	$(MAKE) -C $(MINUI_DIR) sys \
		CROSS_COMPILE="$(MINUI_CROSS)" \
		PREFIX="$(MINUI_PREFIX)"

	# Rebuild MinUI libraries from the current MinUI source tree.
	$(MAKE) $(MINUI_LIBS_TARGET)

	# Replace the libraries packaged by upstream `sys` with our
	# reproducible orchestration builds.
	cp \
		$(MINUI_LIBS_BUILD)/libmsettings/libmsettings.so \
		$(MINUI_PAYLOAD_DIR)/System/lib/libmsettings.so

	cp \
		$(MINUI_LIBS_BUILD)/libmmenu/libmmenu.so \
		$(MINUI_PAYLOAD_DIR)/System/lib/libmmenu.so

# Reproduce the upstream build order. The only manually expanded emulator target
# is PicoDrive (`gen`) because MinUI references platform/trimui/skin, while the
# pinned PicoDrive commit actually provides platform/opendingux/data/skin.
build-minui: source-minui
	$(MAKE) _build-minui

_build-minui: _build-minui-system
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
        PATH="$(MINUI_TOOLCHAIN)/usr/bin:$$PATH" \
        CROSS_COMPILE="$(MINUI_CROSS)" \
        PREFIX="$(MINUI_PREFIX)" \
        SYSROOT="$(MINUI_SYSROOT)" \
        PKG_CONFIG_SYSROOT_DIR="$(MINUI_SYSROOT)" \
        PKG_CONFIG_LIBDIR="$(MINUI_PREFIX)/lib/pkgconfig" \
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
	$(MAKE) -C $(MINUI_DIR)/src/libmmenu clean \
		CROSS_COMPILE="$(MINUI_CROSS)" \
		PREFIX="$(MINUI_PREFIX)"
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
