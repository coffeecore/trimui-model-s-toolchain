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
	clean-install-libs

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

clean-build-libs:
	$(MAKE) clean-build-tinyalsa
	$(MAKE) clean-build-sdl-ttf
	$(MAKE) clean-build-freetype
	$(MAKE) clean-build-sdl-mixer
	$(MAKE) clean-build-sdl-image
	$(MAKE) clean-build-sdl
	$(MAKE) clean-build-zlib
	chmod -R u+w $(BUILD_SYSROOT) 2>/dev/null || true
	rm -rf $(BUILD_SYSROOT)

install-libs:
	$(MAKE) install-zlib
	$(MAKE) install-sdl
	$(MAKE) install-sdl-image
	$(MAKE) install-sdl-mixer
	$(MAKE) install-freetype
	$(MAKE) install-sdl-ttf
	$(MAKE) install-tinyalsa

clean-install-libs:
	$(MAKE) clean-install-tinyalsa
	$(MAKE) clean-install-sdl-ttf
	$(MAKE) clean-install-freetype
	$(MAKE) clean-install-sdl-mixer
	$(MAKE) clean-install-sdl-image
	$(MAKE) clean-install-sdl
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
		'exec $(TOOLCHAIN_BIN)/$(TARGET)-gcc --sysroot=$(SYSROOT) "$$@" -lfreetype -lz -pthread' \
		> $(COMPAT_BIN)/$(COMPAT_TARGET)-gcc
	chmod +x $(COMPAT_BIN)/$(COMPAT_TARGET)-gcc

	printf '%s\n' \
		'#!/bin/sh' \
		'exec $(TOOLCHAIN_BIN)/$(TARGET)-g++ --sysroot=$(SYSROOT) "$$@"' \
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
