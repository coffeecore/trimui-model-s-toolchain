# -----------------------------------------------------------------------------
# Arnold / Amstrad GX4000
# -----------------------------------------------------------------------------

ARNOLD_REPO := https://github.com/coffeecore/arnold_gcw0.git
ARNOLD_BRANCH := trimui-powkiddy-a66
ARNOLD_DIR := /workspace/sources/arnold
ARNOLD_OUTPUT_DIR := $(OUTPUT_DIR)/arnold

.PHONY: \
	source-arnold \
	build-arnold \
	clean-build-arnold \
	clean-source-arnold \
	install-arnold \
	clean-install-arnold \
	arnold

arnold:
	$(MAKE) clean-install-arnold
	$(MAKE) clean-build-arnold
	$(MAKE) build-arnold
	$(MAKE) install-arnold

# Clone Arnold s'il n'est pas déjà présent.
# La branche trimui-powkiddy-a66 contient les adaptations Trimui Model S/A66.
source-arnold:
	@if [ ! -d "$(ARNOLD_DIR)/.git" ]; then \
		mkdir -p "$(dir $(ARNOLD_DIR))"; \
		git clone \
			--branch $(ARNOLD_BRANCH) \
			--single-branch \
			$(ARNOLD_REPO) \
			$(ARNOLD_DIR); \
	fi


# Compile Arnold avec le Makefile upstream.
#
# Le Makefile Arnold utilise directement :
#   /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-gcc
#
# Ce chemin est fourni par notre couche de compatibilité toolchain.
build-arnold: source-arnold
	cd "$(ARNOLD_DIR)" && $(MAKE) -j$(JOBS)

	test -x "$(ARNOLD_DIR)/arnold"


# Le clean upstream supprime les objets mais oublie le binaire final.
# On complète donc le nettoyage sans modifier le dépôt Arnold.
clean-build-arnold:
	cd "$(ARNOLD_DIR)" && $(MAKE) clean
	rm -f "$(ARNOLD_DIR)/arnold"


# Supprime complètement le checkout Arnold.
clean-source-arnold:
	rm -rf "$(ARNOLD_DIR)"


# Prépare le paquet MinUI GX4000.
#
# Le dépôt fournit GX4000.pak/launch.sh.
# Le launcher attend simplement le binaire "arnold" dans le même dossier.
install-arnold:
	test -x "$(ARNOLD_DIR)/arnold"

	rm -rf "$(ARNOLD_OUTPUT_DIR)"
	mkdir -p "$(ARNOLD_OUTPUT_DIR)"

	cp -R \
		"$(ARNOLD_DIR)/GX4000.pak" \
		"$(ARNOLD_OUTPUT_DIR)/"

	cp \
		"$(ARNOLD_DIR)/arnold" \
		"$(ARNOLD_OUTPUT_DIR)/GX4000.pak/arnold"


clean-install-arnold:
	rm -rf "$(ARNOLD_OUTPUT_DIR)"
