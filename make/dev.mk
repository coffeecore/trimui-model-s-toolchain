# ==============================================================================
# Development workflow
# ==============================================================================
# /workspace/sources is developer-owned. Targets in this file never checkout,
# reset, clean Git state, or auto-apply project patches to those trees.
#
# Release builds are deliberately isolated under RELEASE_SOURCES_DIR.
#
# Expected development trees:
#   /workspace/sources/minui
#   /workspace/sources/picoarch
#   /workspace/sources/picoarch-cores/<core>
#   /workspace/sources/gngeo-coffeecore
#   /workspace/sources/gngeo-steward-fu

DEV_MINUI_DIR := $(DEV_SOURCES_DIR)/minui
DEV_PICOARCH_DIR := $(DEV_SOURCES_DIR)/picoarch
DEV_PICOARCH_CORES_DIR := $(DEV_SOURCES_DIR)/picoarch-cores

DEV_GNGEO_COFFEECORE_DIR := $(DEV_SOURCES_DIR)/gngeo-coffeecore
DEV_GNGEO_STEWARD_FU_DIR := $(DEV_SOURCES_DIR)/gngeo-steward-fu

DEV_MINUI_LIBS_BUILD := $(WORKSPACE)/build/dev/minui-libs
DEV_MINUI_MSETTINGS_BUILD := $(DEV_MINUI_LIBS_BUILD)/libmsettings
DEV_MINUI_MMENU_BUILD := $(DEV_MINUI_LIBS_BUILD)/libmmenu

DEV_GNGEO_COFFEECORE_OUTPUT_DIR := $(DEV_OUTPUT_DIR)/gngeo-coffeecore
DEV_GNGEO_COFFEECORE_PAK := $(DEV_GNGEO_COFFEECORE_OUTPUT_DIR)/NEOGEO.pak
DEV_GNGEO_STEWARD_FU_OUTPUT_DIR := $(DEV_OUTPUT_DIR)/gngeo-steward-fu
DEV_GNGEO_STEWARD_FU_BINARY := $(DEV_GNGEO_STEWARD_FU_DIR)/gngeo

DEV_PICOARCH_OUTPUT := $(DEV_OUTPUT_DIR)/picoarch

.PHONY: \
	dev-status \
	dev-check-gngeo-coffeecore dev-gngeo-coffeecore dev-clean-gngeo-coffeecore dev-install-gngeo-coffeecore \
	dev-check-gngeo-steward-fu dev-gngeo-steward-fu dev-clean-gngeo-steward-fu dev-install-gngeo-steward-fu \
	dev-gngeo dev-clean-gngeo dev-install-gngeo \
	dev-check-minui dev-minui-libs dev-minui-system dev-minui dev-clean-minui dev-deploy-minui \
	dev-check-picoarch dev-picoarch-frontend dev-picoarch-frontend-with-dev-minui \
	dev-picoarch-output dev-clean-picoarch dev-picoarch-core

# -----------------------------------------------------------------------------
# Status / guards
# -----------------------------------------------------------------------------

