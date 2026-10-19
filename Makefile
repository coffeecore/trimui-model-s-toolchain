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
include make/minui-release.mk
include make/minui-libs.mk

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

help-release:
	@echo "Release targets"
	@echo "  Disposable pinned source root: $(RELEASE_SOURCES_DIR)"
	@echo
	@echo "Orchestration:"
	@echo "  preflight                Validate release prerequisites"
	@echo "  release-all              Build both MinUI release variants"
	@echo "  release-fresh            Remove generated build/output and rebuild from scratch"
	@echo
	@echo "MinUI releases:"
	@echo "  minui-only-release       Build MinUI-only release"
	@echo "  minui-picoarch-release   Build MinUI + PicoArch release"
	@echo "  minui-release            Alias for minui-picoarch-release"
	@echo "  minui-releases           Build both release variants"
	@echo "  clean-minui-release      Remove generated MinUI release ZIPs"
	@echo
	@echo "PicoArch:"
	@echo "  prepare-picoarch         Prepare PicoArch build tree from MinUI"
	@echo "  picoarch-frontend        Build PicoArch frontend"
	@echo "  picoarch-validated       Build all validated cores"
	@echo "  picoarch-output          Collect frontend + validated cores"
	@echo "  picoarch-clean-frontend  Remove PicoArch working tree"
	@echo "  picoarch-clean-output    Remove collected PicoArch output"
	@echo
	@echo "Other packaging:"
	@echo "  mame4allx-pak            Package MAME4ALLX"
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
	@echo "Preflight OK"

# Build the complete release in a deterministic serial order. Each recursive make
# must succeed before the next stage starts.
release-all:
	$(MAKE) preflight
	$(MAKE) minui-releases

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

