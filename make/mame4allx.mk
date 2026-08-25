MAME4ALLX_SCRIPT := /workspace/scripts/package-mame4allx-pak.sh
MAME4ALLX_OUTPUT := /workspace/output/mame4allx
MAME4ALLX_BUILD := /workspace/build/mame4allx

.PHONY: mame4allx-pak clean-mame4allx-pak

mame4allx-pak:
	$(MAME4ALLX_SCRIPT)

clean-mame4allx-pak:
	rm -rf $(MAME4ALLX_OUTPUT)
	rm -rf $(MAME4ALLX_BUILD)
