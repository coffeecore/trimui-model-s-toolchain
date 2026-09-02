PICOARCH_TOOL_SCRIPT := /workspace/scripts/package-picoarch-tool.sh
PICOARCH_TOOL_OUTPUT := /workspace/output/picoarch-tool

.PHONY: picoarch-tool
picoarch-tool:
	test -x "$(PICOARCH_OUTPUT)/picoarch"
	@test "$$(find "$(PICOARCH_OUTPUT_CORES)" \
		-maxdepth 1 \
		-type f \
		-name '*_libretro.so' \
		| wc -l)" -eq 27 || { \
		echo "ERROR: expected 27 validated PicoArch cores in $(PICOARCH_OUTPUT_CORES)" >&2; \
		exit 1; \
	}
	$(PICOARCH_TOOL_SCRIPT)

.PHONY: clean-picoarch-tool
clean-picoarch-tool:
	rm -rf $(PICOARCH_TOOL_OUTPUT)
