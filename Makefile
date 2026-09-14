# ==============================================================================
# Trimui Model S build environment
# ==============================================================================
# This root Makefile intentionally stays small. Implementation details live in
# make/*.mk so each component can evolve independently.
#
# Parallelism defaults to all available CPUs. Override without editing files:
#   make libs JOBS=4
#   make build-minui JOBS=4

.DEFAULT_GOAL := help

include make/common.mk
include make/libs.mk
include make/minui.mk
include make/arnold.mk
include make/stella.mk
include make/gngeo.mk
include make/retro8.mk
include make/picoarch.mk
include make/picoarch-tool.mk
include make/picoarch-paks.mk
include make/standalone-paks.mk
include make/minui-extra-paks.mk
include make/minui-release.mk
include make/minui-libs.mk
include make/mame4allx.mk

.PHONY: help shell preflight release-all release-fresh

# Show the high-level commands intended for normal use.
help:
	@echo "Trimui Model S build environment"
	@echo
	@echo "Main targets:"
	@echo "  minui                    Clean and build MinUI Legacy"
	@echo "  arnold                   Clean, build and install Arnold"
	@echo "  stella                   Clean, build and install Stella"
	@echo "  gngeo                    Clean, build and install GnGeo"
	@echo "  retro8                   Clean, build and install Retro8"
	@echo "  picoarch-validated       Build all validated PicoArch cores"
	@echo "  picoarch-frontend        Build PicoArch frontend"
	@echo "  picoarch-output          Collect PicoArch frontend + cores"
	@echo "  picoarch-paks            Build the 35 PicoArch MinUI PAKs"
	@echo "  standalone-paks          Package the 4 standalone emulator PAKs"
	@echo "  minui-extra-paks         Package the 5 additional MinUI PAKs"
	@echo "  minui-release            Build the final installable MinUI release"
	@echo "  preflight                Validate tools and local release inputs"
	@echo "  release-all              Build/reuse sources and create the complete release"
	@echo "  release-fresh            Delete generated clones/build/output and rebuild from scratch"
	@echo
	@echo "Release packaging:"
	@echo "  picoarch-paks            Create output/picoarch-paks"
	@echo "  standalone-paks          Create output/standalone-paks"
	@echo "  minui-extra-paks         Create output/minui-extra-paks"
	@echo "  minui-release            Create output/minui-release/MinUI-*-custom.zip"
	@echo "  clean-picoarch-paks      Remove PicoArch PAK output"
	@echo "  clean-standalone-paks    Remove standalone PAK output"
	@echo "  clean-minui-extra-paks   Remove additional MinUI PAK output"
	@echo "  clean-minui-release      Remove final MinUI release output/build"
	@echo
	@echo "MinUI Legacy:"
	@echo "  source-minui             Clone/update MinUI sources and submodules"
	@echo "  build-minui              Build MinUI Legacy and bundled emulators"
	@echo "  clean-build-minui        Clean MinUI build"
	@echo "  clean-source-minui       Remove MinUI sources"
	@echo "  build-minui-system       Build MinUI system + libraries only (make build-minui-system MINUI_REF=yourBranch)"
	@echo "  deploy-minui            Deploy built MinUI System to TrimUI over ADB"
	@echo
	@echo "Arnold:"
	@echo "  source-arnold            Checkout Arnold source"
	@echo "  build-arnold             Build Arnold"
	@echo "  install-arnold           Install GX4000.pak into output/arnold"
	@echo "  clean-build-arnold       Clean Arnold build"
	@echo "  clean-install-arnold     Remove Arnold output"
	@echo "  clean-source-arnold      Remove Arnold sources"
	@echo
	@echo "Stella:"
	@echo "  source-stella            Checkout pinned Stella source"
	@echo "  configure-stella         Generate Trimui config.mak"
	@echo "  build-stella             Build Stella"
	@echo "  install-stella           Install Atari2600.pak into output/stella"
	@echo "  clean-build-stella       Clean Stella build"
	@echo "  clean-install-stella     Remove Stella output"
	@echo "  clean-source-stella      Remove Stella sources"
	@echo
	@echo "GnGeo:"
	@echo "  source-gngeo             Checkout pinned GnGeo source"
	@echo "  configure-gngeo          Configure GnGeo for Trimui"
	@echo "  build-gngeo              Build GnGeo"
	@echo "  install-gngeo            Install NEOGEO.pak into output/gngeo"
	@echo "  clean-build-gngeo        Clean GnGeo build"
	@echo "  clean-install-gngeo      Remove GnGeo output"
	@echo "  clean-source-gngeo       Remove GnGeo sources"
	@echo
	@echo "Retro8:"
	@echo "  source-retro8            Checkout pinned Retro8 source"
	@echo "  build-retro8             Build Retro8"
	@echo "  install-retro8           Install PICO-8.pak into output/retro8"
	@echo "  clean-build-retro8       Clean Retro8 build"
	@echo "  clean-install-retro8     Remove Retro8 output"
	@echo "  clean-source-retro8      Remove Retro8 sources"
	@echo
	@echo "Options:"
	@echo "  JOBS=N                   Number of parallel jobs"

