# CROSS TOOL NG
CROSSTOOL_NG_VERSION := 1.27.0
CROSSTOOL_NG_DIR := /workspace/toolchain/crosstool-ng
TOOLCHAIN_CONFIG := /workspace/trimui-toolchain.config

TARGET := arm-unknown-linux-gnueabi

TOOLCHAIN_PREFIX := /workspace/toolchain/$(TARGET)
TOOLCHAIN_BIN := $(TOOLCHAIN_PREFIX)/bin
TOOLCHAIN_SYSROOT := $(TOOLCHAIN_PREFIX)/$(TARGET)/sysroot

INSTALL_BIN := /workspace/toolchain/bin
SYSROOT := /workspace/sysroot

BUILD_SYSROOT := /workspace/build/sysroot

COMPAT_TOOLCHAIN := /opt/trimui-toolchain
COMPAT_BIN := $(COMPAT_TOOLCHAIN)/bin
COMPAT_TARGET := arm-buildroot-linux-gnueabi

# ZLIB
ZLIB_VERSION := 1.3.1
ZLIB_DIR := /workspace/libs/zlib
ZLIB_BUILD_DIR := /workspace/build/zlib

CROSS_COMPILE := /workspace/toolchain/bin/$(TARGET)-

# SDL
SDL_VERSION := 1.2.15
SDL_DIR := /workspace/libs/SDL-1.2
SDL_BUILD_DIR := /workspace/build/SDL-1.2

# SDL_image
SDL_IMAGE_VERSION := 1.2.12
SDL_IMAGE_DIR := /workspace/libs/SDL_image
SDL_IMAGE_BUILD_DIR := /workspace/build/SDL_image

# SDL_mixer
SDL_MIXER_VERSION := 1.2.12
SDL_MIXER_DIR := /workspace/libs/SDL_mixer
SDL_MIXER_BUILD_DIR := /workspace/build/SDL_mixer

# Freetype
FREETYPE_VERSION := 2.4.8
FREETYPE_DIR := /workspace/libs/freetype
FREETYPE_BUILD_DIR := /workspace/build/freetype

# SDL_ttf
SDL_TTF_VERSION := 2.0.11
SDL_TTF_DIR := /workspace/libs/SDL_ttf
SDL_TTF_BUILD_DIR := /workspace/build/SDL_ttf

# Tinyalsa
TINYALSA_VERSION := 2.0.0
TINYALSA_DIR := /workspace/libs/tinyalsa
TINYALSA_BUILD_DIR := /workspace/build/tinyalsa

# Libpng
LIBPNG_VERSION := 1.6.58
LIBPNG_DIR := /workspace/libs/libpng
LIBPNG_BUILD_DIR := /workspace/build/libpng

# Alsa
ALSA_LIB_VERSION := 1.2.10
ALSA_LIB_DIR := /workspace/libs/alsa-lib
ALSA_LIB_BUILD_DIR := /workspace/build/alsa-lib

# bzip
BZIP2_VERSION := 1.0.8
BZIP2_DIR := /workspace/libs/bzip2
BZIP2_BUILD_DIR := /workspace/build/bzip2

# Minui
MINUI_DIR := /workspace/sources/minui
MINUI_PICODRIVE_DIR := $(MINUI_DIR)/third-party/picodrive
MINUI_BUILD_DIR := $(MINUI_DIR)/build
MINUI_PAYLOAD_DIR := $(MINUI_BUILD_DIR)/PAYLOAD
MINUI_ROMS_DIR := $(MINUI_BUILD_DIR)/Roms

.PHONY: \
	shell \
	build-toolchain \
	clean-build-toolchain \
	install-toolchain \
	clean-install-toolchain \
	build-zlib \
	clean-build-zlib \
	install-zlib \
	clean-install-zlib \
	build-sdl \
	clean-build-sdl \
	install-sdl \
	clean-install-sdl \
	build-sdl-image \
	clean-build-sdl-image \
	install-sdl-image \
	clean-install-sdl-image \
	build-sdl-mixer \
	clean-build-sdl-mixer \
	install-sdl-mixer \
	clean-install-sdl-mixer \
	build-freetype \
	clean-build-freetype \
	install-freetype \
	clean-install-freetype \
	build-sdl-ttf \
	clean-build-sdl-ttf \
	install-sdl-ttf \
	clean-install-sdl-ttf \
	build-tinyalsa \
	clean-build-tinyalsa \
	install-tinyalsa \
	clean-install-tinyalsa \
	prepare-build-sysroot \
	build-libs \
	clean-build-libs \
	install-libs \
	clean-install-libs \
	build-minui \
	clean-build-minui

