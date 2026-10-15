MINUI_RELEASE_SCRIPT := /workspace/scripts/package-minui-release.sh

MINUI_ONLY_OUTPUT := /workspace/output/minui-only
MINUI_RELEASE_OUTPUT := /workspace/output/minui-release


.PHONY: minui-only-release
minui-only-release:
	$(MINUI_RELEASE_SCRIPT) only


.PHONY: minui-release
minui-release: picoarch-paks picoarch-tool
	$(MINUI_RELEASE_SCRIPT) full


.PHONY: clean-minui-only-release
clean-minui-only-release:
	rm -rf $(MINUI_ONLY_OUTPUT)
	rm -rf /workspace/build/minui-release-only


.PHONY: clean-minui-release
clean-minui-release:
	rm -rf $(MINUI_RELEASE_OUTPUT)
	rm -rf /workspace/build/minui-release-full
