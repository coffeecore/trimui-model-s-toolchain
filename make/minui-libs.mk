MINUI_SOURCE := $(MINUI_DIR)

MINUI_LIBS_BUILD := $(WORKSPACE)/build/minui-libs
MINUI_MSETTINGS_BUILD := $(MINUI_LIBS_BUILD)/libmsettings
MINUI_MMENU_BUILD := $(MINUI_LIBS_BUILD)/libmmenu

.PHONY: minui-libs
minui-libs: source-minui libs
	rm -rf $(MINUI_LIBS_BUILD)
	mkdir -p $(MINUI_LIBS_BUILD)

	cp -a \
		$(MINUI_SOURCE)/src/libmsettings \
		$(MINUI_MSETTINGS_BUILD)

	cp -a \
		$(MINUI_SOURCE)/src/libmmenu \
		$(MINUI_MMENU_BUILD)

	$(MAKE) -C $(MINUI_MSETTINGS_BUILD) \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(BUILD_SYSROOT)" \
		PREFIX="$(BUILD_SYSROOT)/usr"

	sed -i \
		's|$$(CC) -shared -o "lib$$(TARGET).so" "$$(TARGET).o"|$$(CC) -shared -s -o "lib$$(TARGET).so" "$$(TARGET).o" -lSDL -lSDL_image -lSDL_ttf -ldl -lmsettings|' \
		$(MINUI_MMENU_BUILD)/makefile

	$(MAKE) -C $(MINUI_MMENU_BUILD) \
		CROSS_COMPILE="$(CROSS_COMPILE)" \
		CC="$(CROSS_COMPILE)gcc --sysroot=$(BUILD_SYSROOT)" \
		PREFIX="$(BUILD_SYSROOT)/usr"
