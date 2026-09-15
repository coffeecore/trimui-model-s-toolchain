# ==============================================================================
# Trimui Model S build environment
# ==============================================================================
# This root Makefile intentionally stays small. Implementation details live in
# make/*.mk so each component can evolve independently.
#
# Parallelism has a conservative default. Override without editing files:
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
include make/dev.mk

.PHONY: help help-dev help-release shell preflight release-all release-fresh

# Full command overview. Development and release help can also be shown alone.
help:
	@echo "Trimui Model S build environment"
	@echo
	@$(MAKE) --no-print-directory help-dev
	@echo
	@$(MAKE) --no-print-directory help-release
	@echo
	@echo "Shared / utility targets:"
	@echo "  shell                    Open an interactive builder container shell"
	@echo "  libs                     Build/install the shared target libraries"
	@echo "  build-libs               Recreate the project sysroot and all shared libraries"
	@echo "  clean-build-libs         Remove the generated project sysroot/build artifacts"
	@echo "  install-libs             Reinstall already-built libraries into the project sysroot"
	@echo "  clean-install-libs       Remove project-installed library files"
	@echo "  clean-source-libs        Remove downloaded library sources"
	@echo "  JOBS=N                   Override parallel build jobs (default: $(JOBS))"

help-dev:
	@echo "Development targets"
	@echo "  Source root: $(DEV_SOURCES_DIR)"
	@echo "  Output root: $(DEV_OUTPUT_DIR)"
	@echo
	@echo "Status:"
	@echo "  dev-status                       Show Git branch/status of all known dev trees"
	@echo
	@echo "GnGeo - Steward Fu (active GNO port):"
	@echo "  dev-gngeo-steward-fu             Build sources/gngeo-steward-fu"
	@echo "  dev-clean-gngeo-steward-fu       Clean its build artifacts"
	@echo "  dev-install-gngeo-steward-fu     Copy binary to output/dev/gngeo-steward-fu"
	@echo "  dev-gngeo                         Alias of dev-gngeo-steward-fu"
	@echo "  dev-clean-gngeo                   Alias of dev-clean-gngeo-steward-fu"
	@echo "  dev-install-gngeo                 Alias of dev-install-gngeo-steward-fu"
	@echo
	@echo "GnGeo - Coffeecore (known Trimui reference):"
	@echo "  dev-gngeo-coffeecore              Build sources/gngeo-coffeecore"
	@echo "  dev-clean-gngeo-coffeecore        Clean its build artifacts"
	@echo "  dev-install-gngeo-coffeecore      Create output/dev/gngeo-coffeecore/NEOGEO.pak"
	@echo
	@echo "MinUI:"
	@echo "  dev-minui-libs                    Build libmsettings/libmmenu from sources/minui"
	@echo "  dev-minui-system                  Build only the MinUI System"
	@echo "  dev-minui                         Build full MinUI from sources/minui"
	@echo "  dev-clean-minui                   Clean generated MinUI artifacts"
	@echo "  dev-deploy-minui                  Deploy dev MinUI System over ADB"
	@echo
	@echo "PicoArch:"
	@echo "  dev-picoarch-frontend             Build sources/picoarch using pinned MinUI libs"
	@echo "  dev-picoarch-frontend-with-dev-minui"
	@echo "                                    Build PicoArch using sources/minui libmmenu"
	@echo "  dev-picoarch-output               Copy dev frontend to output/dev/picoarch"
	@echo "  dev-clean-picoarch                Remove dev PicoArch top-level build products"
	@echo "  dev-picoarch-core CORE=<name>     Build sources/picoarch-cores/<name>"
	@echo "                                    Example: make dev-picoarch-core CORE=mame2000"
	@echo
	@echo "Safety: dev targets never checkout/reset/clean Git and never auto-apply patches."

