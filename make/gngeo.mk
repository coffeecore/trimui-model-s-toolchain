# -----------------------------------------------------------------------------
# GnGeo / Neo Geo
# -----------------------------------------------------------------------------

GNGEO_REPO := https://github.com/coffeecore/gngeo.git
GNGEO_COMMIT := 9336cb9f4cdda6de91b4234975248f4b0580ab5a

GNGEO_DIR := $(WORKSPACE)/sources/gngeo
GNGEO_OUTPUT_DIR := $(OUTPUT_DIR)/gngeo
GNGEO_PAK := $(GNGEO_OUTPUT_DIR)/NEOGEO.pak

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
		mkdir -p "$(dir $(GNGEO_DIR))"; \
		git clone "$(GNGEO_REPO)" "$(GNGEO_DIR)"; \
	fi
	cd "$(GNGEO_DIR)" && git checkout --detach "$(GNGEO_COMMIT)"

configure-gngeo: source-gngeo libs
	cd "$(GNGEO_DIR)" && \
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

build-gngeo: configure-gngeo minui-libs
	cd "$(GNGEO_DIR)" && \
	PATH="$(SYSROOT)/usr/bin:$$PATH" \
	$(MAKE) -j$(JOBS)
	test -x "$(GNGEO_DIR)/src/gngeo"

clean-build-gngeo:
	@if [ -f "$(GNGEO_DIR)/Makefile" ]; then \
		cd "$(GNGEO_DIR)" && \
		PATH="$(SYSROOT)/usr/bin:$$PATH" \
		$(MAKE) clean; \
	fi
	rm -f "$(GNGEO_DIR)/config.status"
	rm -f "$(GNGEO_DIR)/config.log"
	rm -f "$(GNGEO_DIR)/config.cache"

clean-source-gngeo:
	rm -rf "$(GNGEO_DIR)"

install-gngeo:
	test -x "$(GNGEO_DIR)/src/gngeo"
	rm -rf "$(GNGEO_OUTPUT_DIR)"
	mkdir -p "$(GNGEO_OUTPUT_DIR)"
	cp -R \
		"$(GNGEO_DIR)/trimui-dist/Emus/NEOGEO.pak" \
		"$(GNGEO_OUTPUT_DIR)/"
	cp \
		"$(GNGEO_DIR)/src/gngeo" \
		"$(GNGEO_PAK)/gngeo"

	# The Buildroot SDL used by GnGeo has a runtime dependency on tslib.
	# The Trimui Model S firmware does not provide libts-1.0.so.0, so keep this
	# non-system dependency private to the PAK instead of modifying the firmware.
	test -e "$(SYSROOT)/usr/lib/libts-1.0.so.0"
	mkdir -p "$(GNGEO_PAK)/lib"
	cp -a $(SYSROOT)/usr/lib/libts-1.0.so* "$(GNGEO_PAK)/lib/"
	@if [ -d "$(SYSROOT)/usr/lib/ts" ]; then \
		cp -a "$(SYSROOT)/usr/lib/ts" "$(GNGEO_PAK)/lib/"; \
	fi

	# Make the private runtime directory visible before executing GnGeo.
	sed -i '1a\
PAK_DIR="$$(CDPATH= cd -- "$$(dirname -- "$$0")" && pwd)"\
export LD_LIBRARY_PATH="$$PAK_DIR/lib$${LD_LIBRARY_PATH:+:$$LD_LIBRARY_PATH}"\
export TSLIB_PLUGINDIR="$$PAK_DIR/lib/ts"' \
		"$(GNGEO_PAK)/launch.sh"
	sh -n "$(GNGEO_PAK)/launch.sh"

clean-install-gngeo:
	rm -rf "$(GNGEO_OUTPUT_DIR)"

gngeo:
	$(MAKE) clean-install-gngeo
	$(MAKE) clean-build-gngeo
	$(MAKE) build-gngeo
	$(MAKE) install-gngeo
