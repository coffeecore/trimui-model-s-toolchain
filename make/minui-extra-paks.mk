MINUI_EXTRA_PAKS_OUTPUT := /workspace/output/minui-extra-paks
MINUI_EXTRA_PAKS_SCRIPT := /workspace/scripts/package-minui-extra-paks.sh

.PHONY: minui-extra-paks
minui-extra-paks:
	$(MINUI_EXTRA_PAKS_SCRIPT)

.PHONY: clean-minui-extra-paks
clean-minui-extra-paks:
	rm -rf $(MINUI_EXTRA_PAKS_OUTPUT)
