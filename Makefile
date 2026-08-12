# ==============================================================================
# Trimui Model S build environment
# ==============================================================================
# This root Makefile intentionally stays small. Implementation details live in
# make/*.mk so each component can evolve independently.
#
# Main commands:
#   make toolchain          Rebuild + install the cross-toolchain
#   make libs               Rebuild + install all common libraries
#   make setup              Run toolchain then libs
#   make build-minui        Build and package MinUI Legacy
#   make clean-build-minui  Remove MinUI build artifacts
#
# Parallelism defaults to all available CPUs. Override without editing files:
#   make libs JOBS=4
#   make build-minui JOBS=4

.DEFAULT_GOAL := help

include make/common.mk
include make/toolchain.mk
include make/libs.mk
include make/minui.mk
include make/arnold.mk
include make/stella.mk
include make/gngeo.mk
include make/retro8.mk

.PHONY: help shell toolchain libs setup


# Show the high-level commands intended for normal use.
help:
	@echo "Trimui Model S build environment"
	@echo
	@echo "Main targets:"
	@echo "  setup                 Build and install toolchain + libraries"
	@echo "  toolchain             Clean, build and install the toolchain"
	@echo "  libs                  Clean, build and install common libraries"
	@echo "  minui                 Clean and build MinUI Legacy"
	@echo "  arnold                Clean, build and install Arnold"
	@echo "  stella                Clean, build and install Stella"
	@echo "  gngeo                 Clean, build and install GnGeo"
	@echo "  retro8                Clean, build and install Retro8"
	@echo
	@echo "Toolchain:"
	@echo "  build-toolchain       Build the crosstool-NG toolchain"
	@echo "  install-toolchain     Install toolchain sysroot and compatibility wrappers"
	@echo "  clean-build-toolchain Clean toolchain build"
	@echo "  clean-install-toolchain"
	@echo
	@echo "Libraries:"
	@echo "  build-libs            Build all common libraries"
	@echo "  install-libs          Install all common libraries"
	@echo "  clean-build-libs      Clean all library builds"
	@echo "  clean-install-libs    Clean installed libraries"
	@echo "  clean-source-libs     Remove downloaded library sources"
	@echo
	@echo "MinUI Legacy:"
	@echo "  source-minui          Clone/update MinUI sources and submodules"
	@echo "  build-minui           Build MinUI Legacy and bundled emulators"
	@echo "  clean-build-minui     Clean MinUI build"
	@echo "  clean-source-minui    Remove MinUI sources"
	@echo
	@echo "Arnold:"
	@echo "  source-arnold         Checkout pinned Arnold source"
	@echo "  build-arnold          Build Arnold"
	@echo "  install-arnold        Install GX4000.pak into output/arnold"
	@echo "  clean-build-arnold    Clean Arnold build"
	@echo "  clean-install-arnold  Remove Arnold output"
	@echo "  clean-source-arnold   Remove Arnold sources"
	@echo
	@echo "Stella:"
	@echo "  source-stella         Checkout pinned Stella source"
	@echo "  configure-stella      Generate Trimui config.mak"
	@echo "  build-stella          Build Stella"
	@echo "  install-stella        Install Atari2600.pak into output/stella"
	@echo "  clean-build-stella    Clean Stella build"
	@echo "  clean-install-stella  Remove Stella output"
	@echo "  clean-source-stella   Remove Stella sources"
	@echo
	@echo "GnGeo:"
	@echo "  source-gngeo          Checkout pinned GnGeo source"
	@echo "  configure-gngeo       Configure GnGeo for Trimui"
	@echo "  build-gngeo           Build GnGeo"
	@echo "  install-gngeo         Install NEOGEO.pak into output/gngeo"
	@echo "  clean-build-gngeo     Clean GnGeo build"
	@echo "  clean-install-gngeo   Remove GnGeo output"
	@echo "  clean-source-gngeo    Remove GnGeo sources"
	@echo
	@echo "Retro8:"
	@echo "  source-retro8         Checkout pinned Retro8 source"
	@echo "  build-retro8          Build Retro8"
	@echo "  install-retro8        Install PICO-8.pak into output/retro8"
	@echo "  clean-build-retro8    Clean Retro8 build"
	@echo "  clean-install-retro8  Remove Retro8 output"
	@echo "  clean-source-retro8   Remove Retro8 sources"
	@echo
	@echo "Options:"
	@echo "  JOBS=N                Number of parallel jobs (default: nproc)"

# Open an interactive shell in the build container.
shell:
	docker compose run --rm builder

# Full toolchain refresh: remove the previous installation/build, rebuild it,
# then recreate the compatibility wrappers expected by legacy Trimui projects.
toolchain:
	$(MAKE) clean-install-toolchain
	$(MAKE) clean-build-toolchain
	$(MAKE) build-toolchain
	$(MAKE) install-toolchain

# Full common-library refresh. Sources are kept locally to avoid needless Git
# downloads; build artifacts and installed libraries are recreated from scratch.
libs:
	$(MAKE) clean-install-libs
	$(MAKE) clean-build-libs
	$(MAKE) build-libs
	$(MAKE) install-libs

# First-time environment setup convenience target.
setup:
	$(MAKE) toolchain
	$(MAKE) libs
