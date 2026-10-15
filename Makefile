# ==============================================================================
# Trimui Model S build environment
# ==============================================================================
# This root Makefile intentionally stays small. Implementation details live in
# make/*.mk so each component can evolve independently.
#
# Parallelism has a conservative default. Override without editing files:
#   make libs JOBS=4
#   make build-minui JOBS=4

.DEFAULT_GOAL := help-dev

include make/common.mk
include make/libs.mk
include make/minui.mk
include make/picoarch.mk
include make/picoarch-tool.mk
include make/picoarch-paks.mk
include make/minui-release.mk
include make/minui-libs.mk
include make/mame4allx.mk
include make/gno.mk

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
	@echo "Neo Geo tools:"
	@echo '  gno ROM=/path/game.zip       Convert one Neo Geo ZIP to GNO'
	@echo '  gno-dir ROM_DIR=/path        Convert every Neo Geo ZIP in a directory'
	@echo '  gno-image                    Build the GNO converter Docker image'
	@echo

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
	@echo "PicoArch release:"
	@echo "  source-picoarch          Prepare pinned PicoArch source"
	@echo "  prepare-picoarch         Create release build tree"
	@echo "  picoarch-frontend        Build PicoArch frontend"
	@echo "  picoarch-validated       Build all validated cores"
	@echo "  picoarch-output          Collect frontend + validated cores"
	@echo "  picoarch-clean-frontend  Remove release PicoArch working tree"
	@echo "  picoarch-clean-output    Remove collected PicoArch output"
	@echo "  clean-source-picoarch    Remove only the release PicoArch checkout"
	@echo
	@echo "Individual PicoArch cores:"
	@echo "  picoarch-fceumm picoarch-gambatte picoarch-gpsp picoarch-picodrive"
	@echo "  picoarch-mame2000 picoarch-mame2003 picoarch-pcsx-rearmed"
	@echo "  picoarch-beetle-pce-fast picoarch-bluemsx picoarch-fmsx picoarch-gme"
	@echo "  picoarch-mednafen-ngp picoarch-mednafen-wswan picoarch-pokemini"
	@echo "  picoarch-quicknes picoarch-smsplus-gx picoarch-snes9x2002"
	@echo "  picoarch-snes9x2005 picoarch-stella2014 picoarch-handy picoarch-gngeo"
	@echo "Core cleanup targets:"
	@echo "  picoarch-clean-fceumm picoarch-clean-gambatte picoarch-clean-gpsp picoarch-clean-picodrive"
	@echo "  picoarch-clean-mame2000 picoarch-clean-mame2003 picoarch-clean-pcsx-rearmed"
	@echo "  picoarch-clean-beetle-pce-fast picoarch-clean-bluemsx picoarch-clean-fmsx picoarch-clean-gme"
	@echo "  picoarch-clean-mednafen-ngp picoarch-clean-mednafen-wswan picoarch-clean-pokemini"
	@echo "  picoarch-clean-quicknes picoarch-clean-smsplus-gx picoarch-clean-snes9x2002"
	@echo "  picoarch-clean-snes9x2005 picoarch-clean-stella2014 picoarch-clean-handy"
	@echo "  picoarch-clean-gngeo picoarch-clean-validated"
	@echo
	@echo "Packaging / release variants:"
	@echo "  picoarch-paks            Create output/picoarch-paks"
	@echo "  picoarch-tool            Create output/picoarch-tool"
	@echo "  mame4allx-pak            Package MAME4ALLX"
	@echo "  minui-only-release       Build MinUI-only release"
	@echo "  minui-release            Build full installable MinUI release"
	@echo
	@echo "Packaging cleanup:"
	@echo "  clean-picoarch-paks / clean-picoarch-tool"
	@echo "  clean-minui-only-release"
	@echo
	@echo "Safety: release targets never remove, checkout or reset $(DEV_SOURCES_DIR)."

# Open an interactive shell in the build container.
shell:
	docker compose run --rm builder


# Validate local prerequisites before spending time compiling.
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
		scripts/package-minui-release.sh \
		scripts/package-picoarch-paks.sh \
		scripts/package-picoarch-tool.sh; do \
		test -f "$(WORKSPACE)/$$file" || { \
			echo "ERROR: missing project file: $$file" >&2; \
			exit 1; \
		}; \
	done
	@echo "Preflight OK"

# Build the complete release in a deterministic serial order. Each recursive make
# must succeed before the next stage starts.
release-all:
	$(MAKE) preflight
	$(MAKE) libs
	$(MAKE) build-minui
	$(MAKE) picoarch-frontend
	$(MAKE) picoarch-validated
	$(MAKE) picoarch-output
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

