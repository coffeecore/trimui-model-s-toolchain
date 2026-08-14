# -----------------------------------------------------------------------------
# PicoArch - Trimui Model S
# -----------------------------------------------------------------------------

PICOARCH_SOURCE := /workspace/sources/picoarch
PICOARCH_BUILD := /workspace/build/picoarch
PICOARCH_CORE_SOURCES := /workspace/build/picoarch-sources
PICOARCH_PATCHES := /workspace/patches/picoarch

PICOARCH_PLATFORM := trimui
PICOARCH_CROSS := /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-
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

# -----------------------------------------------------------------------------
# Core repositories
# -----------------------------------------------------------------------------

FCEUMM_REPO := https://github.com/libretro/libretro-fceumm.git
GAMBATTE_REPO := https://github.com/libretro/gambatte-libretro.git
GPSP_REPO := https://github.com/libretro/gpsp.git
PICODRIVE_REPO := https://github.com/libretro/picodrive.git
MAME2000_REPO := https://github.com/libretro/mame2000-libretro.git
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
# Groups
# -----------------------------------------------------------------------------

.PHONY: picoarch-validated
picoarch-validated: \
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
	picoarch-mame2003-plus \
	picoarch-snes9x2010


# -----------------------------------------------------------------------------
# FCEUmm
# -----------------------------------------------------------------------------

