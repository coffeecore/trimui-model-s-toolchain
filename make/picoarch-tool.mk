PICOARCH_TOOL_SCRIPT := /workspace/scripts/package-picoarch-tool.sh
PICOARCH_TOOL_OUTPUT := /workspace/output/picoarch-tool

.PHONY: picoarch-tool
picoarch-tool: picoarch-output
	$(PICOARCH_TOOL_SCRIPT)

.PHONY: clean-picoarch-tool
clean-picoarch-tool:
	rm -rf $(PICOARCH_TOOL_OUTPUT)
