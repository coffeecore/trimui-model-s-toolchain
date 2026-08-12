# -----------------------------------------------------------------------------
# Stella / Atari 2600
#
# Stella 3.9.3 has an old configure script whose ARM/Linux cross-compilation
# path is disabled. Generate config.mak externally instead of patching the
# upstream project.
# -----------------------------------------------------------------------------

STELLA_REPO := https://github.com/coffeecore/Stella-3.9.3.git
STELLA_COMMIT := d2eab06c5fdf1e302a8b7a7e21f036216315d0f7

STELLA_DIR := /workspace/sources/stella
STELLA_OUTPUT_DIR := $(OUTPUT_DIR)/stella

STELLA_CXX := /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-g++
STELLA_AR := /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-ar
STELLA_RANLIB := /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-ranlib
STELLA_STRIP := /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-strip

STELLA_PAK := $(STELLA_OUTPUT_DIR)/Atari2600.pak

.PHONY: \
	stella \
	source-stella \
	configure-stella \
	build-stella \
	clean-build-stella \
	clean-source-stella \
	install-stella \
	clean-install-stella

stella:
	$(MAKE) clean-install-stella
	$(MAKE) clean-build-stella
	$(MAKE) build-stella
	$(MAKE) install-stella

source-stella:
	@if [ ! -d "$(STELLA_DIR)/.git" ]; then \
		mkdir -p "$(dir $(STELLA_DIR))"; \
		git clone "$(STELLA_REPO)" "$(STELLA_DIR)"; \
	fi
	cd "$(STELLA_DIR)" && git checkout --detach "$(STELLA_COMMIT)"

configure-stella: source-stella
	@{ \
		echo '# Generated externally for Trimui Model S.'; \
		echo '# Upstream configure cannot cross-compile its disabled linupy target.'; \
		echo ''; \
		echo 'CXX := $(STELLA_CXX)'; \
		echo 'CXXFLAGS := -O2'; \
		echo 'LD := $(STELLA_CXX)'; \
		echo 'LIBS += -L$(SYSROOT)/usr/lib -lSDL -lpng -lz -lm -lpthread -ldl'; \
		echo 'RANLIB := $(STELLA_RANLIB)'; \
		echo 'INSTALL := install'; \
		echo 'AR := $(STELLA_AR) cru'; \
		echo 'MKDIR := mkdir -p'; \
		echo 'ECHO := printf'; \
		echo 'CAT := cat'; \
		echo 'RM := rm -f'; \
		echo 'RM_REC := rm -f -r'; \
		echo 'ZIP := zip -q'; \
		echo 'CP := cp'; \
		echo 'WIN32PATH :='; \
		echo 'STRIP := $(STELLA_STRIP)'; \
		echo 'WINDRES := windres'; \
		echo ''; \
		echo 'MODULES += src/unix src/debugger src/debugger/gui src/yacc src/cheat'; \
		echo 'EXEEXT :='; \
		echo ''; \
		echo 'PREFIX := /usr'; \
		echo 'BINDIR := /usr/bin'; \
		echo 'DOCDIR := /usr/share/doc/stella'; \
		echo 'DATADIR := /usr/share'; \
		echo 'PROFILE :='; \
		echo ''; \
		echo 'HAVE_GCC = 1'; \
		echo 'HAVE_GCC3 = 1'; \
		echo 'CXX_UPDATE_DEP_FLAG = -MMD -MF "$$(*D)/$$(DEPDIR)/$$(*F).d" -MQ "$$@" -MP'; \
		echo ''; \
		echo 'INCLUDES += -Isrc/emucore -Isrc/common -Isrc/common/tv_filters -Isrc/gui -Isrc/unix -Isrc/debugger -Isrc/debugger/gui -Isrc/yacc -Isrc/cheat -I$(SYSROOT)/usr/include/SDL -D_GNU_SOURCE=1 -D_REENTRANT'; \
		echo 'DEFINES += -DUNIX -DBSPF_UNIX -DHAVE_GETTIMEOFDAY -DHAVE_INTTYPES -DWINDOWED_SUPPORT -DSOUND_SUPPORT -DDEBUGGER_SUPPORT -DSNAPSHOT_SUPPORT -DJOYSTICK_SUPPORT -DCHEATCODE_SUPPORT -DTHUMB_SUPPORT'; \
		echo 'LDFLAGS += -L$(SYSROOT)/usr/lib'; \
	} > "$(STELLA_DIR)/config.mak"

build-stella: configure-stella
	cd "$(STELLA_DIR)" && $(MAKE) -j$(JOBS)
	test -x "$(STELLA_DIR)/stella"

clean-build-stella:
	@if [ -f "$(STELLA_DIR)/config.mak" ]; then \
		cd "$(STELLA_DIR)" && $(MAKE) clean; \
	fi
	rm -f "$(STELLA_DIR)/config.mak"
	rm -f "$(STELLA_DIR)/stella"

clean-source-stella:
	rm -rf "$(STELLA_DIR)"

install-stella:
	test -x "$(STELLA_DIR)/stella"
	rm -rf "$(STELLA_OUTPUT_DIR)"
	mkdir -p "$(STELLA_PAK)"
	cp "$(STELLA_DIR)/stella" "$(STELLA_PAK)/stella"
	@{ \
		echo '#!/bin/sh'; \
		echo '# Atari2600.pak/launch.sh'; \
		echo ''; \
		echo 'EMU_EXE=stella'; \
		echo 'EMU_DIR=$$(dirname "$$0")'; \
		echo 'ROM_DIR=$${EMU_DIR/.pak/}'; \
		echo 'ROM_DIR=$${ROM_DIR/Emus/Roms}'; \
		echo 'EMU_NAME=$${ROM_DIR/\/mnt\/SDCARD\/Roms\//}'; \
		echo 'ROM=$${1}'; \
		echo ''; \
		echo 'HOME="$$ROM_DIR"'; \
		echo 'cd "$$EMU_DIR"'; \
		echo '"$$EMU_DIR/$$EMU_EXE" "$$ROM" &> "/mnt/SDCARD/.minui/logs/$$EMU_NAME.txt"'; \
	} > "$(STELLA_PAK)/launch.sh"
	chmod +x "$(STELLA_PAK)/launch.sh"

clean-install-stella:
	rm -rf "$(STELLA_OUTPUT_DIR)"
