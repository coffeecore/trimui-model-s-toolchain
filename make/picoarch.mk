# -----------------------------------------------------------------------------
# PicoArch - Trimui Model S
# -----------------------------------------------------------------------------
PICOARCH_BUILD := $(WORKSPACE)/build/picoarch

PICOARCH_PLATFORM := trimui
PICOARCH_CROSS := $(CROSS_COMPILE)
PICOARCH_CXX := $(PICOARCH_CROSS)g++

# Exact PicoArch revision validated for Trimui Model S
PICOARCH_REV := 5cabcad277c41ee92424cc50fdc60c22338825a1

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
.PHONY: prepare-picoarch \
	picoarch-frontend picoarch-clean-frontend

prepare-picoarch: source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-prepare \
		PICOARCH_BUILD="$(PICOARCH_BUILD)"

# The frontend and every core now share the same complete PicoArch working tree.
# This is required because the root Makefile owns the *_libretro.so targets.
picoarch-frontend: source-minui minui-libs prepare-picoarch
	$(MAKE) -C "$(MINUI_DIR)" picoarch-frontend \
		PICOARCH_BUILD="$(PICOARCH_BUILD)" \
		SYSROOT="$(TOOLCHAIN_SYSROOT)" \
		CROSS_COMPILE="$(PICOARCH_CROSS)" \
		MINUI_MMENU_BUILD="$(MINUI_MMENU_BUILD)"

	test -x "$(PICOARCH_BUILD)/picoarch"

# Removing the PicoArch working tree also removes all built cores.
picoarch-clean-frontend:
	rm -rf $(PICOARCH_BUILD)

# -----------------------------------------------------------------------------
# PicoArch output
# -----------------------------------------------------------------------------

PICOARCH_OUTPUT := /workspace/output/picoarch
PICOARCH_OUTPUT_CORES := $(PICOARCH_OUTPUT)/cores

.PHONY: picoarch-output picoarch-clean-output

