# -----------------------------------------------------------------------------
# PicoArch - Trimui Model S
# -----------------------------------------------------------------------------

PICOARCH_REPO := https://github.com/coffeecore/picoarch.git
PICOARCH_SOURCE := $(RELEASE_SOURCES_DIR)/picoarch
PICOARCH_BUILD := $(WORKSPACE)/build/picoarch
PICOARCH_CORE_SOURCES := $(WORKSPACE)/build/picoarch-sources
PICOARCH_PATCHES := $(WORKSPACE)/patches/picoarch
PICOARCH_PREPARED_STAMP := $(PICOARCH_BUILD)/.prepared

PICOARCH_PLATFORM := trimui
PICOARCH_CROSS := $(CROSS_COMPILE)
PICOARCH_CC := $(PICOARCH_CROSS)gcc
PICOARCH_CXX := $(PICOARCH_CROSS)g++

# Exact PicoArch revision validated for Trimui Model S
PICOARCH_REV := 53e0e6b2b72b8c50e6b9fceb437dfa8c650d05c5


# -----------------------------------------------------------------------------
# Validated core revisions
# -----------------------------------------------------------------------------

FCEUMM_REV := b5e3566515c27dc66c9c20572171673126532e06
GAMBATTE_REV := 96174369b3c30d9fc57c926fa3379c273dc6a9a5
GPSP_REV := 5b6e751f4abf368509146cd143c949c1946ac1ae
PICODRIVE_REV := 6248b51ffbe212ce441de023ccea6b10fa4d7082
MAME2000_REV := f099ba44c7664906fd7e01cbed89d13a7e32dee1
MAME2003_REV := 259339e92d5f63e4b293ce0d42a069f9e8ba2a6a
PCSX_REARMED_REV := da2cb8ecd17fd0932ab6d94774c0522beebce6e3
BEETLE_PCE_FAST_REV := b211204c7026dff6e86e79b00185512e2421fff8
BLUEMSX_REV := 0f32f52c48d3e772bfdf0379756f81f00b4e08bc
FMSX_REV := f013e213458e06d9df718e4bc4b09d46f88aa899
GME_REV := 1562f6207a066e9807243c89648d1cb44e411971
MEDNAFEN_NGP_REV := a50d5ac288a81f2104ddf43195a4efdd15c72227
MEDNAFEN_WSWAN_REV := 4b01295838ea89e3f1355bbe4cb5cf98aa6108cd
POKEMINI_REV := 132111b76343559860532a1ccc094f93f1ed5650
QUICKNES_REV := 26bb785c9deddb66a17717b21bb4e328f03ade32
SMSPLUS_GX_REV := 8a63f82d3c3bbf7215a31f86a4aaa13fb68a579f
SNES9X2002_REV := 5bd8bd6d449be8a2ef7909e1aeb2bd8c9c0da8cb
SNES9X2005_REV := deb49d80d1836e3e737480a326e31a54c46c04ae
STELLA2014_REV := 4a7da82595d27b8df7af1ecb467a64b642a41bc9
MAME2003_PLUS_REV := e9cebbf19dec88d52469bfa1f4a0add4c82fd9df
SNES9X2010_REV := 421a8d9449031245f1dfdb632b84548a9f19fddd
SNES9X2005_PLUS_REV := deb49d80d1836e3e737480a326e31a54c46c04ae
FAKE08_REV := 814991a2571ad3970e386cef48f3b148aa1c27b9
PRBOOM_REV := c180d47a5f9f1b5f74be18bf74deb5eccf97057e
FBALPHA2012_REV := 0ce31536bef3162fe7e69ff5f555334ec4913cef

# -----------------------------------------------------------------------------
# Core repositories
# -----------------------------------------------------------------------------

FCEUMM_REPO := https://github.com/libretro/libretro-fceumm.git
GAMBATTE_REPO := https://github.com/libretro/gambatte-libretro.git
GPSP_REPO := https://github.com/libretro/gpsp.git
PICODRIVE_REPO := https://github.com/libretro/picodrive.git
MAME2000_REPO := https://github.com/libretro/mame2000-libretro.git
MAME2003_REPO := https://github.com/libretro/mame2003-libretro.git
PCSX_REARMED_REPO := https://github.com/libretro/pcsx_rearmed.git
BEETLE_PCE_FAST_REPO := https://github.com/libretro/beetle-pce-fast-libretro.git
BLUEMSX_REPO := https://github.com/libretro/blueMSX-libretro.git
FMSX_REPO := https://github.com/libretro/fmsx-libretro.git
GME_REPO := https://github.com/libretro/libretro-gme.git
MEDNAFEN_NGP_REPO := https://github.com/libretro/beetle-ngp-libretro.git
MEDNAFEN_WSWAN_REPO := https://github.com/libretro/beetle-wswan-libretro.git
POKEMINI_REPO := https://github.com/libretro/PokeMini.git
QUICKNES_REPO := https://github.com/libretro/QuickNES_Core.git
SMSPLUS_GX_REPO := https://github.com/libretro/smsplus-gx.git
SNES9X2002_REPO := https://github.com/libretro/snes9x2002.git
SNES9X2005_REPO := https://github.com/libretro/snes9x2005.git
STELLA2014_REPO := https://github.com/libretro/stella2014-libretro.git
MAME2003_PLUS_REPO := https://github.com/libretro/mame2003-plus-libretro.git
SNES9X2010_REPO := https://github.com/libretro/snes9x2010.git
SNES9X2005_PLUS_REPO := https://github.com/libretro/snes9x2005.git
FAKE08_REPO := https://github.com/jtothebell/fake-08.git
PRBOOM_REPO := https://github.com/libretro/libretro-prboom.git
FBALPHA2012_REPO := https://github.com/libretro/fbalpha2012.git


# -----------------------------------------------------------------------------
# Common PicoArch build arguments
# -----------------------------------------------------------------------------

PICOARCH_MAKE_ARGS := \
	platform=$(PICOARCH_PLATFORM) \
	CROSS_COMPILE=$(PICOARCH_CROSS) \
	CXX=$(PICOARCH_CXX) \
	CC_FOR_BUILD=gcc \
	CXX_FOR_BUILD=g++

