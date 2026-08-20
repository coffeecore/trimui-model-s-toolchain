MINUI_RELEASE_SCRIPT := /workspace/scripts/package-minui-release.sh

MINUI_ONLY_OUTPUT := /workspace/output/minui-only
MINUI_STANDALONE_OUTPUT := /workspace/output/minui-standalone
MINUI_PICOARCH_OUTPUT := /workspace/output/minui-picoarch
MINUI_RELEASE_OUTPUT := /workspace/output/minui-release

.PHONY: minui-only-release
minui-only-release:
	$(MINUI_RELEASE_SCRIPT) only

.PHONY: minui-standalone-release
minui-standalone-release: minui-extra-paks standalone-paks
	$(MINUI_RELEASE_SCRIPT) standalone

.PHONY: minui-picoarch-release
minui-picoarch-release: picoarch-paks picoarch-tool
	$(MINUI_RELEASE_SCRIPT) picoarch

.PHONY: minui-release
minui-release: minui-extra-paks standalone-paks picoarch-paks picoarch-tool
	$(MINUI_RELEASE_SCRIPT) full


.PHONY: clean-minui-only-release
clean-minui-only-release:
	rm -rf $(MINUI_ONLY_OUTPUT)
	rm -rf /workspace/build/minui-release-only

.PHONY: clean-minui-standalone-release
clean-minui-standalone-release:
	rm -rf $(MINUI_STANDALONE_OUTPUT)
	rm -rf /workspace/build/minui-release-standalone

.PHONY: clean-minui-picoarch-release
clean-minui-picoarch-release:
	rm -rf $(MINUI_PICOARCH_OUTPUT)
	rm -rf /workspace/build/minui-release-picoarch

.PHONY: clean-minui-release
clean-minui-release:
	rm -rf $(MINUI_RELEASE_OUTPUT)
	rm -rf /workspace/build/minui-release-full