.PHONY: picoarch-fceumm
picoarch-fceumm: picoarch-clean-fceumm
	mkdir -p $(PICOARCH_CORE_SOURCES)
	git clone $(FCEUMM_REPO) $(PICOARCH_CORE_SOURCES)/fceumm
	git -C $(PICOARCH_CORE_SOURCES)/fceumm checkout $(FCEUMM_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/fceumm
	rm -f $(PICOARCH_BUILD)/fceumm_libretro.so


# -----------------------------------------------------------------------------
# Gambatte
# -----------------------------------------------------------------------------

.PHONY: picoarch-gambatte
picoarch-gambatte: picoarch-clean-gambatte
	mkdir -p $(PICOARCH_CORE_SOURCES)
	git clone $(GAMBATTE_REPO) $(PICOARCH_CORE_SOURCES)/gambatte
	git -C $(PICOARCH_CORE_SOURCES)/gambatte checkout $(GAMBATTE_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/gambatte
	rm -f $(PICOARCH_BUILD)/gambatte_libretro.so


# -----------------------------------------------------------------------------
# gpSP
# -----------------------------------------------------------------------------

.PHONY: picoarch-gpsp
picoarch-gpsp: picoarch-clean-gpsp
	mkdir -p $(PICOARCH_CORE_SOURCES)
	git clone $(GPSP_REPO) $(PICOARCH_CORE_SOURCES)/gpsp
	git -C $(PICOARCH_CORE_SOURCES)/gpsp checkout $(GPSP_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/gpsp
	rm -f $(PICOARCH_BUILD)/gpsp_libretro.so


# -----------------------------------------------------------------------------
# PicoDrive
# -----------------------------------------------------------------------------

.PHONY: picoarch-picodrive
picoarch-picodrive: picoarch-clean-picodrive
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone --recursive \
		$(PICODRIVE_REPO) \
		$(PICOARCH_CORE_SOURCES)/picodrive

	git -C $(PICOARCH_CORE_SOURCES)/picodrive checkout $(PICODRIVE_REV)

	git -C $(PICOARCH_CORE_SOURCES)/picodrive \
		submodule update --init --recursive

	cp -a \
		$(PICOARCH_CORE_SOURCES)/picodrive \
		$(PICOARCH_BUILD)/picodrive

	cd $(PICOARCH_BUILD)/picodrive && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/picodrive/0001-frameskip-interval.patch

	cd $(PICOARCH_BUILD)/picodrive && \
		patch --no-backup-if-mismatch -p1 \
		< $(PICOARCH_SOURCE)/patches/picodrive/1000-trimui-build.patch

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
	rm -rf $(PICOARCH_CORE_SOURCES)/picodrive
	rm -f $(PICOARCH_BUILD)/picodrive_libretro.so


# -----------------------------------------------------------------------------
# MAME 2000
# -----------------------------------------------------------------------------

.PHONY: picoarch-mame2000
picoarch-mame2000: picoarch-clean-mame2000
	mkdir -p $(PICOARCH_CORE_SOURCES)
	git clone $(MAME2000_REPO) $(PICOARCH_CORE_SOURCES)/mame2000
	git -C $(PICOARCH_CORE_SOURCES)/mame2000 checkout $(MAME2000_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/mame2000
	rm -f $(PICOARCH_BUILD)/mame2000_libretro.so


# -----------------------------------------------------------------------------
# PCSX-ReARMed
# -----------------------------------------------------------------------------

.PHONY: picoarch-pcsx-rearmed
picoarch-pcsx-rearmed: picoarch-clean-pcsx-rearmed
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone --recursive \
		$(PCSX_REARMED_REPO) \
		$(PICOARCH_CORE_SOURCES)/pcsx_rearmed

	git -C $(PICOARCH_CORE_SOURCES)/pcsx_rearmed checkout $(PCSX_REARMED_REV)

	git -C $(PICOARCH_CORE_SOURCES)/pcsx_rearmed \
		submodule update --init --recursive

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
	rm -rf $(PICOARCH_CORE_SOURCES)/pcsx_rearmed
	rm -f $(PICOARCH_BUILD)/pcsx_rearmed_libretro.so


# -----------------------------------------------------------------------------
# Beetle PCE Fast
# -----------------------------------------------------------------------------

.PHONY: picoarch-beetle-pce-fast
picoarch-beetle-pce-fast: picoarch-clean-beetle-pce-fast
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(BEETLE_PCE_FAST_REPO) \
		$(PICOARCH_CORE_SOURCES)/beetle-pce-fast

	git -C $(PICOARCH_CORE_SOURCES)/beetle-pce-fast \
		checkout $(BEETLE_PCE_FAST_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/beetle-pce-fast
	rm -f $(PICOARCH_BUILD)/beetle-pce-fast_libretro.so

# -----------------------------------------------------------------------------
# blueMSX
# -----------------------------------------------------------------------------

.PHONY: picoarch-bluemsx
picoarch-bluemsx: picoarch-clean-bluemsx
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(BLUEMSX_REPO) \
		$(PICOARCH_CORE_SOURCES)/bluemsx

	git -C $(PICOARCH_CORE_SOURCES)/bluemsx \
		checkout $(BLUEMSX_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/bluemsx
	rm -f $(PICOARCH_BUILD)/bluemsx_libretro.so

# -----------------------------------------------------------------------------
# fMSX
# -----------------------------------------------------------------------------

.PHONY: picoarch-fmsx
picoarch-fmsx: picoarch-clean-fmsx
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(FMSX_REPO) \
		$(PICOARCH_CORE_SOURCES)/fmsx

	git -C $(PICOARCH_CORE_SOURCES)/fmsx \
		checkout $(FMSX_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/fmsx
	rm -f $(PICOARCH_BUILD)/fmsx_libretro.so

# -----------------------------------------------------------------------------
# GME
# -----------------------------------------------------------------------------

.PHONY: picoarch-gme
picoarch-gme: picoarch-clean-gme
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(GME_REPO) \
		$(PICOARCH_CORE_SOURCES)/gme

	git -C $(PICOARCH_CORE_SOURCES)/gme \
		checkout $(GME_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/gme
	rm -f $(PICOARCH_BUILD)/gme_libretro.so

# -----------------------------------------------------------------------------
# Mednafen NGP
# -----------------------------------------------------------------------------

.PHONY: picoarch-mednafen-ngp
picoarch-mednafen-ngp: picoarch-clean-mednafen-ngp
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(MEDNAFEN_NGP_REPO) \
		$(PICOARCH_CORE_SOURCES)/mednafen_ngp

	git -C $(PICOARCH_CORE_SOURCES)/mednafen_ngp \
		checkout $(MEDNAFEN_NGP_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/mednafen_ngp
	rm -f $(PICOARCH_BUILD)/mednafen_ngp_libretro.so


# -----------------------------------------------------------------------------
# Mednafen WonderSwan
# -----------------------------------------------------------------------------

.PHONY: picoarch-mednafen-wswan
picoarch-mednafen-wswan: picoarch-clean-mednafen-wswan
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(MEDNAFEN_WSWAN_REPO) \
		$(PICOARCH_CORE_SOURCES)/mednafen_wswan

	git -C $(PICOARCH_CORE_SOURCES)/mednafen_wswan \
		checkout $(MEDNAFEN_WSWAN_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/mednafen_wswan
	rm -f $(PICOARCH_BUILD)/mednafen_wswan_libretro.so

# -----------------------------------------------------------------------------
# PokeMini
# -----------------------------------------------------------------------------

.PHONY: picoarch-pokemini
picoarch-pokemini: picoarch-clean-pokemini
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(POKEMINI_REPO) \
		$(PICOARCH_CORE_SOURCES)/pokemini

	git -C $(PICOARCH_CORE_SOURCES)/pokemini \
		checkout $(POKEMINI_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/pokemini
	rm -f $(PICOARCH_BUILD)/pokemini_libretro.so


# -----------------------------------------------------------------------------
# QuickNES
# -----------------------------------------------------------------------------

.PHONY: picoarch-quicknes
picoarch-quicknes: picoarch-clean-quicknes
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(QUICKNES_REPO) \
		$(PICOARCH_CORE_SOURCES)/quicknes

	git -C $(PICOARCH_CORE_SOURCES)/quicknes \
		checkout $(QUICKNES_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/quicknes
	rm -f $(PICOARCH_BUILD)/quicknes_libretro.so

# -----------------------------------------------------------------------------
# SMS Plus GX
# -----------------------------------------------------------------------------

.PHONY: picoarch-smsplus-gx
picoarch-smsplus-gx: picoarch-clean-smsplus-gx
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(SMSPLUS_GX_REPO) \
		$(PICOARCH_CORE_SOURCES)/smsplus-gx

	git -C $(PICOARCH_CORE_SOURCES)/smsplus-gx \
		checkout $(SMSPLUS_GX_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/smsplus-gx
	rm -f $(PICOARCH_BUILD)/smsplus-gx_libretro.so

# -----------------------------------------------------------------------------
# Snes9x 2002
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2002
picoarch-snes9x2002: picoarch-clean-snes9x2002
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(SNES9X2002_REPO) \
		$(PICOARCH_CORE_SOURCES)/snes9x2002

	git -C $(PICOARCH_CORE_SOURCES)/snes9x2002 \
		checkout $(SNES9X2002_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/snes9x2002
	rm -f $(PICOARCH_BUILD)/snes9x2002_libretro.so

# -----------------------------------------------------------------------------
# Snes9x 2005
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2005
picoarch-snes9x2005: picoarch-clean-snes9x2005
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(SNES9X2005_REPO) \
		$(PICOARCH_CORE_SOURCES)/snes9x2005

	git -C $(PICOARCH_CORE_SOURCES)/snes9x2005 \
		checkout $(SNES9X2005_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/snes9x2005
	rm -f $(PICOARCH_BUILD)/snes9x2005_libretro.so

# -----------------------------------------------------------------------------
# Stella 2014
# -----------------------------------------------------------------------------

.PHONY: picoarch-stella2014
picoarch-stella2014: picoarch-clean-stella2014
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(STELLA2014_REPO) \
		$(PICOARCH_CORE_SOURCES)/stella2014

	git -C $(PICOARCH_CORE_SOURCES)/stella2014 \
		checkout $(STELLA2014_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/stella2014
	rm -f $(PICOARCH_BUILD)/stella2014_libretro.so

# -----------------------------------------------------------------------------
# MAME 2003-Plus
# -----------------------------------------------------------------------------

.PHONY: picoarch-mame2003-plus
picoarch-mame2003-plus: picoarch-clean-mame2003-plus
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(MAME2003_PLUS_REPO) \
		$(PICOARCH_CORE_SOURCES)/mame2003_plus

	git -C $(PICOARCH_CORE_SOURCES)/mame2003_plus \
		checkout $(MAME2003_PLUS_REV)

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
	rm -rf $(PICOARCH_CORE_SOURCES)/mame2003_plus
	rm -f $(PICOARCH_BUILD)/mame2003_plus_libretro.so

# -----------------------------------------------------------------------------
# Snes9x 2010
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2010
picoarch-snes9x2010: picoarch-clean-snes9x2010
	mkdir -p $(PICOARCH_CORE_SOURCES)

	git clone \
		$(SNES9X2010_REPO) \
		$(PICOARCH_CORE_SOURCES)/snes9x2010

	git -C $(PICOARCH_CORE_SOURCES)/snes9x2010 \
		checkout $(SNES9X2010_REV)

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
		-j$(JOBS)

	cp \
		$(PICOARCH_BUILD)/snes9x2010/snes9x2010_libretro.so \
		$(PICOARCH_BUILD)/snes9x2010_libretro.so


.PHONY: picoarch-clean-snes9x2010
picoarch-clean-snes9x2010:
	rm -rf $(PICOARCH_BUILD)/snes9x2010
	rm -rf $(PICOARCH_CORE_SOURCES)/snes9x2010
	rm -f $(PICOARCH_BUILD)/snes9x2010_libretro.so

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
	picoarch-clean-mame2003-plus \
	picoarch-clean-snes9x2010