picoarch-output: picoarch-validated picoarch-frontend
	test -x "$(PICOARCH_BUILD)/picoarch"
	@test "$$(find $(PICOARCH_BUILD) -maxdepth 1 -type f -name '*_libretro.so' \
		| wc -l)" -eq 21 || { \
		echo "ERROR: expected 21 validated PicoArch cores in $(PICOARCH_BUILD)" >&2; \
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
		-exec cp {} $(PICOARCH_OUTPUT_CORES)/ \;

picoarch-clean-output:
	rm -rf $(PICOARCH_OUTPUT)

# -----------------------------------------------------------------------------
# Groups
# -----------------------------------------------------------------------------

.PHONY: picoarch-validated
picoarch-validated: prepare-picoarch \
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
	picoarch-mame2003


# -----------------------------------------------------------------------------
# FCEUmm
# -----------------------------------------------------------------------------

.PHONY: picoarch-fceumm
picoarch-fceumm: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		fceumm_libretro.so

.PHONY: picoarch-clean-fceumm
picoarch-clean-fceumm: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-fceumm

# -----------------------------------------------------------------------------
# Gambatte
# -----------------------------------------------------------------------------

.PHONY: picoarch-gambatte
picoarch-gambatte: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		gambatte_libretro.so

.PHONY: picoarch-clean-gambatte
picoarch-clean-gambatte: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-gambatte

# -----------------------------------------------------------------------------
# gpSP
# -----------------------------------------------------------------------------

.PHONY: picoarch-gpsp
picoarch-gpsp: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		gpsp_libretro.so

.PHONY: picoarch-clean-gpsp
picoarch-clean-gpsp: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-gpsp


# -----------------------------------------------------------------------------
# PicoDrive
# -----------------------------------------------------------------------------

.PHONY: picoarch-picodrive
picoarch-picodrive: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		picodrive_libretro.so

.PHONY: picoarch-clean-picodrive
picoarch-clean-picodrive: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-picodrive


# -----------------------------------------------------------------------------
# MAME 2000
# -----------------------------------------------------------------------------

.PHONY: picoarch-mame2000
picoarch-mame2000: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mame2000_libretro.so

.PHONY: picoarch-clean-mame2000
picoarch-clean-mame2000: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-mame2000

# -----------------------------------------------------------------------------
# MAME 2003
# -----------------------------------------------------------------------------

.PHONY: picoarch-mame2003
picoarch-mame2003: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mame2003_libretro.so

.PHONY: picoarch-clean-mame2003
picoarch-clean-mame2003: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-mame2003

# -----------------------------------------------------------------------------
# PCSX-ReARMed
# -----------------------------------------------------------------------------

.PHONY: picoarch-pcsx-rearmed
picoarch-pcsx-rearmed: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		pcsx_rearmed_libretro.so

.PHONY: picoarch-clean-pcsx-rearmed
picoarch-clean-pcsx-rearmed: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-pcsx_rearmed


# -----------------------------------------------------------------------------
# Beetle PCE Fast
# -----------------------------------------------------------------------------

.PHONY: picoarch-beetle-pce-fast
picoarch-beetle-pce-fast: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		beetle-pce-fast_libretro.so

.PHONY: picoarch-clean-beetle-pce-fast
picoarch-clean-beetle-pce-fast: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-beetle-pce-fast

# -----------------------------------------------------------------------------
# blueMSX
# -----------------------------------------------------------------------------

.PHONY: picoarch-bluemsx
picoarch-bluemsx: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		bluemsx_libretro.so

.PHONY: picoarch-clean-bluemsx
picoarch-clean-bluemsx: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-bluemsx

# -----------------------------------------------------------------------------
# fMSX
# -----------------------------------------------------------------------------

.PHONY: picoarch-fmsx
picoarch-fmsx: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		fmsx_libretro.so

.PHONY: picoarch-clean-fmsx
picoarch-clean-fmsx: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-fmsx

# -----------------------------------------------------------------------------
# GME
# -----------------------------------------------------------------------------

.PHONY: picoarch-gme
picoarch-gme: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		gme_libretro.so

.PHONY: picoarch-clean-gme
picoarch-clean-gme: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-gme

# -----------------------------------------------------------------------------
# Mednafen NGP
# -----------------------------------------------------------------------------

.PHONY: picoarch-mednafen-ngp
picoarch-mednafen-ngp: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mednafen_ngp_libretro.so

.PHONY: picoarch-clean-mednafen-ngp
picoarch-clean-mednafen-ngp: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-mednafen_ngp


# -----------------------------------------------------------------------------
# Mednafen WonderSwan
# -----------------------------------------------------------------------------

.PHONY: picoarch-mednafen-wswan
picoarch-mednafen-wswan: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		mednafen_wswan_libretro.so

.PHONY: picoarch-clean-mednafen-wswan
picoarch-clean-mednafen-wswan: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-mednafen_wswan

# -----------------------------------------------------------------------------
# PokeMini
# -----------------------------------------------------------------------------

.PHONY: picoarch-pokemini
picoarch-pokemini: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		pokemini_libretro.so

.PHONY: picoarch-clean-pokemini
picoarch-clean-pokemini: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-pokemini


# -----------------------------------------------------------------------------
# QuickNES
# -----------------------------------------------------------------------------

.PHONY: picoarch-quicknes
picoarch-quicknes: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		quicknes_libretro.so

.PHONY: picoarch-clean-quicknes
picoarch-clean-quicknes: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-quicknes

# -----------------------------------------------------------------------------
# SMS Plus GX
# -----------------------------------------------------------------------------

.PHONY: picoarch-smsplus-gx
picoarch-smsplus-gx: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		smsplus-gx_libretro.so

.PHONY: picoarch-clean-smsplus-gx
picoarch-clean-smsplus-gx: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-smsplus-gx

# -----------------------------------------------------------------------------
# Snes9x 2002
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2002
picoarch-snes9x2002: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		snes9x2002_libretro.so

.PHONY: picoarch-clean-snes9x2002
picoarch-clean-snes9x2002: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-snes9x2002

# -----------------------------------------------------------------------------
# Snes9x 2005
# -----------------------------------------------------------------------------

.PHONY: picoarch-snes9x2005
picoarch-snes9x2005: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		snes9x2005_libretro.so

.PHONY: picoarch-clean-snes9x2005
picoarch-clean-snes9x2005: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-snes9x2005

# -----------------------------------------------------------------------------
# Stella 2014
# -----------------------------------------------------------------------------

.PHONY: picoarch-stella2014
picoarch-stella2014: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		stella2014_libretro.so

.PHONY: picoarch-clean-stella2014
picoarch-clean-stella2014: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-stella2014

# -----------------------------------------------------------------------------
# Handy
# -----------------------------------------------------------------------------

.PHONY: picoarch-handy
picoarch-handy: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		handy_libretro.so

.PHONY: picoarch-clean-handy
picoarch-clean-handy: prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		clean-handy

# -----------------------------------------------------------------------------
# GnGeo
# -----------------------------------------------------------------------------

.PHONY: picoarch-gngeo
picoarch-gngeo: libs prepare-picoarch
	$(MAKE) -C $(PICOARCH_BUILD) \
		$(PICOARCH_MAKE_ARGS) \
		SYSROOT="$(SYSROOT)" \
		gngeo_libretro.so

.PHONY: picoarch-clean-gngeo
picoarch-clean-gngeo: prepare-picoarch
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
	picoarch-clean-mame2003
