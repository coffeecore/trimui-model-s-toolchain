MINUI_RELEASE_OUTPUT := /workspace/output/minui-release
MINUI_RELEASE_SCRIPT := /workspace/scripts/package-minui-release.sh

.PHONY: minui-release
minui-release: minui-extra-paks standalone-paks picoarch-paks
	$(MINUI_RELEASE_SCRIPT)

.PHONY: clean-minui-release
clean-minui-release:
	rm -rf $(MINUI_RELEASE_OUTPUT)
	rm -rf /workspace/build/minui-release
