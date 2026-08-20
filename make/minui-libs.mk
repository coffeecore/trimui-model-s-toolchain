MINUI_SOURCE := /workspace/sources/minui

MINUI_LIBS_BUILD := /workspace/build/minui-libs
MINUI_MSETTINGS_BUILD := $(MINUI_LIBS_BUILD)/libmsettings
MINUI_MMENU_BUILD := $(MINUI_LIBS_BUILD)/libmmenu

.PHONY: minui-libs
minui-libs:
	rm -rf $(MINUI_LIBS_BUILD)
	mkdir -p $(MINUI_LIBS_BUILD)

	cp -a \
		$(MINUI_SOURCE)/src/libmsettings \
		$(MINUI_MSETTINGS_BUILD)

	cp -a \
		$(MINUI_SOURCE)/src/libmmenu \
		$(MINUI_MMENU_BUILD)

	$(MAKE) -C $(MINUI_MSETTINGS_BUILD)

	sed -i \
		's|$$(CC) -shared -o "lib$$(TARGET).so" "$$(TARGET).o"|$$(CC) -shared -s -o "lib$$(TARGET).so" "$$(TARGET).o" -lSDL -lSDL_image -lSDL_ttf -ldl -lmsettings|' \
		$(MINUI_MMENU_BUILD)/makefile

	$(MAKE) -C $(MINUI_MMENU_BUILD)
