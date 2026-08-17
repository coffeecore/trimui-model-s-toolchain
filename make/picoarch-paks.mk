PICOARCH_PAKS_OUTPUT := /workspace/output/picoarch-paks
PICOARCH_PAKS_SCRIPT := /workspace/scripts/package-picoarch-paks.sh

.PHONY: picoarch-paks
picoarch-paks:
	$(PICOARCH_PAKS_SCRIPT)

.PHONY: clean-picoarch-paks
clean-picoarch-paks:
	rm -rf $(PICOARCH_PAKS_OUTPUT)
