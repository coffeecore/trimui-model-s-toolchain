PICOARCH_PAKS_OUTPUT := /workspace/output/picoarch-paks

.PHONY: picoarch-paks
picoarch-paks: source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-paks \
		PICOARCH_BUILD="/workspace/build/picoarch" \
		PICOARCH_OUTPUT="/workspace/output/picoarch" \
		PICOARCH_PAKS_OUTPUT="$(PICOARCH_PAKS_OUTPUT)"

.PHONY: clean-picoarch-paks
clean-picoarch-paks:
	rm -rf $(PICOARCH_PAKS_OUTPUT)