shell:
	docker compose run --rm builder

prepare-build-sysroot:
	test -d $(TOOLCHAIN_SYSROOT)
	rm -rf $(BUILD_SYSROOT)
	mkdir -p $(BUILD_SYSROOT)
	rsync -a $(TOOLCHAIN_SYSROOT)/ $(BUILD_SYSROOT)/
	chmod -R u+w $(BUILD_SYSROOT)

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

clean-build-libs:
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

clean-install-libs:
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

build-toolchain:
	@if [ ! -d "$(CROSSTOOL_NG_DIR)/.git" ]; then \
		git clone \
			--branch crosstool-ng-$(CROSSTOOL_NG_VERSION) \
			--depth 1 \
			https://github.com/crosstool-ng/crosstool-ng.git \
			$(CROSSTOOL_NG_DIR); \
	fi
	cd $(CROSSTOOL_NG_DIR) && ./bootstrap
	cd $(CROSSTOOL_NG_DIR) && ./configure --enable-local
# 	$(MAKE) -C $(CROSSTOOL_NG_DIR) -j"$$(nproc)"
	$(MAKE) -C $(CROSSTOOL_NG_DIR) -j"4"
	cp $(TOOLCHAIN_CONFIG) $(CROSSTOOL_NG_DIR)/.config
	cd $(CROSSTOOL_NG_DIR) && ./ct-ng olddefconfig
# 	cd $(CROSSTOOL_NG_DIR) && ./ct-ng build.$$(nproc)
	cd $(CROSSTOOL_NG_DIR) && ./ct-ng build.4

clean-build-toolchain:
	rm -rf $(CROSSTOOL_NG_DIR)
	rm -rf /workspace/toolchain/arm-unknown-linux-gnueabi

