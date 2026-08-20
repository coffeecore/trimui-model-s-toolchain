# ==============================================================================
# Common target libraries
# ==============================================================================
# All projects link against a single final sysroot. `build-libs` first creates a
# temporary staging sysroot from the pristine crosstool-NG sysroot, then builds
# and installs every library into that staging tree in dependency order.

# ------------------------------------------------------------------------------
# Versions and paths
# ------------------------------------------------------------------------------
ZLIB_VERSION := 1.3.1
ZLIB_DIR := $(WORKSPACE)/libs/zlib
ZLIB_BUILD_DIR := $(WORKSPACE)/build/zlib

LIBPNG_VERSION := 1.6.58
LIBPNG_DIR := $(WORKSPACE)/libs/libpng
LIBPNG_BUILD_DIR := $(WORKSPACE)/build/libpng

SDL_VERSION := 1.2.15
SDL_REPO := https://github.com/coffeecore/SDL-1.2.git
SDL_BRANCH := trimui-model-s
SDL_COMMIT := 65e28f147edefb6f6ad8fe3dd02f457ef0d15b62

SDL_DIR := $(WORKSPACE)/libs/SDL-1.2
SDL_BUILD_DIR := $(WORKSPACE)/build/SDL-1.2

SDL_IMAGE_VERSION := 1.2.12
SDL_IMAGE_DIR := $(WORKSPACE)/libs/SDL_image
SDL_IMAGE_BUILD_DIR := $(WORKSPACE)/build/SDL_image

SDL_MIXER_VERSION := 1.2.12
SDL_MIXER_DIR := $(WORKSPACE)/libs/SDL_mixer
SDL_MIXER_BUILD_DIR := $(WORKSPACE)/build/SDL_mixer

FREETYPE_VERSION := 2.4.8
FREETYPE_DIR := $(WORKSPACE)/libs/freetype
FREETYPE_BUILD_DIR := $(WORKSPACE)/build/freetype

SDL_TTF_VERSION := 2.0.11
SDL_TTF_DIR := $(WORKSPACE)/libs/SDL_ttf
SDL_TTF_BUILD_DIR := $(WORKSPACE)/build/SDL_ttf

TINYALSA_VERSION := 2.0.0
TINYALSA_DIR := $(WORKSPACE)/libs/tinyalsa
TINYALSA_BUILD_DIR := $(WORKSPACE)/build/tinyalsa

ALSA_LIB_VERSION := 1.2.10
ALSA_LIB_DIR := $(WORKSPACE)/libs/alsa-lib
ALSA_LIB_BUILD_DIR := $(WORKSPACE)/build/alsa-lib

BZIP2_VERSION := 1.0.8
BZIP2_DIR := $(WORKSPACE)/libs/bzip2
BZIP2_BUILD_DIR := $(WORKSPACE)/build/bzip2

LIBMAD_VERSION := 0.15.1b
LIBMAD_DIR := /workspace/libs/libmad
LIBMAD_BUILD_DIR := /workspace/build/libmad
LIBMAD_ARCHIVE := /workspace/libs/libmad-$(LIBMAD_VERSION).tar.gz

.PHONY: \
	prepare-build-sysroot \
	build-libs clean-build-libs install-libs clean-install-libs clean-source-libs \
	build-zlib clean-build-zlib install-zlib clean-install-zlib \
	build-libpng clean-build-libpng install-libpng clean-install-libpng \
	build-sdl clean-build-sdl install-sdl clean-install-sdl \
	build-sdl-image clean-build-sdl-image install-sdl-image clean-install-sdl-image \
	build-sdl-mixer clean-build-sdl-mixer install-sdl-mixer clean-install-sdl-mixer \
	build-freetype clean-build-freetype install-freetype clean-install-freetype \
	build-sdl-ttf clean-build-sdl-ttf install-sdl-ttf clean-install-sdl-ttf \
	build-tinyalsa clean-build-tinyalsa install-tinyalsa clean-install-tinyalsa \
	build-alsa-lib clean-build-alsa-lib install-alsa-lib clean-install-alsa-lib \
	build-bzip2 clean-build-bzip2 install-bzip2 clean-install-bzip2 \
	build-libmad clean-build-libmad install-libmad clean-install-libmad

