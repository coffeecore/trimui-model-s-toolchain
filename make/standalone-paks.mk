STANDALONE_PAKS_OUTPUT := /workspace/output/standalone-paks
STANDALONE_PAKS_SCRIPT := /workspace/scripts/package-standalone-paks.sh

.PHONY: standalone-paks
standalone-paks:
	$(STANDALONE_PAKS_SCRIPT)

.PHONY: clean-standalone-paks
clean-standalone-paks:
	rm -rf $(STANDALONE_PAKS_OUTPUT)
