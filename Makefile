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

.PHONY: help shell toolchain libs setup


# Show the high-level commands intended for normal use.
help:
	@printf '%s\n' \
		'make toolchain          Rebuild and install the cross-toolchain' \
		'make libs               Rebuild and install common libraries' \
		'make setup              Run toolchain then libs' \
		'make build-minui        Build and package MinUI Legacy' \
		'make clean-build-minui  Remove MinUI build artifacts' \
		'' \
		'Optional: append JOBS=N to limit parallel compilation.'

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