# ------------------------------------------------------------------------------
# Global library orchestration
# ------------------------------------------------------------------------------
prepare-build-sysroot:
	test -d $(TOOLCHAIN_SYSROOT)
	rm -rf $(BUILD_SYSROOT)
	mkdir -p $(BUILD_SYSROOT)
	rsync -a $(TOOLCHAIN_SYSROOT)/ $(BUILD_SYSROOT)/
	chmod -R u+w $(BUILD_SYSROOT)

# Explicitly serial orchestration: each library is installed into the staging
# sysroot before the next dependent library is configured.
build-libs: prepare-build-sysroot
	$(MAKE) build-zlib SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-zlib SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-libpng SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-libpng SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-sdl SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-sdl SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-sdl-image SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-sdl-image SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-sdl-mixer SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-sdl-mixer SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-freetype SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-freetype SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-sdl-ttf SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-sdl-ttf SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-tinyalsa SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-tinyalsa SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-alsa-lib SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-alsa-lib SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-bzip2 SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-bzip2 SYSROOT=$(BUILD_SYSROOT)

	$(MAKE) build-libmad SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) install-libmad SYSROOT=$(BUILD_SYSROOT)

# Clean build artifacts only. Git source checkouts are intentionally retained so
# normal rebuilds do not redownload every dependency.
clean-build-libs:
	$(MAKE) clean-build-libmad SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-bzip2 SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-alsa-lib SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-tinyalsa SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-sdl-ttf SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-freetype SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-sdl-mixer SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-sdl-image SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-sdl SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-libpng SYSROOT=$(BUILD_SYSROOT)
	$(MAKE) clean-build-zlib SYSROOT=$(BUILD_SYSROOT)
	chmod -R u+w $(BUILD_SYSROOT) 2>/dev/null || true
	rm -rf $(BUILD_SYSROOT)

# Install already-built libraries into the final project sysroot.
install-libs:
	$(MAKE) install-zlib
	$(MAKE) install-libpng
	$(MAKE) install-sdl
	$(MAKE) install-sdl-image
	$(MAKE) install-sdl-mixer
	$(MAKE) install-freetype
	$(MAKE) install-sdl-ttf
	$(MAKE) install-tinyalsa
	$(MAKE) install-alsa-lib
	$(MAKE) install-bzip2
	$(MAKE) install-libmad

# Remove installed library files in reverse dependency order.
clean-install-libs:
	$(MAKE) clean-install-libmad
	$(MAKE) clean-install-bzip2
	$(MAKE) clean-install-alsa-lib
	$(MAKE) clean-install-tinyalsa
	$(MAKE) clean-install-sdl-ttf
	$(MAKE) clean-install-freetype
	$(MAKE) clean-install-sdl-mixer
	$(MAKE) clean-install-sdl-image
	$(MAKE) clean-install-sdl
	$(MAKE) clean-install-libpng
	$(MAKE) clean-install-zlib

# Optional deep clean: delete downloaded library repositories too.
clean-source-libs:
	rm -rf \
		$(ZLIB_DIR) \
		$(LIBPNG_DIR) \
		$(SDL_DIR) \
		$(SDL_IMAGE_DIR) \
		$(SDL_MIXER_DIR) \
		$(FREETYPE_DIR) \
		$(SDL_TTF_DIR) \
		$(TINYALSA_DIR) \
		$(ALSA_LIB_DIR) \
		$(BZIP2_DIR) \
		$(LIBMAD_DIR) \
		$(LIBMAD_ARCHIVE)

# ------------------------------------------------------------------------------
# zlib
# ------------------------------------------------------------------------------
build-zlib:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -d $(SYSROOT)
	@if [ ! -d "$(ZLIB_DIR)/.git" ]; then \
		git clone --branch v$(ZLIB_VERSION) --depth 1 \
			https://github.com/madler/zlib.git $(ZLIB_DIR); \
	fi
	rm -rf $(ZLIB_BUILD_DIR)
	mkdir -p $(ZLIB_BUILD_DIR)
	cd $(ZLIB_BUILD_DIR) && \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		$(ZLIB_DIR)/configure --prefix=/usr --static
	$(MAKE) -C $(ZLIB_BUILD_DIR) -j$(JOBS)

clean-build-zlib:
	rm -rf $(ZLIB_BUILD_DIR)

install-zlib:
	test -f $(ZLIB_BUILD_DIR)/libz.a
	$(MAKE) -C $(ZLIB_BUILD_DIR) install DESTDIR=$(SYSROOT)