dev-status:
	@echo "Development source root: $(DEV_SOURCES_DIR)"
	@echo
	@for dir in gngeo-coffeecore gngeo-steward-fu minui picoarch; do \
		path="$(DEV_SOURCES_DIR)/$$dir"; \
		if [ -d "$$path/.git" ]; then \
			echo "[$$dir]"; \
			git -C "$$path" status --short --branch; \
			echo; \
		elif [ -d "$$path" ]; then \
			echo "[$$dir] present (not a Git worktree)"; \
			echo; \
		else \
			echo "[$$dir] missing: $$path"; \
			echo; \
		fi; \
	done
	@if [ -d "$(DEV_PICOARCH_CORES_DIR)" ]; then \
		echo "[picoarch cores]"; \
		for path in "$(DEV_PICOARCH_CORES_DIR)"/*; do \
			[ -d "$$path" ] || continue; \
			name="$$(basename "$$path")"; \
			if [ -d "$$path/.git" ]; then \
				printf '%s: ' "$$name"; \
				git -C "$$path" status --short --branch | head -n 1; \
			else \
				echo "$$name: present (not a Git worktree)"; \
			fi; \
		done; \
	fi

# -----------------------------------------------------------------------------
# GnGeo - Coffeecore reference port (Autotools)
# -----------------------------------------------------------------------------
# This is the known Trimui Model S port. It remains available as a reference
# while the Steward Fu tree is ported. Nothing here changes its Git state.

dev-check-gngeo-coffeecore:
	@test -d "$(DEV_GNGEO_COFFEECORE_DIR)" || { \
		echo "ERROR: GnGeo Coffeecore development tree not found: $(DEV_GNGEO_COFFEECORE_DIR)" >&2; \
		exit 1; \
	}
	@test -x "$(DEV_GNGEO_COFFEECORE_DIR)/configure" || { \
		echo "ERROR: missing executable configure in $(DEV_GNGEO_COFFEECORE_DIR)" >&2; \
		exit 1; \
	}

dev-gngeo-coffeecore: dev-check-gngeo-coffeecore libs minui-libs
	cd "$(DEV_GNGEO_COFFEECORE_DIR)" && \
	rm -f config.status config.log config.cache && \
	CC="$(GNGEO_CC)" \
	CPP="$(GNGEO_CPP)" \
	AR="$(GNGEO_AR)" \
	RANLIB="$(GNGEO_RANLIB)" \
	STRIP="$(GNGEO_STRIP)" \
	CC_FOR_BUILD=gcc \
	SDL_CONFIG="$(SYSROOT)/usr/bin/sdl-config" \
	CFLAGS="-O3 -Wall -fomit-frame-pointer -ffast-math -I$(SYSROOT)/usr/include" \
	LDFLAGS="-L$(SYSROOT)/usr/lib -ldl" \
	./configure \
		--host=$(TARGET) \
		--disable-sdltest
	cd "$(DEV_GNGEO_COFFEECORE_DIR)" && \
	PATH="$(SYSROOT)/usr/bin:$$PATH" \
	$(MAKE) -j$(JOBS)
	@test -x "$(DEV_GNGEO_COFFEECORE_DIR)/src/gngeo"

dev-clean-gngeo-coffeecore: dev-check-gngeo-coffeecore
	@if [ -f "$(DEV_GNGEO_COFFEECORE_DIR)/Makefile" ]; then \
		cd "$(DEV_GNGEO_COFFEECORE_DIR)" && \
		PATH="$(SYSROOT)/usr/bin:$$PATH" \
		$(MAKE) clean; \
	fi
	rm -f \
		"$(DEV_GNGEO_COFFEECORE_DIR)/config.status" \
		"$(DEV_GNGEO_COFFEECORE_DIR)/config.log" \
		"$(DEV_GNGEO_COFFEECORE_DIR)/config.cache"

dev-install-gngeo-coffeecore: dev-check-gngeo-coffeecore
	@test -x "$(DEV_GNGEO_COFFEECORE_DIR)/src/gngeo" || { \
		echo "ERROR: build first with: make dev-gngeo-coffeecore" >&2; \
		exit 1; \
	}
	@test -d "$(DEV_GNGEO_COFFEECORE_DIR)/trimui-dist/Emus/NEOGEO.pak" || { \
		echo "ERROR: missing Trimui PAK template in $(DEV_GNGEO_COFFEECORE_DIR)" >&2; \
		exit 1; \
	}
	rm -rf "$(DEV_GNGEO_COFFEECORE_OUTPUT_DIR)"
	mkdir -p "$(DEV_GNGEO_COFFEECORE_OUTPUT_DIR)"
	cp -R \
		"$(DEV_GNGEO_COFFEECORE_DIR)/trimui-dist/Emus/NEOGEO.pak" \
		"$(DEV_GNGEO_COFFEECORE_OUTPUT_DIR)/"
	cp \
		"$(DEV_GNGEO_COFFEECORE_DIR)/src/gngeo" \
		"$(DEV_GNGEO_COFFEECORE_PAK)/gngeo"
	@test -e "$(SYSROOT)/usr/lib/libts-1.0.so.0"
	mkdir -p "$(DEV_GNGEO_COFFEECORE_PAK)/lib"
	cp -a $(SYSROOT)/usr/lib/libts-1.0.so* "$(DEV_GNGEO_COFFEECORE_PAK)/lib/"
	@if [ -d "$(SYSROOT)/usr/lib/ts" ]; then \
		cp -a "$(SYSROOT)/usr/lib/ts" "$(DEV_GNGEO_COFFEECORE_PAK)/lib/"; \
	fi
	sed -i '1a\
PAK_DIR="$$(CDPATH= cd -- "$$(dirname -- "$$0")" && pwd)"\
export LD_LIBRARY_PATH="$$PAK_DIR/lib$${LD_LIBRARY_PATH:+:$$LD_LIBRARY_PATH}"\
export TSLIB_PLUGINDIR="$$PAK_DIR/lib/ts"' \
		"$(DEV_GNGEO_COFFEECORE_PAK)/launch.sh"
	sh -n "$(DEV_GNGEO_COFFEECORE_PAK)/launch.sh"

# -----------------------------------------------------------------------------
# GnGeo - Steward Fu GNO base (direct Makefile)
# -----------------------------------------------------------------------------
# The Steward Fu source uses a direct Makefile whose defaults reference the
# Miyoo toolchain. Command-line variables override those defaults, so the source
# Makefile can remain untouched while we build with the Trimui toolchain/sysroot.

dev-check-gngeo-steward-fu:
	@test -d "$(DEV_GNGEO_STEWARD_FU_DIR)" || { \
		echo "ERROR: GnGeo Steward Fu development tree not found: $(DEV_GNGEO_STEWARD_FU_DIR)" >&2; \
		exit 1; \
	}
	@test -f "$(DEV_GNGEO_STEWARD_FU_DIR)/Makefile" || { \
		echo "ERROR: missing Makefile in $(DEV_GNGEO_STEWARD_FU_DIR)" >&2; \
		exit 1; \
	}
	@test -f "$(DEV_GNGEO_STEWARD_FU_DIR)/Makefile.trimui" || { \
		echo "ERROR: missing Makefile.trimui in $(DEV_GNGEO_STEWARD_FU_DIR)" >&2; \
		exit 1; \
	}
	@test -f "$(DEV_GNGEO_STEWARD_FU_DIR)/src/main.c" || { \
		echo "ERROR: unexpected GnGeo Steward Fu tree: missing src/main.c" >&2; \
		exit 1; \
	}

dev-gngeo-steward-fu: dev-check-gngeo-steward-fu minui-libs
	$(MAKE) -C "$(DEV_GNGEO_STEWARD_FU_DIR)" \
		-f Makefile.trimui \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		SYSROOT="$(SYSROOT)" \
		MMENU_DIR="$(MINUI_MMENU_BUILD)" \
		JOBS="$(JOBS)"

dev-clean-gngeo-steward-fu: dev-check-gngeo-steward-fu
	$(MAKE) -C "$(DEV_GNGEO_STEWARD_FU_DIR)" \
		-f Makefile.trimui \
		clean

dev-install-gngeo-steward-fu: dev-check-gngeo-steward-fu
	@test -x "$(DEV_GNGEO_STEWARD_FU_BINARY)" || { \
		echo "ERROR: build first with: make dev-gngeo-steward-fu" >&2; \
		exit 1; \
	}
	rm -rf "$(DEV_GNGEO_STEWARD_FU_OUTPUT_DIR)"
	mkdir -p "$(DEV_GNGEO_STEWARD_FU_OUTPUT_DIR)"
	cp "$(DEV_GNGEO_STEWARD_FU_BINARY)" "$(DEV_GNGEO_STEWARD_FU_OUTPUT_DIR)/gngeo"

# Short aliases intentionally point to the active/new GnGeo port. The explicit
# targets above remain available at all times, so switching implementation is
# never implicit or driven by directory contents.
dev-gngeo: dev-gngeo-steward-fu

dev-clean-gngeo: dev-clean-gngeo-steward-fu

dev-install-gngeo: dev-install-gngeo-steward-fu

# -----------------------------------------------------------------------------
# MinUI
# -----------------------------------------------------------------------------

dev-check-minui:
	@test -f "$(DEV_MINUI_DIR)/Makefile" || { \
		echo "ERROR: MinUI development tree not found: $(DEV_MINUI_DIR)" >&2; \
		exit 1; \
	}
	@test -d "$(DEV_MINUI_DIR)/src/libmmenu" || { \
		echo "ERROR: MinUI submodules/source tree are incomplete: $(DEV_MINUI_DIR)" >&2; \
		exit 1; \
	}

dev-minui-libs: dev-check-minui
	$(MAKE) _build-minui-libs \
		MINUI_SOURCE="$(DEV_MINUI_DIR)" \
		MINUI_LIBS_BUILD="$(DEV_MINUI_LIBS_BUILD)"

dev-minui-system: dev-check-minui
	$(MAKE) _build-minui-system \
		MINUI_DIR="$(DEV_MINUI_DIR)" \
		MINUI_LIBS_TARGET=dev-minui-libs \
		MINUI_LIBS_BUILD="$(DEV_MINUI_LIBS_BUILD)"

dev-minui: dev-check-minui
	$(MAKE) _build-minui \
		MINUI_DIR="$(DEV_MINUI_DIR)" \
		MINUI_LIBS_TARGET=dev-minui-libs \
		MINUI_LIBS_BUILD="$(DEV_MINUI_LIBS_BUILD)"

dev-clean-minui: dev-check-minui
	$(MAKE) clean-build-minui MINUI_DIR="$(DEV_MINUI_DIR)"
	rm -rf "$(DEV_MINUI_LIBS_BUILD)"

# Reuse the proven deploy recipe, but point it at the development payload.
dev-deploy-minui: dev-check-minui
	$(MAKE) deploy-minui \
		MINUI_DEPLOY_SOURCE="$(DEV_MINUI_DIR)/build/PAYLOAD/System"

# -----------------------------------------------------------------------------
# PicoArch frontend and optional core worktrees
# -----------------------------------------------------------------------------

dev-check-picoarch:
	@test -f "$(DEV_PICOARCH_DIR)/Makefile" || { \
		echo "ERROR: PicoArch development tree not found: $(DEV_PICOARCH_DIR)" >&2; \
		exit 1; \
	}

# Default PicoArch development uses the pinned release MinUI libraries. This
# keeps PicoArch development independent from whether a MinUI dev checkout is
# present.
dev-picoarch-frontend: dev-check-picoarch minui-libs
	$(MAKE) _build-picoarch-frontend \
		PICOARCH_BUILD="$(DEV_PICOARCH_DIR)" \
		MINUI_MMENU_BUILD="$(MINUI_MMENU_BUILD)"

# Use this variant only when testing PicoArch together with changes made to the
# developer-owned MinUI/libmmenu tree.
dev-picoarch-frontend-with-dev-minui: dev-check-picoarch dev-minui-libs
	$(MAKE) _build-picoarch-frontend \
		PICOARCH_BUILD="$(DEV_PICOARCH_DIR)" \
		MINUI_MMENU_BUILD="$(DEV_MINUI_MMENU_BUILD)"

# Copy only the development frontend to an isolated output tree.
dev-picoarch-output: dev-check-picoarch
	@test -x "$(DEV_PICOARCH_DIR)/picoarch" || { \
		echo "ERROR: build PicoArch first with: make dev-picoarch-frontend" >&2; \
		exit 1; \
	}
	mkdir -p "$(DEV_PICOARCH_OUTPUT)"
	cp "$(DEV_PICOARCH_DIR)/picoarch" "$(DEV_PICOARCH_OUTPUT)/picoarch"

# Safe clean: remove only top-level build products created by dev targets.
# The source tree, Git state and external core worktrees are untouched.
dev-clean-picoarch: dev-check-picoarch
	rm -f "$(DEV_PICOARCH_DIR)/picoarch"
	find "$(DEV_PICOARCH_DIR)" -maxdepth 1 -type f -name '*_libretro.so' -delete
	rm -rf "$(DEV_PICOARCH_OUTPUT)"

# Build a PicoArch core from a developer-owned source tree without copying or
# resetting it. The PicoArch root Makefile expects the core as a child directory,
# so a temporary symlink is created and removed around the build.
#
# Example:
#   make dev-picoarch-core CORE=mame2000
# For exceptional target names:
#   make dev-picoarch-core CORE=pcsx_rearmed CORE_TARGET=pcsx_rearmed_libretro.so
CORE_TARGET ?= $(CORE)_libretro.so

dev-picoarch-core: dev-check-picoarch
	@test -n "$(CORE)" || { \
		echo "ERROR: CORE is required (example: make dev-picoarch-core CORE=mame2000)" >&2; \
		exit 1; \
	}
	@test -d "$(DEV_PICOARCH_CORES_DIR)/$(CORE)" || { \
		echo "ERROR: core development tree not found: $(DEV_PICOARCH_CORES_DIR)/$(CORE)" >&2; \
		exit 1; \
	}
	@test ! -e "$(DEV_PICOARCH_DIR)/$(CORE)" -a ! -L "$(DEV_PICOARCH_DIR)/$(CORE)" || { \
		echo "ERROR: $(DEV_PICOARCH_DIR)/$(CORE) already exists; refusing to replace it" >&2; \
		exit 1; \
	}
	@set -e; \
	ln -s "$(DEV_PICOARCH_CORES_DIR)/$(CORE)" "$(DEV_PICOARCH_DIR)/$(CORE)"; \
	trap 'rm -f "$(DEV_PICOARCH_DIR)/$(CORE)"' EXIT INT TERM; \
	$(MAKE) -C "$(DEV_PICOARCH_DIR)" \
		$(PICOARCH_MAKE_ARGS) \
		"$(CORE_TARGET)"; \
	test -f "$(DEV_PICOARCH_DIR)/$(CORE_TARGET)"; \
	mkdir -p "$(DEV_PICOARCH_OUTPUT)/cores"; \
	cp "$(DEV_PICOARCH_DIR)/$(CORE_TARGET)" "$(DEV_PICOARCH_OUTPUT)/cores/$(CORE_TARGET)"
