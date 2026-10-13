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
PICOARCH_REV := cffcb95b50e59ac56b6f7cdc4f776291c0ffeca2

# -----------------------------------------------------------------------------
# Validated core revisions
# -----------------------------------------------------------------------------

MAME2003_PLUS_REV := e9cebbf19dec88d52469bfa1f4a0add4c82fd9df
SNES9X2010_REV := 421a8d9449031245f1dfdb632b84548a9f19fddd
SNES9X2005_PLUS_REV := deb49d80d1836e3e737480a326e31a54c46c04ae
FAKE08_REV := 814991a2571ad3970e386cef48f3b148aa1c27b9
PRBOOM_REV := c180d47a5f9f1b5f74be18bf74deb5eccf97057e
FBALPHA2012_REV := 0ce31536bef3162fe7e69ff5f555334ec4913cef

# -----------------------------------------------------------------------------
# Core repositories
# -----------------------------------------------------------------------------

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
	else \
		git -C "$(PICOARCH_SOURCE)" fetch --prune origin; \
	fi
	git -C "$(PICOARCH_SOURCE)" checkout --detach "$(PICOARCH_REV)"
	git -C "$(PICOARCH_SOURCE)" submodule update --init --recursive

prepare-picoarch: source-picoarch
	@if [ ! -f "$(PICOARCH_PREPARED_STAMP)" ] || \
		[ "$$(cat "$(PICOARCH_PREPARED_STAMP)" 2>/dev/null)" != "$(PICOARCH_REV)" ]; then \
		rm -rf "$(PICOARCH_BUILD)"; \
		mkdir -p "$(dir $(PICOARCH_BUILD))"; \
		cp -a "$(PICOARCH_SOURCE)" "$(PICOARCH_BUILD)"; \
		cp "$(PICOARCH_PATCHES)/libpicofe/0001-key-combos.patch" \
			"$(PICOARCH_BUILD)/patches/libpicofe/0001-key-combos.patch"; \
		for patch_file in "$(PICOARCH_PATCHES)"/frontend/*.patch; do \
			patch -l -d "$(PICOARCH_BUILD)" -p1 < "$$patch_file"; \
		done; \
		echo "$(PICOARCH_REV)" > "$(PICOARCH_PREPARED_STAMP)"; \
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
		patches/handy/1000-trimui-build.patch \
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

picoarch-output: picoarch-validated picoarch-frontend
	test -x "$(PICOARCH_BUILD)/picoarch"
	@test "$$(find $(PICOARCH_BUILD) -maxdepth 1 -type f -name '*_libretro.so' \
		! -name 'fake08_libretro.so' \
		| wc -l)" -eq 29 || { \
		echo "ERROR: expected 29 validated PicoArch cores in $(PICOARCH_BUILD)" >&2; \
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
	picoarch-gngeo \
	picoarch-gpsp \
	picoarch-handy \
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
picoarch-fceumm: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		fceumm_libretro.so

.PHONY: picoarch-clean-fceumm
picoarch-clean-fceumm: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-fceumm

# -----------------------------------------------------------------------------
# Gambatte
# -----------------------------------------------------------------------------

.PHONY: picoarch-gambatte
picoarch-gambatte: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		gambatte_libretro.so

.PHONY: picoarch-clean-gambatte
picoarch-clean-gambatte: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-gambatte

# -----------------------------------------------------------------------------
# gpSP
# -----------------------------------------------------------------------------

.PHONY: picoarch-gpsp
picoarch-gpsp: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		gpsp_libretro.so

.PHONY: picoarch-clean-gpsp
picoarch-clean-gpsp: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-gpsp


# -----------------------------------------------------------------------------
# PicoDrive
# -----------------------------------------------------------------------------

.PHONY: picoarch-picodrive
picoarch-picodrive: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		picodrive_libretro.so

.PHONY: picoarch-clean-picodrive
picoarch-clean-picodrive: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-picodrive


# -----------------------------------------------------------------------------
# MAME 2000
# -----------------------------------------------------------------------------

.PHONY: picoarch-mame2000
picoarch-mame2000: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mame2000_libretro.so

.PHONY: picoarch-clean-mame2000
picoarch-clean-mame2000: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-mame2000

# -----------------------------------------------------------------------------
# MAME 2003
# -----------------------------------------------------------------------------

.PHONY: picoarch-mame2003
picoarch-mame2003: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mame2003_libretro.so

.PHONY: picoarch-clean-mame2003
picoarch-clean-mame2003: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-mame2003

# -----------------------------------------------------------------------------
# PCSX-ReARMed
# -----------------------------------------------------------------------------

.PHONY: picoarch-pcsx-rearmed
picoarch-pcsx-rearmed: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		pcsx_rearmed_libretro.so

.PHONY: picoarch-clean-pcsx-rearmed
picoarch-clean-pcsx-rearmed: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-pcsx_rearmed


# -----------------------------------------------------------------------------
# Beetle PCE Fast
# -----------------------------------------------------------------------------

.PHONY: picoarch-beetle-pce-fast
picoarch-beetle-pce-fast: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		beetle-pce-fast_libretro.so

.PHONY: picoarch-clean-beetle-pce-fast
picoarch-clean-beetle-pce-fast: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-beetle-pce-fast

# -----------------------------------------------------------------------------
# blueMSX
# -----------------------------------------------------------------------------

.PHONY: picoarch-bluemsx
picoarch-bluemsx: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		bluemsx_libretro.so

.PHONY: picoarch-clean-bluemsx
picoarch-clean-bluemsx: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-bluemsx

# -----------------------------------------------------------------------------
# fMSX
# -----------------------------------------------------------------------------

.PHONY: picoarch-fmsx
picoarch-fmsx: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		fmsx_libretro.so

.PHONY: picoarch-clean-fmsx
picoarch-clean-fmsx: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-fmsx

# -----------------------------------------------------------------------------
# GME
# -----------------------------------------------------------------------------

.PHONY: picoarch-gme
picoarch-gme: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		gme_libretro.so

.PHONY: picoarch-clean-gme
picoarch-clean-gme: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-gme

# -----------------------------------------------------------------------------
# Mednafen NGP
# -----------------------------------------------------------------------------

.PHONY: picoarch-mednafen-ngp
picoarch-mednafen-ngp: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mednafen_ngp_libretro.so

.PHONY: picoarch-clean-mednafen-ngp
picoarch-clean-mednafen-ngp: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-mednafen_ngp


# -----------------------------------------------------------------------------
# Mednafen WonderSwan
# -----------------------------------------------------------------------------

.PHONY: picoarch-mednafen-wswan
picoarch-mednafen-wswan: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mednafen_wswan_libretro.so

.PHONY: picoarch-clean-mednafen-wswan
picoarch-clean-mednafen-wswan: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-mednafen_wswan

# -----------------------------------------------------------------------------
# PokeMini
# -----------------------------------------------------------------------------

.PHONY: picoarch-pokemini
picoarch-pokemini: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		pokemini_libretro.so

.PHONY: picoarch-clean-pokemini
picoarch-clean-pokemini: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-pokemini


# -----------------------------------------------------------------------------
# QuickNES
# -----------------------------------------------------------------------------

.PHONY: picoarch-quicknes
picoarch-quicknes: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		quicknes_libretro.so

.PHONY: picoarch-clean-quicknes
picoarch-clean-quicknes: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-quicknes

# -----------------------------------------------------------------------------
# SMS Plus GX
# -----------------------------------------------------------------------------

.PHONY: picoarch-smsplus-gx
picoarch-smsplus-gx: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		smsplus-gx_libretro.so

.PHONY: picoarch-clean-smsplus-gx
picoarch-clean-smsplus-gx: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-smsplus-gx

# -----------------------------------------------------------------------------
# Snes9x 2002
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2002
picoarch-snes9x2002: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		snes9x2002_libretro.so

.PHONY: picoarch-clean-snes9x2002
picoarch-clean-snes9x2002: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-snes9x2002

# -----------------------------------------------------------------------------
# Snes9x 2005
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2005
picoarch-snes9x2005: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		snes9x2005_libretro.so

.PHONY: picoarch-clean-snes9x2005
picoarch-clean-snes9x2005: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-snes9x2005

# -----------------------------------------------------------------------------
# Stella 2014
# -----------------------------------------------------------------------------

.PHONY: picoarch-stella2014
picoarch-stella2014: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		stella2014_libretro.so

.PHONY: picoarch-clean-stella2014
picoarch-clean-stella2014: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-stella2014

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
# Handy
# -----------------------------------------------------------------------------

.PHONY: picoarch-handy
picoarch-handy: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		handy_libretro.so

.PHONY: picoarch-clean-handy
picoarch-clean-handy: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-handy

# -----------------------------------------------------------------------------
# GnGeo
# -----------------------------------------------------------------------------

.PHONY: picoarch-gngeo
picoarch-gngeo: libs picoarch-check-patches picoarch-clean-gngeo
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		SYSROOT="$(SYSROOT)" \
		gngeo_libretro.so

.PHONY: picoarch-clean-gngeo
picoarch-clean-gngeo: picoarch-check-patches
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-gngeo

# -----------------------------------------------------------------------------
# Clean all validated cores
# -----------------------------------------------------------------------------

.PHONY: picoarch-clean-validated
picoarch-clean-validated: \
	picoarch-clean-fceumm \
	picoarch-clean-gambatte \
	picoarch-clean-gngeo \
	picoarch-clean-gpsp \
	picoarch-clean-handy \
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