clean-install-zlib:
	rm -f $(SYSROOT)/usr/lib/libz.a
	rm -f $(SYSROOT)/usr/include/zlib.h
	rm -f $(SYSROOT)/usr/include/zconf.h
	rm -f $(SYSROOT)/usr/lib/pkgconfig/zlib.pc
	rm -f $(SYSROOT)/usr/share/man/man3/zlib.3

# ------------------------------------------------------------------------------
# libpng (depends on zlib)
# ------------------------------------------------------------------------------
build-libpng:
	@if [ ! -d "$(LIBPNG_DIR)/.git" ]; then \
		git clone --branch v$(LIBPNG_VERSION) --depth 1 \
			https://github.com/pnggroup/libpng.git $(LIBPNG_DIR); \
	fi
	rm -rf $(LIBPNG_BUILD_DIR)
	mkdir -p $(LIBPNG_BUILD_DIR)
	cd $(LIBPNG_BUILD_DIR) && \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		CPPFLAGS="-I$(SYSROOT)/usr/include" \
		LDFLAGS="-L$(SYSROOT)/usr/lib" \
		$(LIBPNG_DIR)/configure \
			--host=$(TARGET) \
			--prefix=/usr \
			--disable-shared \
			--enable-static
	$(MAKE) -C $(LIBPNG_BUILD_DIR) -j$(JOBS)

clean-build-libpng:
	rm -rf $(LIBPNG_BUILD_DIR)

install-libpng:
	test -f $(LIBPNG_BUILD_DIR)/.libs/libpng16.a
	DESTDIR=$(SYSROOT) $(MAKE) -C $(LIBPNG_BUILD_DIR) install

clean-install-libpng:
	rm -f $(SYSROOT)/usr/lib/libpng.a
	rm -f $(SYSROOT)/usr/lib/libpng16.a
	rm -f $(SYSROOT)/usr/lib/libpng16.la
	rm -f $(SYSROOT)/usr/lib/pkgconfig/libpng.pc
	rm -f $(SYSROOT)/usr/lib/pkgconfig/libpng16.pc
	rm -f $(SYSROOT)/usr/include/png.h
	rm -f $(SYSROOT)/usr/include/pngconf.h
	rm -f $(SYSROOT)/usr/include/pnglibconf.h
	rm -rf $(SYSROOT)/usr/include/libpng16
	rm -f $(SYSROOT)/usr/bin/libpng-config
	rm -f $(SYSROOT)/usr/bin/libpng16-config

# ------------------------------------------------------------------------------
# SDL 1.2
# ------------------------------------------------------------------------------
build-sdl:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -d $(SYSROOT)

	@if [ ! -d "$(SDL_DIR)/.git" ]; then \
		git clone \
			--branch "$(SDL_BRANCH)" \
			--single-branch \
			"$(SDL_REPO)" \
			"$(SDL_DIR)"; \
	fi

	cd "$(SDL_DIR)" && git fetch origin "$(SDL_BRANCH)"
	cd "$(SDL_DIR)" && git checkout --detach "$(SDL_COMMIT)"

	cd "$(SDL_DIR)" && ./autogen.sh

	rm -rf $(SDL_BUILD_DIR)
	mkdir -p $(SDL_BUILD_DIR)
	cd $(SDL_BUILD_DIR) && \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		CXX="$(CROSS_COMPILE)g++ --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		$(SDL_DIR)/configure \
			--host=$(TARGET) \
			--prefix=/usr \
			--disable-shared \
			--enable-static \
			--enable-video \
			--enable-video-fbcon \
			--disable-video-x11 \
			--disable-video-directfb \
			--disable-video-opengl \
			--disable-video-dga \
			--disable-video-photon \
			--disable-video-qtopia \
			--disable-video-ggi \
			--disable-video-svga \
			--disable-video-aalib \
			--disable-video-caca \
			--disable-video-nanox \
			--disable-alsa \
			--disable-esd \
			--disable-pulseaudio \
			--disable-arts \
			--disable-nas \
			--enable-oss \
			--disable-nasm
	$(MAKE) -C $(SDL_BUILD_DIR) -j$(JOBS)

clean-build-sdl:
	rm -rf $(SDL_BUILD_DIR)

