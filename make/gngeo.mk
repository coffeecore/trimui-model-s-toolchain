# -----------------------------------------------------------------------------
# GnGeo / Neo Geo
# -----------------------------------------------------------------------------

GNGEO_REPO := https://github.com/coffeecore/gngeo.git
GNGEO_COMMIT := 9336cb9f4cdda6de91b4234975248f4b0580ab5a

GNGEO_DIR := /workspace/sources/gngeo
GNGEO_OUTPUT_DIR := $(OUTPUT_DIR)/gngeo
GNGEO_PAK := $(GNGEO_OUTPUT_DIR)/NEOGEO.pak

GNGEO_CC := /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-gcc
GNGEO_CPP := $(GNGEO_CC) -E
GNGEO_AR := /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-ar
GNGEO_RANLIB := /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-ranlib
GNGEO_STRIP := /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-strip

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

configure-gngeo: source-gngeo
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

clean-install-gngeo:
	rm -rf "$(GNGEO_OUTPUT_DIR)"

gngeo:
	$(MAKE) clean-install-gngeo
	$(MAKE) clean-build-gngeo
	$(MAKE) build-gngeo
	$(MAKE) install-gngeo
