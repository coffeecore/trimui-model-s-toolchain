# ==============================================================================
# crosstool-NG toolchain
# ==============================================================================

CROSSTOOL_NG_VERSION := 1.27.0
CROSSTOOL_NG_DIR := $(TOOLCHAIN_ROOT)/crosstool-ng
TOOLCHAIN_CONFIG := $(WORKSPACE)/trimui-toolchain.config

.PHONY: \
	build-toolchain clean-build-toolchain \
	install-toolchain clean-install-toolchain

# Build crosstool-NG locally, load our pinned configuration and generate the
# ARM926EJ-S / soft-float toolchain.
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
	$(MAKE) -C $(CROSSTOOL_NG_DIR) -j$(JOBS)
	cp $(TOOLCHAIN_CONFIG) $(CROSSTOOL_NG_DIR)/.config
	cd $(CROSSTOOL_NG_DIR) && ./ct-ng olddefconfig
	cd $(CROSSTOOL_NG_DIR) && ./ct-ng build.$(JOBS)

# crosstool-NG builds in its source tree, so a truly clean rebuild removes both
# that tree and the generated target toolchain.
clean-build-toolchain:
	rm -rf $(CROSSTOOL_NG_DIR)
	rm -rf $(TOOLCHAIN_PREFIX)

# Install stable compiler aliases and copy the base crosstool-NG sysroot into
# the project sysroot. `rsync` intentionally has no --delete: reinstalling the
# toolchain must not erase libraries that were added later by `make libs`.
#
# MinUI Legacy expects /opt/trimui-toolchain and the old
# arm-buildroot-linux-gnueabi prefix. The wrappers below redirect those calls to
# our crosstool-NG compiler while forcing the final /workspace/sysroot.
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

	# GCC wrapper: compilation is passed through unchanged. During links we add
	# dependencies required by the old static SDL/FreeType based projects.
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

	# G++ wrapper: some legacy Makefiles place static libraries before object
	# files. Repeating the SDL dependency group at the end makes those links
	# deterministic without editing upstream projects.
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

	# keymon uses old GNU89 inline semantics and hard-codes arm-linux-gcc.
	# Remove any previous symlink before writing the wrapper so redirection never
	# follows a symlink and overwrites the main GCC wrapper.
	rm -f $(COMPAT_BIN)/arm-linux-gcc
	printf '%s\n' \
		'#!/bin/sh' \
		'exec $(COMPAT_BIN)/$(COMPAT_TARGET)-gcc -fgnu89-inline "$$@"' \
		> $(COMPAT_BIN)/arm-linux-gcc
	chmod +x $(COMPAT_BIN)/arm-linux-gcc

	ln -sfn $(COMPAT_BIN)/$(COMPAT_TARGET)-strip \
		$(COMPAT_BIN)/arm-linux-strip

# Remove only the installed/compatibility view. The generated crosstool-NG
# toolchain itself is removed by clean-build-toolchain.
clean-install-toolchain:
	rm -rf $(INSTALL_BIN)
	chmod -R u+w $(SYSROOT) 2>/dev/null || true
	rm -rf $(SYSROOT)
	rm -rf $(COMPAT_TOOLCHAIN)/bin
	rm -rf $(COMPAT_TOOLCHAIN)/$(COMPAT_TARGET)
	mkdir -p $(SYSROOT)