# SDL's generated sdl-config embeds /usr. After installation we preserve the
# original as sdl-config.real and expose a wrapper that injects the active
# sysroot. This is required by projects such as PCSX-ReARMed.
install-sdl:
	test -f $(SDL_BUILD_DIR)/build/.libs/libSDL.a
	$(MAKE) -C $(SDL_BUILD_DIR) install DESTDIR=$(SYSROOT)
	rm -f $(SYSROOT)/usr/bin/sdl-config.real
	mv $(SYSROOT)/usr/bin/sdl-config $(SYSROOT)/usr/bin/sdl-config.real
	printf '%s\n' \
		'#!/bin/sh' \
		'exec "$(SYSROOT)/usr/bin/sdl-config.real" --prefix="$(SYSROOT)/usr" "$$@"' \
		> $(SYSROOT)/usr/bin/sdl-config
	chmod +x $(SYSROOT)/usr/bin/sdl-config

clean-install-sdl:
	rm -f $(SYSROOT)/usr/bin/sdl-config
	rm -f $(SYSROOT)/usr/bin/sdl-config.real
	rm -f $(SYSROOT)/usr/lib/libSDL.a
	rm -f $(SYSROOT)/usr/lib/libSDL.la
	rm -f $(SYSROOT)/usr/lib/libSDLmain.a
	rm -f $(SYSROOT)/usr/lib/libSDLmain.la
	rm -f $(SYSROOT)/usr/lib/pkgconfig/sdl.pc
	rm -f $(SYSROOT)/usr/share/aclocal/sdl.m4
	@for file in $(SDL_DIR)/include/*.h; do \
		rm -f "$(SYSROOT)/usr/include/SDL/$$(basename "$$file")"; \
	done
	rm -f $(SYSROOT)/usr/include/SDL/SDL_config.h
	@for file in $(SDL_DIR)/docs/man3/*.3; do \
		rm -f "$(SYSROOT)/usr/share/man/man3/$$(basename "$$file")"; \
	done

# ------------------------------------------------------------------------------
# SDL_image
# ------------------------------------------------------------------------------
build-sdl-image:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -f $(SYSROOT)/usr/lib/libSDL.a
	@if [ ! -d "$(SDL_IMAGE_DIR)/.git" ]; then \
		git clone --branch release-$(SDL_IMAGE_VERSION) --depth 1 \
			https://github.com/libsdl-org/SDL_image.git $(SDL_IMAGE_DIR); \
	fi
	rm -rf $(SDL_IMAGE_BUILD_DIR)
	mkdir -p $(SDL_IMAGE_BUILD_DIR)
	cd $(SDL_IMAGE_BUILD_DIR) && \
		PATH="$(SYSROOT)/usr/bin:$$PATH" \
		SDL_CONFIG="$(SYSROOT)/usr/bin/sdl-config" \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		CPPFLAGS="-I$(SYSROOT)/usr/include -I$(SYSROOT)/usr/include/SDL" \
		LDFLAGS="--sysroot=$(SYSROOT) -L$(SYSROOT)/usr/lib" \
		$(SDL_IMAGE_DIR)/configure \
			--host=$(TARGET) \
			--prefix=/usr \
			--disable-shared \
			--enable-static \
			--disable-jpg \
			--disable-png \
			--disable-tif \
			--disable-webp
	PATH="$(SYSROOT)/usr/bin:$$PATH" \
		SDL_CONFIG="$(SYSROOT)/usr/bin/sdl-config" \
		$(MAKE) -C $(SDL_IMAGE_BUILD_DIR) -j$(JOBS)

clean-build-sdl-image:
	rm -rf $(SDL_IMAGE_BUILD_DIR)

install-sdl-image:
	test -f $(SDL_IMAGE_BUILD_DIR)/.libs/libSDL_image.a
	$(MAKE) -C $(SDL_IMAGE_BUILD_DIR) install DESTDIR=$(SYSROOT)

clean-install-sdl-image:
	rm -f $(SYSROOT)/usr/lib/libSDL_image.a
	rm -f $(SYSROOT)/usr/lib/libSDL_image.la
	rm -f $(SYSROOT)/usr/include/SDL/SDL_image.h
	rm -f $(SYSROOT)/usr/lib/pkgconfig/SDL_image.pc

# ------------------------------------------------------------------------------
# SDL_mixer
# ------------------------------------------------------------------------------
build-sdl-mixer:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -f $(SYSROOT)/usr/lib/libSDL.a
	@if [ ! -d "$(SDL_MIXER_DIR)/.git" ]; then \
		git clone --branch release-$(SDL_MIXER_VERSION) --depth 1 \
			https://github.com/libsdl-org/SDL_mixer.git $(SDL_MIXER_DIR); \
	fi
	rm -rf $(SDL_MIXER_BUILD_DIR)
	mkdir -p $(SDL_MIXER_BUILD_DIR)
	cd $(SDL_MIXER_BUILD_DIR) && \
		PATH="$(SYSROOT)/usr/bin:$$PATH" \
		SDL_CONFIG="$(SYSROOT)/usr/bin/sdl-config" \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		CPPFLAGS="-I$(SYSROOT)/usr/include -I$(SYSROOT)/usr/include/SDL" \
		LDFLAGS="--sysroot=$(SYSROOT) -L$(SYSROOT)/usr/lib" \
		$(SDL_MIXER_DIR)/configure \
			--host=$(TARGET) \
			--prefix=/usr \
			--disable-shared \
			--enable-static
	PATH="$(SYSROOT)/usr/bin:$$PATH" \
		SDL_CONFIG="$(SYSROOT)/usr/bin/sdl-config" \
		$(MAKE) -C $(SDL_MIXER_BUILD_DIR) -j$(JOBS)

clean-build-sdl-mixer:
	rm -rf $(SDL_MIXER_BUILD_DIR)

install-sdl-mixer:
	test -f $(SDL_MIXER_BUILD_DIR)/build/.libs/libSDL_mixer.a
	$(MAKE) -C $(SDL_MIXER_BUILD_DIR) install DESTDIR=$(SYSROOT)

clean-install-sdl-mixer:
	rm -f $(SYSROOT)/usr/include/SDL/SDL_mixer.h
	rm -f $(SYSROOT)/usr/lib/pkgconfig/SDL_mixer.pc
	rm -f $(SYSROOT)/usr/lib/libSDL_mixer.a
	rm -f $(SYSROOT)/usr/lib/libSDL_mixer.la

# ------------------------------------------------------------------------------
# FreeType 2.4.8 (required by SDL_ttf 2.0.11)
# ------------------------------------------------------------------------------
build-freetype:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	@if [ ! -d "$(FREETYPE_DIR)/.git" ]; then \
		git clone --branch VER-2-4-8 --depth 1 \
			https://gitlab.freedesktop.org/freetype/freetype.git $(FREETYPE_DIR); \
	fi
	cd $(FREETYPE_DIR) && sh ./autogen.sh
	rm -rf $(FREETYPE_BUILD_DIR)
	mkdir -p $(FREETYPE_BUILD_DIR)
	cd $(FREETYPE_BUILD_DIR) && \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		CPPFLAGS="-I$(SYSROOT)/usr/include" \
		LDFLAGS="--sysroot=$(SYSROOT) -L$(SYSROOT)/usr/lib" \
		$(FREETYPE_DIR)/configure \
			--host=$(TARGET) \
			--prefix=/usr \
			--disable-shared \
			--enable-static
	$(MAKE) -C $(FREETYPE_BUILD_DIR) -j$(JOBS)

clean-build-freetype:
	rm -rf $(FREETYPE_BUILD_DIR)

install-freetype:
	test -f $(FREETYPE_BUILD_DIR)/.libs/libfreetype.a
	$(MAKE) -C $(FREETYPE_BUILD_DIR) install DESTDIR=$(SYSROOT)

clean-install-freetype:
	rm -f $(SYSROOT)/usr/lib/libfreetype.a
	rm -f $(SYSROOT)/usr/lib/libfreetype.la
	rm -rf $(SYSROOT)/usr/include/freetype2
	rm -f $(SYSROOT)/usr/include/ft2build.h
	rm -f $(SYSROOT)/usr/bin/freetype-config
	rm -f $(SYSROOT)/usr/share/aclocal/freetype2.m4
	rm -f $(SYSROOT)/usr/lib/pkgconfig/freetype2.pc

# ------------------------------------------------------------------------------
# SDL_ttf
# ------------------------------------------------------------------------------
build-sdl-ttf:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -f $(SYSROOT)/usr/lib/libSDL.a
	test -f $(SYSROOT)/usr/lib/libfreetype.a
	@if [ ! -d "$(SDL_TTF_DIR)/.git" ]; then \
		git clone --branch release-$(SDL_TTF_VERSION) --depth 1 \
			https://github.com/libsdl-org/SDL_ttf.git $(SDL_TTF_DIR); \
	fi
	rm -rf $(SDL_TTF_BUILD_DIR)
	mkdir -p $(SDL_TTF_BUILD_DIR)
	cd $(SDL_TTF_BUILD_DIR) && \
		PATH="$(SYSROOT)/usr/bin:$$PATH" \
		SDL_CONFIG="$(SYSROOT)/usr/bin/sdl-config" \
		FREETYPE_CONFIG="$(SYSROOT)/usr/bin/freetype-config" \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		CPPFLAGS="-I$(SYSROOT)/usr/include -I$(SYSROOT)/usr/include/SDL -I$(SYSROOT)/usr/include/freetype2" \
		LDFLAGS="--sysroot=$(SYSROOT) -L$(SYSROOT)/usr/lib" \
		$(SDL_TTF_DIR)/configure \
			--host=$(TARGET) \
			--prefix=/usr \
			--with-sdl-prefix=$(SYSROOT)/usr \
			--with-freetype-prefix=$(SYSROOT)/usr \
			--disable-shared \
			--enable-static
	PATH="$(SYSROOT)/usr/bin:$$PATH" \
		SDL_CONFIG="$(SYSROOT)/usr/bin/sdl-config" \
		FREETYPE_CONFIG="$(SYSROOT)/usr/bin/freetype-config" \
		$(MAKE) -C $(SDL_TTF_BUILD_DIR) -j$(JOBS)

clean-build-sdl-ttf:
	rm -rf $(SDL_TTF_BUILD_DIR)

install-sdl-ttf:
	test -f $(SDL_TTF_BUILD_DIR)/.libs/libSDL_ttf.a
	$(MAKE) -C $(SDL_TTF_BUILD_DIR) install DESTDIR=$(SYSROOT)

clean-install-sdl-ttf:
	rm -f $(SYSROOT)/usr/lib/libSDL_ttf.a
	rm -f $(SYSROOT)/usr/lib/libSDL_ttf.la
	rm -f $(SYSROOT)/usr/include/SDL/SDL_ttf.h
	rm -f $(SYSROOT)/usr/lib/pkgconfig/SDL_ttf.pc

# ------------------------------------------------------------------------------
# tinyalsa
# ------------------------------------------------------------------------------
build-tinyalsa:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	@if [ ! -d "$(TINYALSA_DIR)/.git" ]; then \
		git clone --branch v$(TINYALSA_VERSION) --depth 1 \
			https://github.com/tinyalsa/tinyalsa.git $(TINYALSA_DIR); \
	fi
	rm -rf $(TINYALSA_BUILD_DIR)
	cmake \
		-S $(TINYALSA_DIR) \
		-B $(TINYALSA_BUILD_DIR) \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_C_COMPILER=$(CROSS_COMPILE)gcc \
		-DCMAKE_SYSROOT=$(SYSROOT) \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_C_FLAGS="-Wno-error=overflow" \
		-DBUILD_SHARED_LIBS=OFF \
		-DTINYALSA_USES_PLUGINS=OFF \
		-DTINYALSA_BUILD_EXAMPLES=OFF \
		-DTINYALSA_BUILD_UTILS=OFF
	cmake --build $(TINYALSA_BUILD_DIR) -j$(JOBS)

clean-build-tinyalsa:
	rm -rf $(TINYALSA_BUILD_DIR)

install-tinyalsa:
	test -f $(TINYALSA_BUILD_DIR)/libtinyalsa.a
	DESTDIR=$(SYSROOT) cmake --install $(TINYALSA_BUILD_DIR)

clean-install-tinyalsa:
	rm -f $(SYSROOT)/usr/lib/libtinyalsa.a
	rm -rf $(SYSROOT)/usr/include/tinyalsa

# ------------------------------------------------------------------------------
# alsa-lib (required by picogpsp)
# ------------------------------------------------------------------------------
build-alsa-lib:
	@if [ ! -d "$(ALSA_LIB_DIR)/.git" ]; then \
		git clone --branch v$(ALSA_LIB_VERSION) --depth 1 \
			https://github.com/alsa-project/alsa-lib.git $(ALSA_LIB_DIR); \
	fi
	rm -rf $(ALSA_LIB_BUILD_DIR)
	mkdir -p $(ALSA_LIB_BUILD_DIR)
	cd $(ALSA_LIB_DIR) && ./gitcompile --help >/dev/null 2>&1 || true
	cd $(ALSA_LIB_DIR) && autoreconf -fi
	cd $(ALSA_LIB_BUILD_DIR) && \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		$(ALSA_LIB_DIR)/configure \
			--host=$(TARGET) \
			--prefix=/usr \
			--disable-shared \
			--enable-static
	$(MAKE) -C $(ALSA_LIB_BUILD_DIR) -j$(JOBS)

clean-build-alsa-lib:
	rm -rf $(ALSA_LIB_BUILD_DIR)

install-alsa-lib:
	test -f $(ALSA_LIB_BUILD_DIR)/src/.libs/libasound.a
	DESTDIR=$(SYSROOT) $(MAKE) -C $(ALSA_LIB_BUILD_DIR) install

clean-install-alsa-lib:
	rm -f $(SYSROOT)/usr/lib/libasound.a
	rm -f $(SYSROOT)/usr/lib/libasound.la
	rm -f $(SYSROOT)/usr/lib/pkgconfig/alsa.pc
	rm -rf $(SYSROOT)/usr/include/alsa

# ------------------------------------------------------------------------------
# bzip2 (required by Temper)
# ------------------------------------------------------------------------------
build-bzip2:
	@if [ ! -d "$(BZIP2_DIR)/.git" ]; then \
		git clone --branch bzip2-$(BZIP2_VERSION) --depth 1 \
			https://gitlab.com/bzip2/bzip2.git $(BZIP2_DIR); \
	fi
	rm -rf $(BZIP2_BUILD_DIR)
	mkdir -p $(BZIP2_BUILD_DIR)
	cp -R $(BZIP2_DIR)/. $(BZIP2_BUILD_DIR)/
	$(MAKE) -C $(BZIP2_BUILD_DIR) \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		CFLAGS="-O2 -fPIC" \
		libbz2.a

clean-build-bzip2:
	rm -rf $(BZIP2_BUILD_DIR)

install-bzip2:
	test -f $(BZIP2_BUILD_DIR)/libbz2.a
	mkdir -p $(SYSROOT)/usr/include
	mkdir -p $(SYSROOT)/usr/lib
	cp $(BZIP2_BUILD_DIR)/bzlib.h $(SYSROOT)/usr/include/
	cp $(BZIP2_BUILD_DIR)/libbz2.a $(SYSROOT)/usr/lib/

clean-install-bzip2:
	rm -f $(SYSROOT)/usr/include/bzlib.h
	rm -f $(SYSROOT)/usr/lib/libbz2.a

# ------------------------------------------------------------------------------
# libmad
# ------------------------------------------------------------------------------
build-libmad:
	@if [ ! -f "$(LIBMAD_ARCHIVE)" ]; then \
		curl -L \
			"https://sourceforge.net/projects/mad/files/libmad/$(LIBMAD_VERSION)/libmad-$(LIBMAD_VERSION).tar.gz/download" \
			-o "$(LIBMAD_ARCHIVE)"; \
	fi

	rm -rf $(LIBMAD_DIR)
	rm -rf $(LIBMAD_BUILD_DIR)

	mkdir -p $(LIBMAD_DIR)
	mkdir -p $(LIBMAD_BUILD_DIR)

	tar -xzf $(LIBMAD_ARCHIVE) \
		-C $(LIBMAD_DIR) \
		--strip-components=1

	cd $(LIBMAD_BUILD_DIR) && \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		CFLAGS="-O2" \
		$(LIBMAD_DIR)/configure \
			--host=$(TARGET) \
			--prefix=/usr \
			--disable-shared \
			--enable-static

	# libmad 0.15.1b génère des CFLAGS contenant -fforce-mem,
	# option obsolète supprimée des GCC modernes.
	# On surcharge CFLAGS au moment du make sans modifier les sources upstream.
	$(MAKE) -C $(LIBMAD_BUILD_DIR) \
		CFLAGS="-O2" \
		-j$(JOBS)

clean-build-libmad:
	rm -rf $(LIBMAD_BUILD_DIR)

install-libmad:
	test -f $(LIBMAD_BUILD_DIR)/.libs/libmad.a
	DESTDIR=$(SYSROOT) $(MAKE) -C $(LIBMAD_BUILD_DIR) install

clean-install-libmad:
	rm -f $(SYSROOT)/usr/lib/libmad.a
	rm -f $(SYSROOT)/usr/lib/libmad.la
	rm -f $(SYSROOT)/usr/include/mad.h
