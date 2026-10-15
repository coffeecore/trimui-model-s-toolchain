PICOARCH_TOOL_OUTPUT := /workspace/output/picoarch-tool

.PHONY: picoarch-tool
picoarch-tool: source-minui
	$(MAKE) -C "$(MINUI_DIR)" picoarch-tool \
		PICOARCH_BUILD="/workspace/build/picoarch" \
		PICOARCH_OUTPUT="/workspace/output/picoarch" \
		PICOARCH_TOOL_OUTPUT="$(PICOARCH_TOOL_OUTPUT)"

.PHONY: clean-picoarch-tool
clean-picoarch-tool:
	rm -rf $(PICOARCH_TOOL_OUTPUT)
