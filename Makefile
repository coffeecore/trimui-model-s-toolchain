CROSSTOOL_NG_VERSION := 1.27.0
CROSSTOOL_NG_DIR := /workspace/toolchain/crosstool-ng
TOOLCHAIN_CONFIG := /workspace/trimui-toolchain.config

TARGET := arm-unknown-linux-gnueabi

TOOLCHAIN_PREFIX := /workspace/toolchain/$(TARGET)
TOOLCHAIN_BIN := $(TOOLCHAIN_PREFIX)/bin
TOOLCHAIN_SYSROOT := $(TOOLCHAIN_PREFIX)/$(TARGET)/sysroot

INSTALL_BIN := /workspace/toolchain/bin
SYSROOT := /workspace/sysroot

.PHONY: \
	shell \
	build-toolchain \
	clean-build-toolchain \
	install-toolchain \
	clean-install-toolchain

shell:
	docker compose run --rm builder

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
	rsync -a --delete $(TOOLCHAIN_SYSROOT)/ $(SYSROOT)/
	chmod -R u+w $(SYSROOT)

clean-install-toolchain:
	rm -rf $(INSTALL_BIN)
	chmod -R u+w $(SYSROOT) 2>/dev/null || true
	rm -rf $(SYSROOT)
	mkdir -p $(SYSROOT)