# Open an interactive shell in the build container.
shell:
	docker compose run --rm builder


# Validate local prerequisites before spending time compiling. Upstream PicoArch
# patch files are validated separately by picoarch-check-patches after the pinned
# PicoArch checkout has been prepared.
preflight:
	@set -e; \
	for cmd in git make rsync patch zip unzip curl cmake autoreconf autoconf automake aclocal libtoolize pkg-config fmt tar; do \
		command -v "$$cmd" >/dev/null || { echo "ERROR: missing command: $$cmd" >&2; exit 1; }; \
	done
	@set -e; \
	for tool in gcc g++ ar ranlib strip; do \
		test -x "$(TOOLCHAIN_BIN)/$(TARGET)-$$tool" || { \
			echo "ERROR: missing toolchain executable: $(TOOLCHAIN_BIN)/$(TARGET)-$$tool" >&2; \
			exit 1; \
		}; \
	done
	@test -d "$(TOOLCHAIN_SYSROOT)" || { echo "ERROR: missing toolchain sysroot: $(TOOLCHAIN_SYSROOT)" >&2; exit 1; }
	@set -e; \
	for file in \
		scripts/package-minui-extra-paks.sh \
		scripts/package-minui-release.sh \
		scripts/package-picoarch-paks.sh \
		scripts/package-picoarch-tool.sh \
		scripts/package-standalone-paks.sh \
		patches/picoarch/beetle-pce-fast/0001-frameskip-interval.patch \
		patches/picoarch/frontend/0001-fix-minui-directories.patch \
		patches/picoarch/libpicofe/0001-key-combos.patch \
		patches/picoarch/mame2000/0004-rotation.patch \
		patches/picoarch/mednafen_ngp/1000-trimui-build.patch \
		patches/picoarch/mednafen_wswan/1000-trimui-build.patch \
		patches/picoarch/pcsx_rearmed/1000-trimui-support.patch \
		patches/picoarch/picodrive/0002-lzma-old-arm-hwcap.patch \
		patches/picoarch/pokemini/1000-trimui-build.patch \
		patches/picoarch/prboom/1000-trimui-build.patch \
		patches/picoarch/snes9x2005/1000-trimui-build.patch \
		patches/picoarch/snes9x2005_plus/1000-trimui-build.patch \
		patches/picoarch/snes9x2010/1000-trimui-build.patch \
		patches/picoarch/stella2014/1000-trimui-build.patch; do \
		test -f "$(WORKSPACE)/$$file" || { echo "ERROR: missing project file: $$file" >&2; exit 1; }; \
	done
	@test -f "$(WORKSPACE)/assets/minui-extra-paks/Famicom Disk System.pak/launch.sh" || { \
		echo "ERROR: missing custom Famicom Disk System PAK asset" >&2; \
		exit 1; \
	}
	@echo "Preflight OK"

# Build the complete release in a deterministic serial order. Each recursive make
# must succeed before the next stage starts.
release-all:
	$(MAKE) preflight
	$(MAKE) libs
	$(MAKE) build-minui
	$(MAKE) build-arnold
	$(MAKE) install-arnold
	$(MAKE) build-stella
	$(MAKE) install-stella
	$(MAKE) build-gngeo
	$(MAKE) install-gngeo
	$(MAKE) build-retro8
	$(MAKE) install-retro8
	$(MAKE) picoarch-frontend
	$(MAKE) picoarch-validated
	$(MAKE) picoarch-output
	$(MAKE) picoarch-paks
	$(MAKE) standalone-paks
	$(MAKE) minui-extra-paks
	$(MAKE) picoarch-tool
	$(MAKE) minui-release
# Force the high-level orchestration to remain serial even if the caller adds -j.
# Individual projects still use JOBS internally where their build systems support it.
.NOTPARALLEL: release-all release-fresh picoarch-validated

# Reproduce the workflow of a newly cloned project while preserving the Docker SDK
# and project-owned files (Makefiles, patches, scripts and assets).
release-fresh:
	$(MAKE) preflight
	rm -rf \
		$(WORKSPACE)/sources \
		$(WORKSPACE)/libs \
		$(WORKSPACE)/build \
		$(WORKSPACE)/output
	$(MAKE) release-all

