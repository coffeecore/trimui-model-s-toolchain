# -----------------------------------------------------------------------------
# GnGeo / Neo Geo - Steward Fu release build
# -----------------------------------------------------------------------------
# The release checkout is isolated under build/release-sources. During active
# development GNGEO_REF may name the trimui-model-s branch; for a frozen release
# it can be overridden with an exact commit SHA without changing this Makefile.

GNGEO_REPO ?= https://github.com/coffeecore/gngeo-steward-fu.git
GNGEO_REF ?= trimui-model-s

GNGEO_DIR := $(RELEASE_SOURCES_DIR)/gngeo-steward-fu
GNGEO_OUTPUT_DIR := $(OUTPUT_DIR)/gngeo
GNGEO_PAK_TEMPLATE := $(GNGEO_DIR)/trimui-dist/Emus/NEOGEO.pak
GNGEO_PAK := $(GNGEO_OUTPUT_DIR)/NEOGEO.pak
GNGEO_BINARY := $(GNGEO_DIR)/gngeo

# Kept for the Coffeecore reference targets in make/dev.mk.
GNGEO_CC := $(CROSS_COMPILE)gcc
GNGEO_CPP := $(GNGEO_CC) -E
GNGEO_AR := $(CROSS_COMPILE)ar
GNGEO_RANLIB := $(CROSS_COMPILE)ranlib
GNGEO_STRIP := $(CROSS_COMPILE)strip

.PHONY: \
	gngeo \
	source-gngeo \
	configure-gngeo \
	build-gngeo \
	clean-build-gngeo \
	clean-source-gngeo \
	install-gngeo \
	clean-install-gngeo

source-gngeo:
	@if [ ! -d "$(GNGEO_DIR)/.git" ]; then \
		rm -rf "$(GNGEO_DIR)"; \
		mkdir -p "$(dir $(GNGEO_DIR))"; \
		git clone --no-checkout "$(GNGEO_REPO)" "$(GNGEO_DIR)"; \
	fi
	git -C "$(GNGEO_DIR)" remote set-url origin "$(GNGEO_REPO)"
	git -C "$(GNGEO_DIR)" fetch --force origin "$(GNGEO_REF)"
	git -C "$(GNGEO_DIR)" checkout --detach FETCH_HEAD
	git -C "$(GNGEO_DIR)" reset --hard FETCH_HEAD
	git -C "$(GNGEO_DIR)" clean -fdx

# Compatibility target: Steward Fu uses Makefile.trimui directly and has no
# Autotools configure phase. Keep the target name so existing workflows do not
# break.
# configure-gngeo: source-gngeo libs minui-libs
configure-gngeo: libs minui-libs
	@test -f "$(GNGEO_DIR)/Makefile.trimui" || { \
		echo "ERROR: missing Makefile.trimui in $(GNGEO_DIR)" >&2; \
		exit 1; \
	}

build-gngeo: configure-gngeo
	$(MAKE) -C "$(GNGEO_DIR)" \
		-f Makefile.trimui \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		SYSROOT="$(SYSROOT)" \
		MMENU_DIR="$(MINUI_MMENU_BUILD)" \
		JOBS="$(JOBS)"
	@test -x "$(GNGEO_BINARY)"

clean-build-gngeo:
	@if [ -f "$(GNGEO_DIR)/Makefile.trimui" ]; then \
		$(MAKE) -C "$(GNGEO_DIR)" -f Makefile.trimui clean; \
	fi

# clean-source-gngeo:
# 	rm -rf "$(GNGEO_DIR)"

install-gngeo:
	@test -x "$(GNGEO_BINARY)" || { \
		echo "ERROR: build first with: make build-gngeo" >&2; \
		exit 1; \
	}
	@test -d "$(GNGEO_PAK_TEMPLATE)" || { \
		echo "ERROR: missing Steward Fu PAK template: $(GNGEO_PAK_TEMPLATE)" >&2; \
		exit 1; \
	}
	@test -f "$(GNGEO_PAK_TEMPLATE)/launch.sh" || { \
		echo "ERROR: missing Steward Fu launcher: $(GNGEO_PAK_TEMPLATE)/launch.sh" >&2; \
		exit 1; \
	}
	rm -rf "$(GNGEO_OUTPUT_DIR)"
	mkdir -p "$(GNGEO_OUTPUT_DIR)"
	cp -a "$(GNGEO_PAK_TEMPLATE)" "$(GNGEO_OUTPUT_DIR)/"
	cp "$(GNGEO_BINARY)" "$(GNGEO_PAK)/gngeo"

	# The Buildroot SDL used by GnGeo has a runtime dependency on tslib.
	# The Trimui Model S firmware does not provide libts-1.0.so.0, so keep this
	# non-system dependency private to the PAK instead of modifying the firmware.
	@test -e "$(SYSROOT)/usr/lib/libts-1.0.so.0"
	mkdir -p "$(GNGEO_PAK)/lib"
	cp -L $(SYSROOT)/usr/lib/libts-1.0.so* "$(GNGEO_PAK)/lib/"
	cp -L "$(SYSROOT)/usr/lib/libz.so.1" "$(GNGEO_PAK)/lib/libz.so.1"
	@if [ -d "$(SYSROOT)/usr/lib/ts" ]; then \
		cp -aL "$(SYSROOT)/usr/lib/ts" "$(GNGEO_PAK)/lib/"; \
	fi

	chmod +x "$(GNGEO_PAK)/gngeo" "$(GNGEO_PAK)/launch.sh"
	sh -n "$(GNGEO_PAK)/launch.sh"

clean-install-gngeo:
	rm -rf "$(GNGEO_OUTPUT_DIR)"

gngeo:
	$(MAKE) clean-install-gngeo
	$(MAKE) clean-build-gngeo
	$(MAKE) build-gngeo
	$(MAKE) install-gngeo