help-release:
	@echo "Release targets"
	@echo "  Disposable pinned source root: $(RELEASE_SOURCES_DIR)"
	@echo
	@echo "Orchestration:"
	@echo "  preflight                Validate release prerequisites"
	@echo "  release-all              Build/reuse pinned sources and create the complete release"
	@echo "  release-fresh            Delete generated libs/build/output and rebuild from scratch"
	@echo
	@echo "MinUI release source/build:"
	@echo "  minui                    Clean and build pinned MinUI"
	@echo "  source-minui             Prepare pinned MinUI source"
	@echo "  build-minui-system       Build MinUI system + libraries"
	@echo "  build-minui              Build full MinUI"
	@echo "  clean-build-minui        Clean MinUI build artifacts"
	@echo "  clean-source-minui       Remove only the release MinUI checkout"
	@echo "  deploy-minui             Deploy the release MinUI System over ADB"
	@echo
	@echo "Standalone emulators:"
	@echo "  arnold / source-arnold / build-arnold / install-arnold"
	@echo "  clean-build-arnold / clean-install-arnold / clean-source-arnold"
	@echo "  stella / source-stella / configure-stella / build-stella / install-stella"
	@echo "  clean-build-stella / clean-install-stella / clean-source-stella"
	@echo "  gngeo / source-gngeo / configure-gngeo / build-gngeo / install-gngeo"
	@echo "      release GnGeo is pinned Coffeecore; dev GnGeo trees are not used"
	@echo "  clean-build-gngeo / clean-install-gngeo / clean-source-gngeo"
	@echo "  retro8 / source-retro8 / build-retro8 / install-retro8"
	@echo "  clean-build-retro8 / clean-install-retro8 / clean-source-retro8"
	@echo
	@echo "PicoArch release:"
	@echo "  source-picoarch          Prepare pinned PicoArch source"
	@echo "  prepare-picoarch         Create patched release build tree"
	@echo "  picoarch-check-patches   Validate required PicoArch patches"
	@echo "  picoarch-frontend        Build PicoArch frontend"
	@echo "  picoarch-validated       Build all validated cores"
	@echo "  picoarch-output          Collect frontend + validated cores"
	@echo "  picoarch-clean-frontend  Remove release PicoArch working tree"
	@echo "  picoarch-clean-output    Remove collected PicoArch output"
	@echo "  clean-source-picoarch    Remove only the release PicoArch checkout"
	@echo
	@echo "Individual PicoArch cores:"
	@echo "  picoarch-fceumm picoarch-gambatte picoarch-gpsp picoarch-picodrive"
	@echo "  picoarch-mame2000 picoarch-mame2003 picoarch-mame2003-plus"
	@echo "  picoarch-pcsx-rearmed picoarch-beetle-pce-fast picoarch-bluemsx"
	@echo "  picoarch-fmsx picoarch-gme picoarch-mednafen-ngp picoarch-mednafen-wswan"
	@echo "  picoarch-pokemini picoarch-quicknes picoarch-smsplus-gx"
	@echo "  picoarch-snes9x2002 picoarch-snes9x2005 picoarch-snes9x2005-plus"
	@echo "  picoarch-snes9x2010 picoarch-stella2014 picoarch-prboom picoarch-fbalpha2012"
	@echo "  picoarch-fake08          Available experimental/non-validated target"
	@echo "Core cleanup targets:"
	@echo "  picoarch-clean-fceumm picoarch-clean-gambatte picoarch-clean-gpsp picoarch-clean-picodrive"
	@echo "  picoarch-clean-mame2000 picoarch-clean-mame2003 picoarch-clean-mame2003-plus"
	@echo "  picoarch-clean-pcsx-rearmed picoarch-clean-beetle-pce-fast picoarch-clean-bluemsx"
	@echo "  picoarch-clean-fmsx picoarch-clean-gme picoarch-clean-mednafen-ngp picoarch-clean-mednafen-wswan"
	@echo "  picoarch-clean-pokemini picoarch-clean-quicknes picoarch-clean-smsplus-gx"
	@echo "  picoarch-clean-snes9x2002 picoarch-clean-snes9x2005 picoarch-clean-snes9x2005-plus"
	@echo "  picoarch-clean-snes9x2010 picoarch-clean-stella2014 picoarch-clean-prboom picoarch-clean-fbalpha2012"
	@echo "  picoarch-clean-fake08 picoarch-clean-validated"
	@echo
	@echo "Packaging / release variants:"
	@echo "  picoarch-paks            Create output/picoarch-paks"
	@echo "  picoarch-tool            Create output/picoarch-tool"
	@echo "  standalone-paks          Create output/standalone-paks"
	@echo "  minui-extra-paks         Create output/minui-extra-paks"
	@echo "  mame4allx-pak            Package MAME4ALLX"
	@echo "  minui-only-release       Build MinUI-only release"
	@echo "  minui-standalone-release Build MinUI + standalone release"
	@echo "  minui-picoarch-release   Build MinUI + PicoArch release"
	@echo "  minui-release            Build full installable MinUI release"
	@echo
	@echo "Packaging cleanup:"
	@echo "  clean-picoarch-paks / clean-picoarch-tool / clean-standalone-paks"
	@echo "  clean-minui-extra-paks / clean-mame4allx-pak"
	@echo "  clean-minui-only-release / clean-minui-standalone-release"
	@echo "  clean-minui-picoarch-release / clean-minui-release"
	@echo
	@echo "Safety: release targets never remove, checkout or reset $(DEV_SOURCES_DIR)."

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

# Reproduce the workflow of a newly cloned release while preserving developer-owned
# source trees under /workspace/sources and project-owned orchestration files.
release-fresh:
	$(MAKE) preflight
	rm -rf \
		$(WORKSPACE)/libs \
		$(WORKSPACE)/build \
		$(WORKSPACE)/output
	$(MAKE) release-all