install-toolchain:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -d $(TOOLCHAIN_SYSROOT)
	mkdir -p $(INSTALL_BIN)
	ln -sfn $(TOOLCHAIN_BIN)/* $(INSTALL_BIN)/
	mkdir -p $(SYSROOT)
	rsync -a $(TOOLCHAIN_SYSROOT)/ $(SYSROOT)/
	chmod -R u+w $(SYSROOT)
		mkdir -p $(COMPAT_BIN)
	mkdir -p $(COMPAT_TOOLCHAIN)/$(COMPAT_TARGET)

	ln -sfn $(SYSROOT) \
		$(COMPAT_TOOLCHAIN)/$(COMPAT_TARGET)/sysroot

	@for tool in ar as nm objcopy objdump ranlib readelf size strings strip ld; do \
		ln -sfn $(TOOLCHAIN_BIN)/$(TARGET)-$$tool \
			$(COMPAT_BIN)/$(COMPAT_TARGET)-$$tool; \
	done

	printf '%s\n' \
		'#!/bin/sh' \
		'for arg in "$$@"; do' \
		'    case "$$arg" in' \
		'        -c|-E|-S|-M|-MM) exec $(TOOLCHAIN_BIN)/$(TARGET)-gcc --sysroot=$(SYSROOT) "$$@" ;;' \
		'    esac' \
		'done' \
		'exec $(TOOLCHAIN_BIN)/$(TARGET)-gcc --sysroot=$(SYSROOT) "$$@" -lfreetype -lz -lm -lpthread' \
		> $(COMPAT_BIN)/$(COMPAT_TARGET)-gcc
	chmod +x $(COMPAT_BIN)/$(COMPAT_TARGET)-gcc

	printf '%s\n' \
		'#!/bin/sh' \
		'for arg in "$$@"; do' \
		'    case "$$arg" in' \
		'        -c|-E|-S|-M|-MM) exec $(TOOLCHAIN_BIN)/$(TARGET)-g++ --sysroot=$(SYSROOT) "$$@" ;;' \
		'    esac' \
		'done' \
		'exec $(TOOLCHAIN_BIN)/$(TARGET)-g++ --sysroot=$(SYSROOT) "$$@" -Wl,--start-group -lSDL -lSDL_ttf -lfreetype -lSDL_image -lpng -lz -lm -lpthread -ldl -Wl,--end-group' \
		> $(COMPAT_BIN)/$(COMPAT_TARGET)-g++
	chmod +x $(COMPAT_BIN)/$(COMPAT_TARGET)-g++

	rm -f $(COMPAT_BIN)/arm-linux-gcc
	printf '%s\n' \
		'#!/bin/sh' \
		'exec $(COMPAT_BIN)/$(COMPAT_TARGET)-gcc -fgnu89-inline "$$@"' \
		> $(COMPAT_BIN)/arm-linux-gcc
	chmod +x $(COMPAT_BIN)/arm-linux-gcc

	ln -sfn $(COMPAT_BIN)/$(COMPAT_TARGET)-strip \
		$(COMPAT_BIN)/arm-linux-strip

clean-install-toolchain:
	rm -rf $(INSTALL_BIN)
	chmod -R u+w $(SYSROOT) 2>/dev/null || true
	rm -rf $(SYSROOT)
	rm -rf $(COMPAT_TOOLCHAIN)/bin
	rm -rf $(COMPAT_TOOLCHAIN)/$(COMPAT_TARGET)
	mkdir -p $(SYSROOT)

build-zlib:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -d $(SYSROOT)
	@if [ ! -d "$(ZLIB_DIR)/.git" ]; then \
		git clone \
			--branch v$(ZLIB_VERSION) \
			--depth 1 \
			https://github.com/madler/zlib.git \
			$(ZLIB_DIR); \
	fi
	rm -rf $(ZLIB_BUILD_DIR)
	mkdir -p $(ZLIB_BUILD_DIR)
	cd $(ZLIB_BUILD_DIR) && \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(SYSROOT)" \
		AR="$(CROSS_COMPILE)ar" \
		RANLIB="$(CROSS_COMPILE)ranlib" \
		$(ZLIB_DIR)/configure \
			--prefix=/usr \
			--static
# 	$(MAKE) -C $(ZLIB_BUILD_DIR) -j"$$(nproc)"
	$(MAKE) -C $(ZLIB_BUILD_DIR) -j"4"

clean-build-zlib:
	rm -rf $(ZLIB_BUILD_DIR)
	rm -rf $(ZLIB_DIR)

install-zlib:
	test -f $(ZLIB_BUILD_DIR)/libz.a
	$(MAKE) -C $(ZLIB_BUILD_DIR) install DESTDIR=$(SYSROOT)

clean-install-zlib:
	rm -f $(SYSROOT)/usr/lib/libz.a
	rm -f $(SYSROOT)/usr/include/zlib.h
	rm -f $(SYSROOT)/usr/include/zconf.h
	rm -f $(SYSROOT)/usr/lib/pkgconfig/zlib.pc
	rm -f $(SYSROOT)/usr/share/man/man3/zlib.3

build-sdl:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -d $(SYSROOT)
	@if [ ! -d "$(SDL_DIR)/.git" ]; then \
		git clone \
			--branch release-$(SDL_VERSION) \
			--depth 1 \
			https://github.com/libsdl-org/SDL-1.2.git \
			$(SDL_DIR); \
	fi
	cd $(SDL_DIR) && ./autogen.sh
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
# 	$(MAKE) -C $(SDL_BUILD_DIR) -j"$$(nproc)"
	$(MAKE) -C $(SDL_BUILD_DIR) -j"4"

clean-build-sdl:
	rm -rf $(SDL_BUILD_DIR)
	rm -rf $(SDL_DIR)

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
	rm -f $(SYSROOT)/usr/bin/sdl-config
	rm -f $(SYSROOT)/usr/bin/sdl-config.real

build-sdl-image:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -f $(SYSROOT)/usr/lib/libSDL.a
	@if [ ! -d "$(SDL_IMAGE_DIR)/.git" ]; then \
		git clone \
			--branch release-$(SDL_IMAGE_VERSION) \
			--depth 1 \
			https://github.com/libsdl-org/SDL_image.git \
			$(SDL_IMAGE_DIR); \
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
		$(MAKE) -C $(SDL_IMAGE_BUILD_DIR) -j"4"
# 		$(MAKE) -C $(SDL_IMAGE_BUILD_DIR) -j"$$(nproc)"
clean-build-sdl-image:
	rm -rf $(SDL_IMAGE_BUILD_DIR)
	rm -rf $(SDL_IMAGE_DIR)

install-sdl-image:
	test -f $(SDL_IMAGE_BUILD_DIR)/.libs/libSDL_image.a
	$(MAKE) -C $(SDL_IMAGE_BUILD_DIR) install DESTDIR=$(SYSROOT)

clean-install-sdl-image:
	rm -f $(SYSROOT)/usr/lib/libSDL_image.a
	rm -f $(SYSROOT)/usr/lib/libSDL_image.la
	rm -f $(SYSROOT)/usr/include/SDL/SDL_image.h
	rm -f $(SYSROOT)/usr/lib/pkgconfig/SDL_image.pc

build-sdl-mixer:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -f $(SYSROOT)/usr/lib/libSDL.a
	@if [ ! -d "$(SDL_MIXER_DIR)/.git" ]; then \
		git clone \
			--branch release-$(SDL_MIXER_VERSION) \
			--depth 1 \
			https://github.com/libsdl-org/SDL_mixer.git \
			$(SDL_MIXER_DIR); \
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
	$(MAKE) -C $(SDL_MIXER_BUILD_DIR) -j"4"
# 	$(MAKE) -C $(SDL_MIXER_BUILD_DIR) -j"$$(nproc)"

clean-build-sdl-mixer:
	rm -rf $(SDL_MIXER_BUILD_DIR)
	rm -rf $(SDL_MIXER_DIR)

install-sdl-mixer:
	test -f $(SDL_MIXER_BUILD_DIR)/build/.libs/libSDL_mixer.a
	$(MAKE) -C $(SDL_MIXER_BUILD_DIR) install DESTDIR=$(SYSROOT)

clean-install-sdl-mixer:
	rm -f $(SYSROOT)/usr/include/SDL/SDL_mixer.h
	rm -f $(SYSROOT)/usr/lib/pkgconfig/SDL_mixer.pc
	rm -f $(SYSROOT)/usr/lib/libSDL_mixer.a
	rm -f $(SYSROOT)/usr/lib/libSDL_mixer.la

build-freetype:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	@if [ ! -d "$(FREETYPE_DIR)/.git" ]; then \
		git clone \
			--branch VER-2-4-8 \
			--depth 1 \
			https://gitlab.freedesktop.org/freetype/freetype.git \
			$(FREETYPE_DIR); \
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
	$(MAKE) -C $(FREETYPE_BUILD_DIR) -j"4"
# 	$(MAKE) -C $(FREETYPE_BUILD_DIR) -j"$$(nproc)"

clean-build-freetype:
	rm -rf $(FREETYPE_BUILD_DIR)
	rm -rf $(FREETYPE_DIR)

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

build-sdl-ttf:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	test -f $(SYSROOT)/usr/lib/libSDL.a
	test -f $(SYSROOT)/usr/lib/libfreetype.a
	@if [ ! -d "$(SDL_TTF_DIR)/.git" ]; then \
		git clone \
			--branch release-$(SDL_TTF_VERSION) \
			--depth 1 \
			https://github.com/libsdl-org/SDL_ttf.git \
			$(SDL_TTF_DIR); \
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
	$(MAKE) -C $(SDL_TTF_BUILD_DIR) -j"4"
# 	$(MAKE) -C $(SDL_TTF_BUILD_DIR) -j"$$(nproc)"

clean-build-sdl-ttf:
	rm -rf $(SDL_TTF_BUILD_DIR)
	rm -rf $(SDL_TTF_DIR)

install-sdl-ttf:
	test -f $(SDL_TTF_BUILD_DIR)/.libs/libSDL_ttf.a
	$(MAKE) -C $(SDL_TTF_BUILD_DIR) install DESTDIR=$(SYSROOT)

clean-install-sdl-ttf:
	rm -f $(SYSROOT)/usr/lib/libSDL_ttf.a
	rm -f $(SYSROOT)/usr/lib/libSDL_ttf.la
	rm -f $(SYSROOT)/usr/include/SDL/SDL_ttf.h
	rm -f $(SYSROOT)/usr/lib/pkgconfig/SDL_ttf.pc

build-tinyalsa:
	test -x $(TOOLCHAIN_BIN)/$(TARGET)-gcc
	@if [ ! -d "$(TINYALSA_DIR)/.git" ]; then \
		git clone \
			--branch v$(TINYALSA_VERSION) \
			--depth 1 \
			https://github.com/tinyalsa/tinyalsa.git \
			$(TINYALSA_DIR); \
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
	cmake --build $(TINYALSA_BUILD_DIR) -j"4"
# 	cmake --build $(TINYALSA_BUILD_DIR) -j"$$(nproc)"

clean-build-tinyalsa:
	rm -rf $(TINYALSA_BUILD_DIR)
	rm -rf $(TINYALSA_DIR)

install-tinyalsa:
	test -f $(TINYALSA_BUILD_DIR)/libtinyalsa.a
	DESTDIR=$(SYSROOT) cmake --install $(TINYALSA_BUILD_DIR)

clean-install-tinyalsa:
	rm -f $(SYSROOT)/usr/lib/libtinyalsa.a
	rm -rf $(SYSROOT)/usr/include/tinyalsa

build-libpng:
	@if [ ! -d "$(LIBPNG_DIR)/.git" ]; then \
		git clone \
			--branch v$(LIBPNG_VERSION) \
			--depth 1 \
			https://github.com/pnggroup/libpng.git \
			$(LIBPNG_DIR); \
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
	$(MAKE) -C $(LIBPNG_BUILD_DIR) -j"4"
# 	$(MAKE) -C $(LIBPNG_BUILD_DIR) -j"$$(nproc)"

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

build-alsa-lib:
	@if [ ! -d "$(ALSA_LIB_DIR)/.git" ]; then \
		git clone \
			--branch v$(ALSA_LIB_VERSION) \
			--depth 1 \
			https://github.com/alsa-project/alsa-lib.git \
			$(ALSA_LIB_DIR); \
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
	$(MAKE) -C $(ALSA_LIB_BUILD_DIR) -j"4"
# 	$(MAKE) -C $(ALSA_LIB_BUILD_DIR) -j"$$(nproc)"

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

build-bzip2:
	@if [ ! -d "$(BZIP2_DIR)/.git" ]; then \
		git clone \
			--branch bzip2-$(BZIP2_VERSION) \
			--depth 1 \
			https://gitlab.com/bzip2/bzip2.git \
			$(BZIP2_DIR); \
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

build-minui:
	$(MAKE) -C $(MINUI_DIR) readme
	$(MAKE) -C $(MINUI_DIR) sys

	$(MAKE) -C $(MINUI_DIR) gb
	$(MAKE) -C $(MINUI_DIR) pm
	$(MAKE) -C $(MINUI_DIR) ngp
	$(MAKE) -C $(MINUI_DIR) gg
	$(MAKE) -C $(MINUI_DIR) snes
	$(MAKE) -C $(MINUI_DIR) ps
	$(MAKE) -C $(MINUI_DIR) gba
	$(MAKE) -C $(MINUI_DIR) nes

	# PicoDrive : équivalent de la cible "gen" de MinUI,
	# avec le skin réellement présent dans ce commit.
	mkdir -p "$(MINUI_ROMS_DIR)/Genesis"
	mkdir -p "$(MINUI_PAYLOAD_DIR)/Emus"

	@if [ ! -f "$(MINUI_PICODRIVE_DIR)/config.mak" ]; then \
		cd "$(MINUI_PICODRIVE_DIR)" && \
		CROSS_COMPILE=$(COMPAT_BIN)/$(COMPAT_TARGET)- \
			./configure --platform=trimui; \
	fi

	cd "$(MINUI_PICODRIVE_DIR)" && $(MAKE) -j"4"
# 	cd "$(MINUI_PICODRIVE_DIR)" && $(MAKE) -j"$$(nproc)"

	rm -rf "$(MINUI_PAYLOAD_DIR)/Emus/Genesis.pak"
	cp -R \
		"$(MINUI_DIR)/paks/Genesis.pak" \
		"$(MINUI_PAYLOAD_DIR)/Emus"

	cp \
		"$(MINUI_PICODRIVE_DIR)/PicoDrive" \
		"$(MINUI_PAYLOAD_DIR)/Emus/Genesis.pak"

	mkdir -p "$(MINUI_PAYLOAD_DIR)/Emus/Genesis.pak/skin"
	cp -R \
		"$(MINUI_PICODRIVE_DIR)/platform/opendingux/data/skin/." \
		"$(MINUI_PAYLOAD_DIR)/Emus/Genesis.pak/skin/"

	$(MAKE) -C $(MINUI_DIR) pce
	$(MAKE) -C $(MINUI_DIR) swan
	$(MAKE) -C $(MINUI_DIR) lynx

	$(MAKE) -C $(MINUI_DIR) tools
	$(MAKE) -C $(MINUI_DIR) zip

clean-build-minui:
	# MinUI system
	$(MAKE) -C $(MINUI_DIR)/src/libmmenu clean
	$(MAKE) -C $(MINUI_DIR)/src/MinUI clean
	$(MAKE) -C $(MINUI_DIR)/src/show clean
	$(MAKE) -C $(MINUI_DIR)/src/confirm clean
	$(MAKE) -C $(MINUI_DIR)/src/flipbook clean
	$(MAKE) -C $(MINUI_DIR)/TrimuiUpdate clean

	# libmsettings et keymon ne sont pas nettoyés par clean-sys upstream
	rm -f \
		$(MINUI_DIR)/src/libmsettings/msettings.o \
		$(MINUI_DIR)/src/libmsettings/libmsettings.so \
		$(MINUI_DIR)/src/keymon/keymon

	# SDL embarquée
	rm -f \
		$(MINUI_DIR)/third-party/SDL-1.2/SDL.spec \
		$(MINUI_DIR)/third-party/SDL-1.2/include/SDL_config.h \
		$(MINUI_DIR)/third-party/SDL-1.2/sdl.pc

	# Tools
	$(MAKE) -C $(MINUI_DIR)/third-party/DinguxCommander clean

	# Emulators
	$(MAKE) -C $(MINUI_DIR)/third-party/gambatte-dms clean
	$(MAKE) -C $(MINUI_DIR)/third-party/pokemini/platform/trimui clean
	$(MAKE) -C $(MINUI_DIR)/third-party/race clean
	$(MAKE) -C $(MINUI_DIR)/third-party/sms_sdl clean
	$(MAKE) -C $(MINUI_DIR)/third-party/snes9x2002 clean
	$(MAKE) -C $(MINUI_DIR)/third-party/pcsx_rearmed clean
	$(MAKE) -C $(MINUI_DIR)/third-party/picogpsp clean
	$(MAKE) -C $(MINUI_DIR)/third-party/fceux clean

	# PicoDrive utilise PWD dans son Makefile
	cd "$(MINUI_PICODRIVE_DIR)" && $(MAKE) clean

	$(MAKE) -C $(MINUI_DIR)/third-party/temper/SDL clean

	# Oswan : son make clean utilise rm sans -f et échoue
	# si les fichiers sont déjà absents.
	rm -f \
		$(MINUI_DIR)/third-party/oswan/main/sdl/main.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/menu.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/input.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/game_input.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/cpu/nec.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/WS.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/WSFileio.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/WSRender.o \
		$(MINUI_DIR)/third-party/oswan/main/emu/WSApu.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/gui_drawing.o \
		$(MINUI_DIR)/third-party/oswan/main/sdl/drawing.o \
		$(MINUI_DIR)/third-party/oswan/oswan

	# Handy
	$(MAKE) -C $(MINUI_DIR)/third-party/handy-rs97 clean

	# Assemblage généré par MinUI
	rm -rf $(MINUI_DIR)/build
	rm -rf $(MINUI_DIR)/release