# -----------------------------------------------------------------------------
# PicoArch source/build tree and frontend (MinUI)
# -----------------------------------------------------------------------------

# Keep a pinned pristine-ish release checkout under build/release-sources/. The working tree in
# build/picoarch is a full copy of that checkout (including the top-level
# Makefile and upstream patches), so the core targets such as
# fceumm_libretro.so are available.
.PHONY: source-picoarch prepare-picoarch picoarch-check-patches \
	picoarch-frontend _build-picoarch-frontend picoarch-clean-frontend clean-source-picoarch

source-picoarch:
	@if [ ! -d "$(PICOARCH_SOURCE)/.git" ]; then \
		mkdir -p "$(dir $(PICOARCH_SOURCE))"; \
		git clone --recursive "$(PICOARCH_REPO)" "$(PICOARCH_SOURCE)"; \
	fi
	git -C "$(PICOARCH_SOURCE)" checkout --detach "$(PICOARCH_REV)"
	git -C "$(PICOARCH_SOURCE)" submodule update --init --recursive

prepare-picoarch: source-picoarch
	@if [ ! -f "$(PICOARCH_PREPARED_STAMP)" ]; then \
		rm -rf "$(PICOARCH_BUILD)"; \
		mkdir -p "$(dir $(PICOARCH_BUILD))"; \
		cp -a "$(PICOARCH_SOURCE)" "$(PICOARCH_BUILD)"; \
		cp "$(PICOARCH_PATCHES)/libpicofe/0001-key-combos.patch" \
			"$(PICOARCH_BUILD)/patches/libpicofe/0001-key-combos.patch"; \
		for patch_file in "$(PICOARCH_PATCHES)"/frontend/*.patch; do \
			patch -l -d "$(PICOARCH_BUILD)" -p1 < "$$patch_file"; \
		done; \
		touch "$(PICOARCH_PREPARED_STAMP)"; \
	fi

# Fail before cloning any core if the pinned PicoArch checkout does not contain
# every upstream patch referenced by our core recipes.
picoarch-check-patches: prepare-picoarch
	@set -e; \
	for patch_file in \
		patches/beetle-pce-fast/1000-trimui-build.patch \
		patches/bluemsx/1000-trimui-build.patch \
		patches/fceumm/1000-trimui-build.patch \
		patches/fmsx/1000-trimui-build.patch \
		patches/gambatte/0001-ghosting-fastest.patch \
		patches/gambatte/1000-trimui-build.patch \
		patches/gme/1000-trimui-build.patch \
		patches/gpsp/1000-trimui-build.patch \
		patches/gpsp/1002-frameskip-changes.patch \
		patches/mame2000/0002-arm-generic-target.patch \
		patches/mame2000/1000-trimui-build.patch \
		patches/mame2000/1002-reduce-vector-game-res.patch \
		patches/picodrive/0001-frameskip-interval.patch \
		patches/picodrive/1000-trimui-build.patch \
		patches/quicknes/1000-trimui-build.patch \
		patches/smsplus-gx/1000-trimui-build.patch \
		patches/snes9x2002/0001-frameskip-interval-max.patch \
		patches/snes9x2002/1000-trimui-support.patch; do \
		test -f "$(PICOARCH_BUILD)/$$patch_file" || { \
			echo "ERROR: missing upstream PicoArch patch: $$patch_file" >&2; \
			exit 1; \
		}; \
	done

# The frontend and every core now share the same complete PicoArch working tree.
# This is required because the root Makefile owns the *_libretro.so targets.
picoarch-frontend: minui-libs picoarch-check-patches
	$(MAKE) _build-picoarch-frontend

_build-picoarch-frontend:
	test -x "$(TOOLCHAIN_SYSROOT)/usr/bin/sdl-config"
	test -f "$(MINUI_MMENU_BUILD)/mmenu.h"

	PATH="$(TOOLCHAIN_SYSROOT)/usr/bin:$$PATH" \
		$(MAKE) -C $(PICOARCH_BUILD) \
		platform=$(PICOARCH_PLATFORM) \
		MINUI=1 \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CC="$(PICOARCH_CC) --sysroot=$(TOOLCHAIN_SYSROOT) -I$(MINUI_MMENU_BUILD)" \
		CXX="$(PICOARCH_CXX) --sysroot=$(TOOLCHAIN_SYSROOT) -I$(MINUI_MMENU_BUILD)" \
		picoarch

	test -x "$(PICOARCH_BUILD)/picoarch"

# Removing the frontend working tree also removes any cores copied into it.
# Core source checkouts under build/picoarch-sources are kept separately.
picoarch-clean-frontend:
	rm -rf $(PICOARCH_BUILD)

clean-source-picoarch:
	rm -rf $(PICOARCH_SOURCE)

# -----------------------------------------------------------------------------
# PicoArch output
# -----------------------------------------------------------------------------

PICOARCH_OUTPUT := /workspace/output/picoarch
PICOARCH_OUTPUT_CORES := $(PICOARCH_OUTPUT)/cores

.PHONY: picoarch-output picoarch-clean-output

picoarch-output:
	test -x $(PICOARCH_BUILD)/picoarch
	@test "$$(find $(PICOARCH_BUILD) -maxdepth 1 -type f -name '*_libretro.so' \
		! -name 'fake08_libretro.so' \
		| wc -l)" -eq 27 || { \
		echo "ERROR: expected 27 validated PicoArch cores in $(PICOARCH_BUILD)" >&2; \
		exit 1; \
	}
	rm -rf $(PICOARCH_OUTPUT)

	mkdir -p $(PICOARCH_OUTPUT_CORES)

	cp \
		$(PICOARCH_BUILD)/picoarch \
		$(PICOARCH_OUTPUT)/picoarch

	find $(PICOARCH_BUILD) \
		-maxdepth 1 \
		-type f \
		-name '*_libretro.so' \
		! -name 'fake08_libretro.so' \
		-exec cp {} $(PICOARCH_OUTPUT_CORES)/ \;

picoarch-clean-output:
	rm -rf $(PICOARCH_OUTPUT)

# -----------------------------------------------------------------------------
# Groups
# -----------------------------------------------------------------------------

.PHONY: picoarch-validated
picoarch-validated: picoarch-check-patches \
	picoarch-fceumm \
	picoarch-gambatte \
	picoarch-gpsp \
	picoarch-picodrive \
	picoarch-mame2000 \
	picoarch-pcsx-rearmed \
	picoarch-beetle-pce-fast \
	picoarch-bluemsx \
	picoarch-fmsx \
	picoarch-gme \
	picoarch-mednafen-ngp \
	picoarch-mednafen-wswan \
	picoarch-pokemini \
	picoarch-quicknes \
	picoarch-smsplus-gx \
	picoarch-snes9x2002 \
	picoarch-snes9x2005 \
	picoarch-stella2014 \
	picoarch-snes9x2010 \
	picoarch-snes9x2005-plus \
	picoarch-prboom \
	picoarch-fbalpha2012 \
	picoarch-mame2003-plus \
	picoarch-mame2003


# -----------------------------------------------------------------------------
# FCEUmm
# -----------------------------------------------------------------------------

.PHONY: picoarch-fceumm
picoarch-fceumm: picoarch-check-patches picoarch-clean-fceumm
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/fceumm/.git" ]; then \
		git clone "$(FCEUMM_REPO)" "$(PICOARCH_CORE_SOURCES)/fceumm"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/fceumm reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/fceumm clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/fceumm checkout --detach $(FCEUMM_REV)
	git -C $(PICOARCH_CORE_SOURCES)/fceumm reset --hard $(FCEUMM_REV)
	git -C $(PICOARCH_CORE_SOURCES)/fceumm clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/fceumm \
		$(PICOARCH_BUILD)/fceumm

	cd $(PICOARCH_BUILD)/fceumm && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/fceumm/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		fceumm_libretro.so


.PHONY: picoarch-clean-fceumm
picoarch-clean-fceumm:
	rm -rf $(PICOARCH_BUILD)/fceumm
	rm -f $(PICOARCH_BUILD)/fceumm_libretro.so


# -----------------------------------------------------------------------------
# Gambatte
# -----------------------------------------------------------------------------

.PHONY: picoarch-gambatte
picoarch-gambatte: picoarch-check-patches picoarch-clean-gambatte
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/gambatte/.git" ]; then \
		git clone "$(GAMBATTE_REPO)" "$(PICOARCH_CORE_SOURCES)/gambatte"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/gambatte reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/gambatte clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/gambatte checkout --detach $(GAMBATTE_REV)
	git -C $(PICOARCH_CORE_SOURCES)/gambatte reset --hard $(GAMBATTE_REV)
	git -C $(PICOARCH_CORE_SOURCES)/gambatte clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/gambatte \
		$(PICOARCH_BUILD)/gambatte

	cd $(PICOARCH_BUILD)/gambatte && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/gambatte/0001-ghosting-fastest.patch

	cd $(PICOARCH_BUILD)/gambatte && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/gambatte/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		gambatte_libretro.so


.PHONY: picoarch-clean-gambatte
picoarch-clean-gambatte:
	rm -rf $(PICOARCH_BUILD)/gambatte
	rm -f $(PICOARCH_BUILD)/gambatte_libretro.so


# -----------------------------------------------------------------------------
# gpSP
# -----------------------------------------------------------------------------

.PHONY: picoarch-gpsp
picoarch-gpsp: picoarch-check-patches picoarch-clean-gpsp
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/gpsp/.git" ]; then \
		git clone "$(GPSP_REPO)" "$(PICOARCH_CORE_SOURCES)/gpsp"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/gpsp reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/gpsp clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/gpsp checkout --detach $(GPSP_REV)
	git -C $(PICOARCH_CORE_SOURCES)/gpsp reset --hard $(GPSP_REV)
	git -C $(PICOARCH_CORE_SOURCES)/gpsp clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/gpsp \
		$(PICOARCH_BUILD)/gpsp

	cd $(PICOARCH_BUILD)/gpsp && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/gpsp/1000-trimui-build.patch

	cd $(PICOARCH_BUILD)/gpsp && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/gpsp/1002-frameskip-changes.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		gpsp_libretro.so


.PHONY: picoarch-clean-gpsp
picoarch-clean-gpsp:
	rm -rf $(PICOARCH_BUILD)/gpsp
	rm -f $(PICOARCH_BUILD)/gpsp_libretro.so


# -----------------------------------------------------------------------------
# PicoDrive
# -----------------------------------------------------------------------------

.PHONY: picoarch-picodrive
picoarch-picodrive: picoarch-check-patches picoarch-clean-picodrive
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/picodrive/.git" ]; then \
		git clone --recursive "$(PICODRIVE_REPO)" "$(PICOARCH_CORE_SOURCES)/picodrive"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/picodrive reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/picodrive clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/picodrive checkout --detach $(PICODRIVE_REV)
	git -C $(PICOARCH_CORE_SOURCES)/picodrive reset --hard $(PICODRIVE_REV)
	git -C $(PICOARCH_CORE_SOURCES)/picodrive clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/picodrive submodule update --init --recursive

	cp -a \
		$(PICOARCH_CORE_SOURCES)/picodrive \
		$(PICOARCH_BUILD)/picodrive

	cd $(PICOARCH_BUILD)/picodrive && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/picodrive/0001-frameskip-interval.patch

	cd $(PICOARCH_BUILD)/picodrive && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/picodrive/1000-trimui-build.patch

	cd $(PICOARCH_BUILD)/picodrive && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/picodrive/0002-lzma-old-arm-hwcap.patch

	# Cyclone generator must run on the build host, not on ARM.
	$(MAKE) -C $(PICOARCH_BUILD)/picodrive/cpu/cyclone clean

	$(MAKE) -C $(PICOARCH_BUILD)/picodrive/cpu/cyclone \
		CC=gcc \
		CXX=g++ \
		CONFIG_FILE=../cyclone_config.h \
		HAVE_ARMv6=0

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		picodrive_libretro.so


.PHONY: picoarch-clean-picodrive
picoarch-clean-picodrive:
	rm -rf $(PICOARCH_BUILD)/picodrive
	rm -f $(PICOARCH_BUILD)/picodrive_libretro.so


# -----------------------------------------------------------------------------
# MAME 2000
# -----------------------------------------------------------------------------

.PHONY: picoarch-mame2000
picoarch-mame2000: picoarch-check-patches picoarch-clean-mame2000
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/mame2000/.git" ]; then \
		git clone "$(MAME2000_REPO)" "$(PICOARCH_CORE_SOURCES)/mame2000"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/mame2000 reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/mame2000 clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/mame2000 checkout --detach $(MAME2000_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mame2000 reset --hard $(MAME2000_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mame2000 clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/mame2000 \
		$(PICOARCH_BUILD)/mame2000

	cd $(PICOARCH_BUILD)/mame2000 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/mame2000/0002-arm-generic-target.patch

	cd $(PICOARCH_BUILD)/mame2000 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/mame2000/0004-rotation.patch

	cd $(PICOARCH_BUILD)/mame2000 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/mame2000/1000-trimui-build.patch

	cd $(PICOARCH_BUILD)/mame2000 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/mame2000/1002-reduce-vector-game-res.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mame2000_libretro.so


.PHONY: picoarch-clean-mame2000
picoarch-clean-mame2000:
	rm -rf $(PICOARCH_BUILD)/mame2000
	rm -f $(PICOARCH_BUILD)/mame2000_libretro.so

# -----------------------------------------------------------------------------
# MAME 2003
# -----------------------------------------------------------------------------

.PHONY: picoarch-mame2003
picoarch-mame2003: picoarch-check-patches picoarch-clean-mame2003
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/mame2003/.git" ]; then \
		git clone "$(MAME2003_REPO)" "$(PICOARCH_CORE_SOURCES)/mame2003"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/mame2003 reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/mame2003 clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/mame2003 checkout --detach $(MAME2003_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mame2003 reset --hard $(MAME2003_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mame2003 clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/mame2003 \
		$(PICOARCH_BUILD)/mame2003

	cd $(PICOARCH_BUILD)/mame2003 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/mame2003/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD)/mame2003 \
		platform=$(PICOARCH_PLATFORM) \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/mame2003/mame2003_libretro.so \
		$(PICOARCH_BUILD)/mame2003_libretro.so


.PHONY: picoarch-clean-mame2003
picoarch-clean-mame2003:
	rm -rf $(PICOARCH_BUILD)/mame2003
	rm -f $(PICOARCH_BUILD)/mame2003_libretro.so

# -----------------------------------------------------------------------------
# PCSX-ReARMed
# -----------------------------------------------------------------------------

.PHONY: picoarch-pcsx-rearmed
picoarch-pcsx-rearmed: picoarch-check-patches picoarch-clean-pcsx-rearmed
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/pcsx_rearmed/.git" ]; then \
		git clone --recursive "$(PCSX_REARMED_REPO)" "$(PICOARCH_CORE_SOURCES)/pcsx_rearmed"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/pcsx_rearmed reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/pcsx_rearmed clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/pcsx_rearmed checkout --detach $(PCSX_REARMED_REV)
	git -C $(PICOARCH_CORE_SOURCES)/pcsx_rearmed reset --hard $(PCSX_REARMED_REV)
	git -C $(PICOARCH_CORE_SOURCES)/pcsx_rearmed clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/pcsx_rearmed submodule update --init --recursive

	cp -a \
		$(PICOARCH_CORE_SOURCES)/pcsx_rearmed \
		$(PICOARCH_BUILD)/pcsx_rearmed

	cd $(PICOARCH_BUILD)/pcsx_rearmed && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/pcsx_rearmed/1000-trimui-support.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		pcsx_rearmed_libretro.so


.PHONY: picoarch-clean-pcsx-rearmed
picoarch-clean-pcsx-rearmed:
	rm -rf $(PICOARCH_BUILD)/pcsx_rearmed
	rm -f $(PICOARCH_BUILD)/pcsx_rearmed_libretro.so


# -----------------------------------------------------------------------------
# Beetle PCE Fast
# -----------------------------------------------------------------------------

.PHONY: picoarch-beetle-pce-fast
picoarch-beetle-pce-fast: picoarch-check-patches picoarch-clean-beetle-pce-fast
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/beetle-pce-fast/.git" ]; then \
		git clone "$(BEETLE_PCE_FAST_REPO)" "$(PICOARCH_CORE_SOURCES)/beetle-pce-fast"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/beetle-pce-fast reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/beetle-pce-fast clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/beetle-pce-fast checkout --detach $(BEETLE_PCE_FAST_REV)
	git -C $(PICOARCH_CORE_SOURCES)/beetle-pce-fast reset --hard $(BEETLE_PCE_FAST_REV)
	git -C $(PICOARCH_CORE_SOURCES)/beetle-pce-fast clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/beetle-pce-fast \
		$(PICOARCH_BUILD)/beetle-pce-fast

	cd $(PICOARCH_BUILD)/beetle-pce-fast && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/beetle-pce-fast/0001-frameskip-interval.patch

	cd $(PICOARCH_BUILD)/beetle-pce-fast && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/beetle-pce-fast/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		beetle-pce-fast_libretro.so


.PHONY: picoarch-clean-beetle-pce-fast
picoarch-clean-beetle-pce-fast:
	rm -rf $(PICOARCH_BUILD)/beetle-pce-fast
	rm -f $(PICOARCH_BUILD)/beetle-pce-fast_libretro.so

# -----------------------------------------------------------------------------
# blueMSX
# -----------------------------------------------------------------------------

.PHONY: picoarch-bluemsx
picoarch-bluemsx: picoarch-check-patches picoarch-clean-bluemsx
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/bluemsx/.git" ]; then \
		git clone "$(BLUEMSX_REPO)" "$(PICOARCH_CORE_SOURCES)/bluemsx"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/bluemsx reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/bluemsx clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/bluemsx checkout --detach $(BLUEMSX_REV)
	git -C $(PICOARCH_CORE_SOURCES)/bluemsx reset --hard $(BLUEMSX_REV)
	git -C $(PICOARCH_CORE_SOURCES)/bluemsx clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/bluemsx \
		$(PICOARCH_BUILD)/bluemsx

	cd $(PICOARCH_BUILD)/bluemsx && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/bluemsx/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		bluemsx_libretro.so


.PHONY: picoarch-clean-bluemsx
picoarch-clean-bluemsx:
	rm -rf $(PICOARCH_BUILD)/bluemsx
	rm -f $(PICOARCH_BUILD)/bluemsx_libretro.so

# -----------------------------------------------------------------------------
# fMSX
# -----------------------------------------------------------------------------

.PHONY: picoarch-fmsx
picoarch-fmsx: picoarch-check-patches picoarch-clean-fmsx
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/fmsx/.git" ]; then \
		git clone "$(FMSX_REPO)" "$(PICOARCH_CORE_SOURCES)/fmsx"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/fmsx reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/fmsx clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/fmsx checkout --detach $(FMSX_REV)
	git -C $(PICOARCH_CORE_SOURCES)/fmsx reset --hard $(FMSX_REV)
	git -C $(PICOARCH_CORE_SOURCES)/fmsx clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/fmsx \
		$(PICOARCH_BUILD)/fmsx

	cd $(PICOARCH_BUILD)/fmsx && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/fmsx/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		fmsx_libretro.so


.PHONY: picoarch-clean-fmsx
picoarch-clean-fmsx:
	rm -rf $(PICOARCH_BUILD)/fmsx
	rm -f $(PICOARCH_BUILD)/fmsx_libretro.so

# -----------------------------------------------------------------------------
# GME
# -----------------------------------------------------------------------------

.PHONY: picoarch-gme
picoarch-gme: picoarch-check-patches picoarch-clean-gme
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/gme/.git" ]; then \
		git clone "$(GME_REPO)" "$(PICOARCH_CORE_SOURCES)/gme"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/gme reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/gme clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/gme checkout --detach $(GME_REV)
	git -C $(PICOARCH_CORE_SOURCES)/gme reset --hard $(GME_REV)
	git -C $(PICOARCH_CORE_SOURCES)/gme clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/gme \
		$(PICOARCH_BUILD)/gme

	cd $(PICOARCH_BUILD)/gme && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/gme/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		gme_libretro.so


.PHONY: picoarch-clean-gme
picoarch-clean-gme:
	rm -rf $(PICOARCH_BUILD)/gme
	rm -f $(PICOARCH_BUILD)/gme_libretro.so

# -----------------------------------------------------------------------------
# Mednafen NGP
# -----------------------------------------------------------------------------

.PHONY: picoarch-mednafen-ngp
picoarch-mednafen-ngp: picoarch-check-patches picoarch-clean-mednafen-ngp
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/mednafen_ngp/.git" ]; then \
		git clone "$(MEDNAFEN_NGP_REPO)" "$(PICOARCH_CORE_SOURCES)/mednafen_ngp"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/mednafen_ngp reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/mednafen_ngp clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/mednafen_ngp checkout --detach $(MEDNAFEN_NGP_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mednafen_ngp reset --hard $(MEDNAFEN_NGP_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mednafen_ngp clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/mednafen_ngp \
		$(PICOARCH_BUILD)/mednafen_ngp

	cd $(PICOARCH_BUILD)/mednafen_ngp && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/mednafen_ngp/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mednafen_ngp_libretro.so


.PHONY: picoarch-clean-mednafen-ngp
picoarch-clean-mednafen-ngp:
	rm -rf $(PICOARCH_BUILD)/mednafen_ngp
	rm -f $(PICOARCH_BUILD)/mednafen_ngp_libretro.so


# -----------------------------------------------------------------------------
# Mednafen WonderSwan
# -----------------------------------------------------------------------------

.PHONY: picoarch-mednafen-wswan
picoarch-mednafen-wswan: picoarch-check-patches picoarch-clean-mednafen-wswan
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/mednafen_wswan/.git" ]; then \
		git clone "$(MEDNAFEN_WSWAN_REPO)" "$(PICOARCH_CORE_SOURCES)/mednafen_wswan"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/mednafen_wswan reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/mednafen_wswan clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/mednafen_wswan checkout --detach $(MEDNAFEN_WSWAN_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mednafen_wswan reset --hard $(MEDNAFEN_WSWAN_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mednafen_wswan clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/mednafen_wswan \
		$(PICOARCH_BUILD)/mednafen_wswan

	cd $(PICOARCH_BUILD)/mednafen_wswan && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/mednafen_wswan/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mednafen_wswan_libretro.so


.PHONY: picoarch-clean-mednafen-wswan
picoarch-clean-mednafen-wswan:
	rm -rf $(PICOARCH_BUILD)/mednafen_wswan
	rm -f $(PICOARCH_BUILD)/mednafen_wswan_libretro.so

# -----------------------------------------------------------------------------
# PokeMini
# -----------------------------------------------------------------------------

.PHONY: picoarch-pokemini
picoarch-pokemini: picoarch-check-patches picoarch-clean-pokemini
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/pokemini/.git" ]; then \
		git clone "$(POKEMINI_REPO)" "$(PICOARCH_CORE_SOURCES)/pokemini"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/pokemini reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/pokemini clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/pokemini checkout --detach $(POKEMINI_REV)
	git -C $(PICOARCH_CORE_SOURCES)/pokemini reset --hard $(POKEMINI_REV)
	git -C $(PICOARCH_CORE_SOURCES)/pokemini clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/pokemini \
		$(PICOARCH_BUILD)/pokemini

	cd $(PICOARCH_BUILD)/pokemini && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/pokemini/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		pokemini_libretro.so


.PHONY: picoarch-clean-pokemini
picoarch-clean-pokemini:
	rm -rf $(PICOARCH_BUILD)/pokemini
	rm -f $(PICOARCH_BUILD)/pokemini_libretro.so


# -----------------------------------------------------------------------------
# QuickNES
# -----------------------------------------------------------------------------

.PHONY: picoarch-quicknes
picoarch-quicknes: picoarch-check-patches picoarch-clean-quicknes
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/quicknes/.git" ]; then \
		git clone "$(QUICKNES_REPO)" "$(PICOARCH_CORE_SOURCES)/quicknes"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/quicknes reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/quicknes clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/quicknes checkout --detach $(QUICKNES_REV)
	git -C $(PICOARCH_CORE_SOURCES)/quicknes reset --hard $(QUICKNES_REV)
	git -C $(PICOARCH_CORE_SOURCES)/quicknes clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/quicknes \
		$(PICOARCH_BUILD)/quicknes

	cd $(PICOARCH_BUILD)/quicknes && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/quicknes/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		quicknes_libretro.so


.PHONY: picoarch-clean-quicknes
picoarch-clean-quicknes:
	rm -rf $(PICOARCH_BUILD)/quicknes
	rm -f $(PICOARCH_BUILD)/quicknes_libretro.so

# -----------------------------------------------------------------------------
# SMS Plus GX
# -----------------------------------------------------------------------------

.PHONY: picoarch-smsplus-gx
picoarch-smsplus-gx: picoarch-check-patches picoarch-clean-smsplus-gx
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/smsplus-gx/.git" ]; then \
		git clone "$(SMSPLUS_GX_REPO)" "$(PICOARCH_CORE_SOURCES)/smsplus-gx"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/smsplus-gx reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/smsplus-gx clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/smsplus-gx checkout --detach $(SMSPLUS_GX_REV)
	git -C $(PICOARCH_CORE_SOURCES)/smsplus-gx reset --hard $(SMSPLUS_GX_REV)
	git -C $(PICOARCH_CORE_SOURCES)/smsplus-gx clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/smsplus-gx \
		$(PICOARCH_BUILD)/smsplus-gx

	cd $(PICOARCH_BUILD)/smsplus-gx && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/smsplus-gx/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		smsplus-gx_libretro.so


.PHONY: picoarch-clean-smsplus-gx
picoarch-clean-smsplus-gx:
	rm -rf $(PICOARCH_BUILD)/smsplus-gx
	rm -f $(PICOARCH_BUILD)/smsplus-gx_libretro.so

# -----------------------------------------------------------------------------
# Snes9x 2002
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2002
picoarch-snes9x2002: picoarch-check-patches picoarch-clean-snes9x2002
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/snes9x2002/.git" ]; then \
		git clone "$(SNES9X2002_REPO)" "$(PICOARCH_CORE_SOURCES)/snes9x2002"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/snes9x2002 reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2002 clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2002 checkout --detach $(SNES9X2002_REV)
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2002 reset --hard $(SNES9X2002_REV)
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2002 clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/snes9x2002 \
		$(PICOARCH_BUILD)/snes9x2002

	cd $(PICOARCH_BUILD)/snes9x2002 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/snes9x2002/0001-frameskip-interval-max.patch

	cd $(PICOARCH_BUILD)/snes9x2002 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/snes9x2002/1000-trimui-support.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		snes9x2002_libretro.so


.PHONY: picoarch-clean-snes9x2002
picoarch-clean-snes9x2002:
	rm -rf $(PICOARCH_BUILD)/snes9x2002
	rm -f $(PICOARCH_BUILD)/snes9x2002_libretro.so

# -----------------------------------------------------------------------------
# Snes9x 2005
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2005
picoarch-snes9x2005: picoarch-check-patches picoarch-clean-snes9x2005
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/snes9x2005/.git" ]; then \
		git clone "$(SNES9X2005_REPO)" "$(PICOARCH_CORE_SOURCES)/snes9x2005"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005 reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005 clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005 checkout --detach $(SNES9X2005_REV)
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005 reset --hard $(SNES9X2005_REV)
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005 clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/snes9x2005 \
		$(PICOARCH_BUILD)/snes9x2005

	cd $(PICOARCH_BUILD)/snes9x2005 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/snes9x2005/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		snes9x2005_libretro.so


.PHONY: picoarch-clean-snes9x2005
picoarch-clean-snes9x2005:
	rm -rf $(PICOARCH_BUILD)/snes9x2005
	rm -f $(PICOARCH_BUILD)/snes9x2005_libretro.so

# -----------------------------------------------------------------------------
# Stella 2014
# -----------------------------------------------------------------------------

.PHONY: picoarch-stella2014
picoarch-stella2014: picoarch-check-patches picoarch-clean-stella2014
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/stella2014/.git" ]; then \
		git clone "$(STELLA2014_REPO)" "$(PICOARCH_CORE_SOURCES)/stella2014"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/stella2014 reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/stella2014 clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/stella2014 checkout --detach $(STELLA2014_REV)
	git -C $(PICOARCH_CORE_SOURCES)/stella2014 reset --hard $(STELLA2014_REV)
	git -C $(PICOARCH_CORE_SOURCES)/stella2014 clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/stella2014 \
		$(PICOARCH_BUILD)/stella2014

	cd $(PICOARCH_BUILD)/stella2014 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/stella2014/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		stella2014_libretro.so


.PHONY: picoarch-clean-stella2014
picoarch-clean-stella2014:
	rm -rf $(PICOARCH_BUILD)/stella2014
	rm -f $(PICOARCH_BUILD)/stella2014_libretro.so

# -----------------------------------------------------------------------------
# MAME 2003-Plus
# -----------------------------------------------------------------------------

.PHONY: picoarch-mame2003-plus
picoarch-mame2003-plus: picoarch-check-patches picoarch-clean-mame2003-plus
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/mame2003_plus/.git" ]; then \
		git clone "$(MAME2003_PLUS_REPO)" "$(PICOARCH_CORE_SOURCES)/mame2003_plus"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/mame2003_plus reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/mame2003_plus clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/mame2003_plus checkout --detach $(MAME2003_PLUS_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mame2003_plus reset --hard $(MAME2003_PLUS_REV)
	git -C $(PICOARCH_CORE_SOURCES)/mame2003_plus clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/mame2003_plus \
		$(PICOARCH_BUILD)/mame2003_plus

	cd $(PICOARCH_BUILD)/mame2003_plus && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/mame2003_plus/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD)/mame2003_plus \
		platform=$(PICOARCH_PLATFORM) \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CC=$(PICOARCH_CC) \
		CXX=$(PICOARCH_CXX) \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/mame2003_plus/mame2003_plus_libretro.so \
		$(PICOARCH_BUILD)/mame2003_plus_libretro.so


.PHONY: picoarch-clean-mame2003-plus
picoarch-clean-mame2003-plus:
	rm -rf $(PICOARCH_BUILD)/mame2003_plus
	rm -f $(PICOARCH_BUILD)/mame2003_plus_libretro.so

# -----------------------------------------------------------------------------
# Snes9x 2010
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2010
picoarch-snes9x2010: picoarch-check-patches picoarch-clean-snes9x2010
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/snes9x2010/.git" ]; then \
		git clone "$(SNES9X2010_REPO)" "$(PICOARCH_CORE_SOURCES)/snes9x2010"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/snes9x2010 reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2010 clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2010 checkout --detach $(SNES9X2010_REV)
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2010 reset --hard $(SNES9X2010_REV)
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2010 clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/snes9x2010 \
		$(PICOARCH_BUILD)/snes9x2010

	cd $(PICOARCH_BUILD)/snes9x2010 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/snes9x2010/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD)/snes9x2010 \
		-f Makefile.libretro \
		platform=$(PICOARCH_PLATFORM) \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CC=$(PICOARCH_CC) \
		CXX=$(PICOARCH_CXX) \
		LDFLAGS="-lm" \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/snes9x2010/snes9x2010_libretro.so \
		$(PICOARCH_BUILD)/snes9x2010_libretro.so


.PHONY: picoarch-clean-snes9x2010
picoarch-clean-snes9x2010:
	rm -rf $(PICOARCH_BUILD)/snes9x2010
	rm -f $(PICOARCH_BUILD)/snes9x2010_libretro.so

# -----------------------------------------------------------------------------
# Snes9x 2005 Plus
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2005-plus
picoarch-snes9x2005-plus: picoarch-check-patches picoarch-clean-snes9x2005-plus
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/snes9x2005_plus/.git" ]; then \
		git clone "$(SNES9X2005_PLUS_REPO)" "$(PICOARCH_CORE_SOURCES)/snes9x2005_plus"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005_plus reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005_plus clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005_plus checkout --detach $(SNES9X2005_PLUS_REV)
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005_plus reset --hard $(SNES9X2005_PLUS_REV)
	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005_plus clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/snes9x2005_plus \
		$(PICOARCH_BUILD)/snes9x2005_plus

	cd $(PICOARCH_BUILD)/snes9x2005_plus && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/snes9x2005_plus/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD)/snes9x2005_plus \
		platform=$(PICOARCH_PLATFORM) \
		USE_BLARGG_APU=1 \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CC=$(PICOARCH_CC) \
		CXX=$(PICOARCH_CXX) \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/snes9x2005_plus/snes9x2005_plus_libretro.so \
		$(PICOARCH_BUILD)/snes9x2005_plus_libretro.so


.PHONY: picoarch-clean-snes9x2005-plus
picoarch-clean-snes9x2005-plus:
	rm -rf $(PICOARCH_BUILD)/snes9x2005_plus
	rm -f $(PICOARCH_BUILD)/snes9x2005_plus_libretro.so

# -----------------------------------------------------------------------------
# Fake-08
# -----------------------------------------------------------------------------

.PHONY: picoarch-fake08
picoarch-fake08: picoarch-check-patches picoarch-clean-fake08
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/fake-08/.git" ]; then \
		git clone --recursive "$(FAKE08_REPO)" "$(PICOARCH_CORE_SOURCES)/fake-08"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/fake-08 reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/fake-08 clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/fake-08 checkout --detach $(FAKE08_REV)
	git -C $(PICOARCH_CORE_SOURCES)/fake-08 reset --hard $(FAKE08_REV)
	git -C $(PICOARCH_CORE_SOURCES)/fake-08 clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/fake-08 submodule update --init --recursive

	cp -a \
		$(PICOARCH_CORE_SOURCES)/fake-08 \
		$(PICOARCH_BUILD)/fake-08

	cd $(PICOARCH_BUILD)/fake-08 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/fake-08/1000-trimui-build.patch

	cd $(PICOARCH_BUILD)/fake-08 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/fake-08/0002-gcc6-compat.patch

	$(MAKE) -C $(PICOARCH_BUILD)/fake-08/platform/libretro \
		platform=$(PICOARCH_PLATFORM) \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CXX=$(PICOARCH_CXX) \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/fake-08/platform/libretro/fake08_libretro.so \
		$(PICOARCH_BUILD)/fake08_libretro.so


.PHONY: picoarch-clean-fake08
picoarch-clean-fake08:
	rm -rf $(PICOARCH_BUILD)/fake-08
	rm -f $(PICOARCH_BUILD)/fake08_libretro.so

# -----------------------------------------------------------------------------
# PrBoom
# -----------------------------------------------------------------------------

.PHONY: picoarch-prboom
picoarch-prboom: picoarch-check-patches picoarch-clean-prboom
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/prboom/.git" ]; then \
		git clone "$(PRBOOM_REPO)" "$(PICOARCH_CORE_SOURCES)/prboom"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/prboom reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/prboom clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/prboom checkout --detach $(PRBOOM_REV)
	git -C $(PICOARCH_CORE_SOURCES)/prboom reset --hard $(PRBOOM_REV)
	git -C $(PICOARCH_CORE_SOURCES)/prboom clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/prboom \
		$(PICOARCH_BUILD)/prboom

	cd $(PICOARCH_BUILD)/prboom && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_PATCHES)/prboom/1000-trimui-build.patch

	$(MAKE) -C $(PICOARCH_BUILD)/prboom \
		platform=$(PICOARCH_PLATFORM) \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CC=$(PICOARCH_CC) \
		CXX=$(PICOARCH_CXX) \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/prboom/prboom_libretro.so \
		$(PICOARCH_BUILD)/prboom_libretro.so


.PHONY: picoarch-clean-prboom
picoarch-clean-prboom:
	rm -rf $(PICOARCH_BUILD)/prboom
	rm -f $(PICOARCH_BUILD)/prboom_libretro.so

# -----------------------------------------------------------------------------
# FinalBurn Alpha 2012
# -----------------------------------------------------------------------------

.PHONY: picoarch-fbalpha2012
picoarch-fbalpha2012: picoarch-check-patches picoarch-clean-fbalpha2012
	mkdir -p $(PICOARCH_CORE_SOURCES)

	@if [ ! -d "$(PICOARCH_CORE_SOURCES)/fbalpha2012/.git" ]; then \
		git clone "$(FBALPHA2012_REPO)" "$(PICOARCH_CORE_SOURCES)/fbalpha2012"; \
	fi

	git -C $(PICOARCH_CORE_SOURCES)/fbalpha2012 reset --hard
	git -C $(PICOARCH_CORE_SOURCES)/fbalpha2012 clean -fdx
	git -C $(PICOARCH_CORE_SOURCES)/fbalpha2012 checkout --detach $(FBALPHA2012_REV)
	git -C $(PICOARCH_CORE_SOURCES)/fbalpha2012 reset --hard $(FBALPHA2012_REV)
	git -C $(PICOARCH_CORE_SOURCES)/fbalpha2012 clean -fdx

	cp -a \
		$(PICOARCH_CORE_SOURCES)/fbalpha2012 \
		$(PICOARCH_BUILD)/fbalpha2012

	cd $(PICOARCH_BUILD)/fbalpha2012 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/fbalpha2012/0001-update-libretro-h.patch

	cd $(PICOARCH_BUILD)/fbalpha2012 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/fbalpha2012/0002-add-auto-frameskip.patch

	cd $(PICOARCH_BUILD)/fbalpha2012 && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/fbalpha2012/1000-trimui-build.patch


	# All variants share the same patched source but build in separate working
	# directories so target-specific object files can never contaminate each other.
	cp -a \
		$(PICOARCH_BUILD)/fbalpha2012 \
		$(PICOARCH_BUILD)/fbalpha2012-cps1
	cp -a \
		$(PICOARCH_BUILD)/fbalpha2012 \
		$(PICOARCH_BUILD)/fbalpha2012-cps2
	cp -a \
		$(PICOARCH_BUILD)/fbalpha2012 \
		$(PICOARCH_BUILD)/fbalpha2012-neogeo

	# Full FBA 2012 core.
	$(MAKE) -C $(PICOARCH_BUILD)/fbalpha2012/svn-current/trunk \
		-f makefile.libretro \
		platform=$(PICOARCH_PLATFORM) \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CC=$(PICOARCH_CC) \
		CXX=$(PICOARCH_CXX) \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/fbalpha2012/svn-current/trunk/fbalpha2012_libretro.so \
		$(PICOARCH_BUILD)/fbalpha2012_libretro.so

	# CPS1-only core.
	$(MAKE) -C $(PICOARCH_BUILD)/fbalpha2012-cps1/svn-current/trunk \
		-f makefile.libretro \
		platform=$(PICOARCH_PLATFORM) \
		target=cps1 \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CC=$(PICOARCH_CC) \
		CXX=$(PICOARCH_CXX) \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/fbalpha2012-cps1/svn-current/trunk/fbalpha2012_cps1_libretro.so \
		$(PICOARCH_BUILD)/fbalpha2012_cps1_libretro.so

	# CPS2-only core.
	$(MAKE) -C $(PICOARCH_BUILD)/fbalpha2012-cps2/svn-current/trunk \
		-f makefile.libretro \
		platform=$(PICOARCH_PLATFORM) \
		target=cps2 \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CC=$(PICOARCH_CC) \
		CXX=$(PICOARCH_CXX) \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/fbalpha2012-cps2/svn-current/trunk/fbalpha2012_cps2_libretro.so \
		$(PICOARCH_BUILD)/fbalpha2012_cps2_libretro.so

	# Neo Geo-only core.
	$(MAKE) -C $(PICOARCH_BUILD)/fbalpha2012-neogeo/svn-current/trunk \
		-f makefile.libretro \
		platform=$(PICOARCH_PLATFORM) \
		target=neogeo \
		CROSS_COMPILE=$(PICOARCH_CROSS) \
		CC=$(PICOARCH_CC) \
		CXX=$(PICOARCH_CXX) \
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/fbalpha2012-neogeo/svn-current/trunk/fbalpha2012_neogeo_libretro.so \
		$(PICOARCH_BUILD)/fbalpha2012_neogeo_libretro.so


.PHONY: picoarch-clean-fbalpha2012
picoarch-clean-fbalpha2012:
	rm -rf $(PICOARCH_BUILD)/fbalpha2012
	rm -rf $(PICOARCH_BUILD)/fbalpha2012-cps1
	rm -rf $(PICOARCH_BUILD)/fbalpha2012-cps2
	rm -rf $(PICOARCH_BUILD)/fbalpha2012-neogeo
	rm -f $(PICOARCH_BUILD)/fbalpha2012_libretro.so
	rm -f $(PICOARCH_BUILD)/fbalpha2012_cps1_libretro.so
	rm -f $(PICOARCH_BUILD)/fbalpha2012_cps2_libretro.so
	rm -f $(PICOARCH_BUILD)/fbalpha2012_neogeo_libretro.so

# -----------------------------------------------------------------------------
# Clean all validated cores
# -----------------------------------------------------------------------------

.PHONY: picoarch-clean-validated
picoarch-clean-validated: \
	picoarch-clean-fceumm \
	picoarch-clean-gambatte \
	picoarch-clean-gpsp \
	picoarch-clean-picodrive \
	picoarch-clean-mame2000 \
	picoarch-clean-pcsx-rearmed \
	picoarch-clean-beetle-pce-fast \
	picoarch-clean-bluemsx \
	picoarch-clean-fmsx \
	picoarch-clean-gme \
	picoarch-clean-mednafen-ngp \
	picoarch-clean-mednafen-wswan \
	picoarch-clean-pokemini \
	picoarch-clean-quicknes \
	picoarch-clean-smsplus-gx \
	picoarch-clean-snes9x2002 \
	picoarch-clean-snes9x2005 \
	picoarch-clean-stella2014 \
	picoarch-clean-snes9x2010 \
	picoarch-clean-snes9x2005-plus \
	picoarch-clean-prboom \
	picoarch-clean-mame2003-plus \
	picoarch-clean-fbalpha2012 \
	picoarch-clean-mame2003
