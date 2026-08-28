# 1

On va reprendre la mise en place d'un environement de dev pour Trimui model s sous docker

Liste des projets qu'on doit pouvoir recompiler :
- minui legacy : https://github.com/coffeecore/MinUI-Legacy-Trimui-Model-S
- arnold : https://github.com/coffeecore/arnold_gcw0/tree/trimui-powkiddy-a66
- stella : https://github.com/coffeecore/Stella-3.9.3
- gngeo : https://github.com/coffeecore/gngeo
- retro8 : https://github.com/coffeecore/retro8/tree/trimui-model-s
- picoarch : https://github.com/coffeecore/picoarch/commit/53e0e6b2b72b8c50e6b9fceb437dfa8c650d05c5

Regles qu'on se fixe : 
- prends ton temps pour répondre
- pas de supposition
- pas de réponse pour revenir ensuite dessus dans la réponse suivante
- pas de réponse verbeuses pour rien
- pas de modifications des projets qu'on va compiler. On passe par des exports de variables, des paramètres aux commandes make etc
- utilisation de crosstool-ng
- un seul conteneur docker
- si tu as besoin que je tape des commandes, elles doivent être explicites et à la fin de ta réponse
- les modifications de fichiers doivent être claires avec le nom du fichier et les modifications exactes
- si tu me demandes de modifier un fichier, prend le bien en compte dans tes réponses suivantes sauf si je dis explicitement que je n'ai pas fait la modification
- tant qu'un projet ne compile pas, on ne passe pas au suivant, donc bien suivre l'ordre que j'ai donné

Ce qu'on sait déjà :
- crosstool-ng ne peut pas être compilé en root donc prévoir utilisateur "builder" sur le docker
- le checkout des submodules doit passer par https pas ssh
- les librairies qu'on a déjà identifié :
	- https://github.com/madler/zlib.git v1.3.1 : déjà fait
	- https://github.com/libsdl-org/SDL-1.2.git release-1.2.15
	- https://github.com/libsdl-org/SDL_image.git release-1.2.12
	- https://github.com/libsdl-org/SDL_mixer.git release-1.2.12
	- https://github.com/libsdl-org/SDL_ttf.git release-2.0.11
	- https://github.com/tinyalsa/tinyalsa.git v2.0.0
- j'ai déjà un fichier de config crosstool-ng, on va le vérifier
- je n'ai pas de dockerfile, je sais juste qu'on doit partir sur du ubuntu:22.04. On doit avoir un docker compose et pouvoir faire make shell pour rentrer dans le conteneur

Commande make que je veux :
- make shell : accéder au contenur
- make clean : nettoyage des artefacts de compilation
- clean-all : retour à un état quasiment vierge, sans forcément supprimer les sources téléchargées.


Ce que je veux pouvoir faire dans le contenur, chaque commande make doit s'accompagner d'une commande préfixée de "clean" pour nettoyer ce que je la commande make a fait :
- make build-toolchain : récupération des sources et compilation de la toolchain : on a déjà
- make install-toolchain : créer les liens symboliques, copie les fichiers où il faut etc. : on a déjà
- make build-libs : récupération des sources et compilation des librairies nécessaires à tous les projets à compiler. Je veux une sous commande make par librairies, donc la commande "make build-libs" appellera ces sous-commandes
- make install-libs : créer les liens symboliques, copie les fichiers où il faut etc. Je veux une sous commande make par librairies, donc la commande "make install-libs" appellera ces sous-commandes
- make minui : récupération des sources et compilation du projet minui legacy
- make arnold : récupération des sources et compilation du projet
- make stella : récupération des sources et compilation du projet
- make gngeo : récupération des sources et compilation du projet
- make retro8 : récupération des sources et compilation du projet
- make picoarch : récupération des sources et compilation du projet

Les dossiers que je veux dans le projet :
- docker : contient le dockerfile
- sources : sources des projets
- libs : sources des libs
- toolchain ; source pour la toolchain
- output : fichiers produits après la compilation qu'on doit installer sur le trimui model s
- sysroot
- build

Est-ce clair ? des suggestions avant de commencer ? des remarques ? ai-je oublié des choses ?

# 2

Avant d'avancer Arnold, le makefile (que je remets en piece jointe) est plutot volumineux maintenant (presque 1000 lignes)

Est-ce qu on peut :

- le diviser en un  makefile pour toolchain, un make file pour libs, un make file pour minui ? On fera donc un makefile Arnold
- possible d'avoir une commande make toolchain pour supprimer, build, installer la toolchain ? (dans le makefile global) et de meme pour libs ? pour éviter d'avoir à taper des commandes à la suite lors du premier lancement du projet
- tu peux voir que je commente les lignes avec $$(nproc) pour remplacer par 4. Possible d'en faire une variable avec par defaut $$(nproc) et que je viens surcharger par 4 sur la ligne du dessous
- ajoute des commentaires pour comprendre tout ce qui est fait

# 3
Oui. Avant de toucher à quoi que ce soit, voilà l’ordre que je suivrais maintenant.

1. **Consolider `make/picoarch.mk`**

   * vérifier que tous les cores validés ont bien :

     * leur repo ;
     * leur commit figé ;
     * leur patch externe si nécessaire ;
     * une cible de build ;
     * une cible de clean ;
   * vérifier aussi que `picoarch-validated` et `picoarch-clean-validated` contiennent bien tous les cores.
   * À ce stade, on corrige uniquement notre infrastructure externe, pas les sources upstream.

2. **Consolider `patches/picoarch/VALIDATED.md`**

   * vérifier que chaque core validé y apparaît ;
   * noter le commit exact, les patches, les particularités de build et les warnings acceptés ;
   * notamment les cas spéciaux :

     * `fbalpha2012` ;
     * `mame2003_plus` + Cyclone + `-fgnu89-inline` ;
     * `fake-08` compilé via C++ ;
     * `prboom` avec `-fPIC`.

3. **Faire un clean complet des cores PicoArch**

   * utiliser uniquement nos cibles `clean`;
   * le but est de supprimer toute possibilité qu’un ancien `.o` ou `.so` manuel masque un problème de reproductibilité.

4. **Recompiler tous les cores validés d’un seul coup**

   * lancer `picoarch-validated`;
   * ce sera le vrai test de reproductibilité global ;
   * si un core échoue, on corrige sa recette avant d’aller plus loin.

5. **Valider automatiquement tous les `.so` produits**

   * vérifier pour chacun :

     * ELF32 ;
     * ARM ;
     * EABI5 ;
     * soft-float ;
     * ARM926EJ-S / v5TEJ ;
   * vérifier aussi qu’aucun core n’a accidentellement été produit en ARMv6/7, NEON ou hard-float.
   * À ce moment-là, on aura notre liste définitive de cores réellement utilisables pour le Model S.

6. **Recompiler/valider le frontend PicoArch avec les mêmes conditions**

   * s’assurer que le frontend validé est toujours reproductible avec les patches externes ;
   * vérifier son ELF et ses dépendances ;
   * vérifier surtout son chargement dynamique de `libmmenu.so` et des cores `.so`.

7. **Construire un arbre de sortie PicoArch propre**
   Quelque chose du genre :

   ```text
   output/picoarch/
   ├── picoarch
   ├── cores/
   │   ├── fceumm_libretro.so
   │   ├── gambatte_libretro.so
   │   ├── ...
   │   ├── mame2003_plus_libretro.so
   │   ├── fake08_libretro.so
   │   └── prboom_libretro.so
   └── ...
   ```

   On ne doit plus dépendre des fichiers qui traînent dans `/workspace/build`.

8. **Déterminer les PAKs MinUI à créer**
   Là, on fera le mapping propre :

   * nom du PAK ;
   * core utilisé ;
   * dossier ROM ;
   * extensions acceptées ;
   * BIOS éventuels ;
   * paramètres particuliers.

   Par exemple, il faudra décider comment présenter les différents cores SNES et Arcade sans créer un menu illisible.

9. **Créer les launchers/PAKs PicoArch**

   * utiliser le frontend PicoArch ;
   * pointer vers le bon `.so` ;
   * respecter la structure MinUI Legacy ;
   * aucune modification à MinUI upstream ;
   * intégrer les chemins BIOS/ROM nécessaires.

10. **Traiter les cas particuliers**
    Notamment :

* Arcade :

  * `mame2000`
  * `fbalpha2012`
  * `mame2003_plus`
* SNES :

  * `snes9x2002`
  * `snes9x2005`
  * `snes9x2005_plus`
  * `snes9x2010`
* PICO-8 :

  * `fake-08`
  * et notre standalone `Retro8`
* Doom/PrBoom :

  * déterminer où mettre les WADs et le WAD de base nécessaire.

11. **Assembler avec les standalones déjà construits**
    On réunira ensuite :

* MinUI Legacy ;
* PicoArch + cores ;
* Arnold ;
* Stella standalone ;
* GnGeo ;
* Retro8 ;
* leurs PAKs respectifs.

12. **Créer le package de test Model S**
    Pas encore la release définitive : d’abord une arborescence installable sur SD pour tester sur la vraie console.

13. **Tests réels sur le Trimui Model S**
    Pour chaque famille importante :

* lancement depuis MinUI ;
* chargement d’une ROM ;
* son ;
* contrôles ;
* sortie vers MinUI sans reboot ;
* menu `mmenu` ;
* save/load state ;
* changement de jeu ;
* retour au menu ;
* éventuellement performances/frameskip.

C’est particulièrement important pour les extras qu’on a seulement validés à la compilation.

14. **Corriger uniquement les problèmes réellement observés sur hardware**
    À ce stade seulement, on ajustera launchers, options de cores ou patches si nécessaire.

15. **Créer la release finale**
    Quand tout fonctionne :

* build depuis zéro ;
* collecte automatique dans `output/`;
* structure propre ;
* version/commit de chaque composant documenté ;
* archive finale MinUI/Model S.

Je pense qu’on doit **commencer maintenant par les étapes 1 à 5** : audit du `make/picoarch.mk`, clean complet, rebuild de tous les cores, puis validation globale. On ne commence les PAKs qu’une fois cette base totalement reproductible.

# 4

MinUI multi-emulator support

[ ] option globale enable-emulator-selector
[ ] déclaration du système dans les PAKs alternatifs
[ ] découverte des PAKs compatibles
[ ] écran de sélection d'émulateur
[ ] mémorisation du dernier PAK par ROM
[ ] lancement direct du dernier PAK
[ ] action pour changer d'émulateur
[ ] intégration correcte avec Resume/mmenu
[ ] fallback propre si le PAK mémorisé a été supprimé
[ ] comportement MinUI original lorsque la fonction est désactivée

better :
[ ] option globale multi-emulator
[ ] A ouvre toujours le sélecteur si option activée
[ ] dernier émulateur utilisé mémorisé par ROM
[ ] dernier émulateur présélectionné
[ ] marqueur [default]
[ ] premier lancement -> PAK principal comme default
[ ] intégration Resume cohérente avec l'émulateur choisi

# 5

J’ai le ZIP et j’ai vérifié la structure. Tu m’as bien envoyé tout ce qu’il faut pour travailler sur la migration du toolchain : `Makefile`, tous les `make/*.mk`, `docker/dockerfile` et `docker-compose.yml`.

La base actuelle confirme plusieurs points importants :

* `make/common.mk` définit encore tout le monde autour de notre crosstool-NG `arm-unknown-linux-gnueabi` et du sysroot `/workspace/sysroot`.
* `make/toolchain.mk` crée effectivement les wrappers de compatibilité `/opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-*`.
* `MinUI`, PicoArch, Stella et GnGeo utilisent déjà ce préfixe historique `/opt/trimui-toolchain/...`.
* notre `libs.mk` reconstruit beaucoup de bibliothèques en **statique**, ce qui explique directement pourquoi notre `MinUI` s’est retrouvé à 735 Kio au lieu des ~31 Kio de l’officiel.
* le Dockerfile actuel ne contient aucun vrai toolchain dans `/opt/trimui-toolchain` : il crée seulement le répertoire pour que nos wrappers puissent y être installés.

J’ai aussi vérifié le dépôt `union-trimui-toolchain`. Son README confirme que le toolchain est installé **directement sous `/opt/` dans son image Docker**, et qu’il est basé sur le toolchain Trimui de neonloop. ([GitHub][1]) C’est particulièrement pertinent pour PicoArch : Shaun Inman crédite explicitement neonloop pour le toolchain Trimui original et pour PicoArch, et le PicoArch Trimui est conçu pour être construit après mise en place de ce toolchain. ([GitHub][2])

Donc oui : **on a maintenant la base nécessaire et je pense toujours qu’il est pertinent d’essayer de migrer vers le toolchain historique comme toolchain unique**, mais progressivement.

Je te propose l’ordre suivant, sans encore supprimer quoi que ce soit :

1. intégrer `union-trimui-toolchain` dans notre environnement Docker actuel ;
2. identifier exactement les chemins qu’il fournit sous `/opt/`;
3. compiler uniquement MinUI avec lui ;
4. comparer le nouveau binaire au MinUI officiel qui fonctionne ;
5. si MinUI fonctionne sur console, tester PicoArch avec le même toolchain ;
6. ensuite Arnold, Stella, GnGeo et Retro8 ;
7. seulement après validation globale, supprimer crosstool-NG, les wrappers et les morceaux de `libs.mk` devenus inutiles.

Et bonne nouvelle : comme plusieurs de tes Makefiles utilisent déjà `/opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-*`, **la migration pourrait nécessiter beaucoup moins de changements de chemins que prévu**.

On peut commencer maintenant par l’étape 1 : intégrer le vrai `union-trimui-toolchain` à ton Dockerfile actuel sans encore toucher aux Makefiles des émulateurs.

[1]: https://github.com/shauninman/union-trimui-toolchain?utm_source=chatgpt.com "GitHub - shauninman/union-trimui-toolchain · GitHub"
[2]: https://github.com/shauninman/MinUI/blob/main/skeleton/BASE/README.txt?utm_source=chatgpt.com "MinUI/skeleton/BASE/README.txt at main · shauninman/MinUI · GitHub"

# 6

Mon plan, pour cette partie, il faudra peut etre qu'on revoit comment on build et install les libs :
- on compile les cores+front end
- on compile les stand alone
- on compile minui
- on fait une release. Petit ajout, on doit avoir picoarch dispo dans le dossier Tools/ pour pouvoir le lancer sans passer par des roms, ca permettra de plus rapidement tester les cores
- on teste sur la console si minui se lance

Ensuite :
- creer un pak pour mame4allx du firmware original
- on regarde pour pifba, fba-sdl ou autre alternative

# 7

```bash
BIN="/workspace/output/retro8/PICO-8.pak/retro8"

echo "===== FILE ====="
file "$BIN"

echo
echo "===== NEEDED ====="
readelf -d "$BIN" | grep NEEDED || true

echo
echo "===== INTERPRETER ====="
readelf -l "$BIN" | grep interpreter || true

echo
echo "===== GLIBC ====="
readelf --version-info "$BIN" \
    | grep -o 'GLIBC_[0-9.]*' \
    | sort -Vu
```

doit donner 
ARM 32-bit EABI5 ;
/lib/ld-linux.so.3 ;
GNU/Linux 3.10.0 ;
dépendances attendues : SDL 1.2, png12, zlib, pthread, dl, libstdc++, libgcc_s, libc ;
seulement GLIBC_2.4.


# 8
Oui. Maintenant que les chemins sont propres, je ferais un **test complet de reproductibilité**, en gardant seulement le projet et le toolchain `/opt/trimui-toolchain`, comme si tu venais de cloner le dépôt.

Point important : `minui-release` **ne compile pas tout tout seul** dans tes Makefiles actuels. Il faut construire les éléments avant le packaging.

### 1. Repartir proprement

Avant de supprimer les sources, retire les libs que notre projet a installées dans le sysroot actuel :

```bash
make clean-install-libs
```

Ensuite, pour vraiment simuler un clone frais du projet :

```bash
rm -rf /workspace/sources
rm -rf /workspace/libs
rm -rf /workspace/build
rm -rf /workspace/output
```

On **ne touche pas** à :

```text
/opt/trimui-toolchain
```

C'est notre toolchain de base.

Tu peux vérifier :

```bash
ls -lah /workspace
ls -lah /opt/trimui-toolchain/bin/arm-buildroot-linux-gnueabi-gcc
```

---

### 2. Recompiler toutes les libs depuis zéro

```bash
make build-libs
```

Puis les installer dans le sysroot final :

```bash
make install-libs
```

Vérification rapide :

```bash
ls /opt/trimui-toolchain/usr/arm-buildroot-linux-gnueabi/sysroot/usr/lib | \
grep -E 'libSDL\.a|libSDL_image\.a|libSDL_mixer\.a|libSDL_ttf\.a|libtinyalsa\.a|libasound\.a|libmad\.a|libbz2\.a'
```

Puis vérifier qu'aucun vieux toolchain n'est revenu :

```bash
grep -RIlE \
'/workspace/toolchain|arm-unknown-linux-gnueabi|/workspace/sysroot|/opt/trimui-toolchain/arm-buildroot-linux-gnueabi' \
/workspace/build 2>/dev/null
```

Ça doit être vide.

---

### 3. Recompiler MinUI Legacy complètement

Comme on a supprimé `/workspace/sources`, **n'utilise pas `make minui` ici** : cette target commence par un clean d'un checkout qui n'existe plus.

Utilise directement :

```bash
make build-minui
```

`build-minui` va lui-même :

* cloner MinUI ;
* récupérer les submodules ;
* construire le système MinUI ;
* reconstruire `libmsettings` / `libmmenu` ;
* construire les émulateurs MinUI Legacy ;
* construire PicoDrive ;
* créer le zip upstream MinUI.

Ensuite :

```bash
find /workspace/sources/minui/build -maxdepth 2 -type f | sort
```

---

### 4. Compiler les quatre standalone

Dans notre projet, ce sont :

```text
Arnold  -> GX4000
Stella  -> Atari 2600
GnGeo   -> Neo Geo
Retro8  -> PICO-8
```

Puisque leurs sources n'existent plus, utilise les targets `build-*`, puis `install-*` :

```bash
make build-arnold
make install-arnold

make build-stella
make install-stella

make build-gngeo
make install-gngeo

make build-retro8
make install-retro8
```

Puis :

```bash
find /workspace/output/arnold \
     /workspace/output/stella \
     /workspace/output/gngeo \
     /workspace/output/retro8 \
     -maxdepth 3 -type f | sort
```

À ce stade, on sait déjà que GnGeo fonctionne réellement sur la console, menu compris, donc ce rebuild nous permettra aussi de confirmer sa reproductibilité.

---

### 5. Recompiler PicoArch frontend

```bash
make picoarch-frontend
```

Puis tous les cores que nous avons validés :

```bash
make picoarch-validated
```

Ta target `picoarch-validated` contient actuellement les cores validés, notamment FCEUmm, Gambatte, gpSP, PicoDrive, MAME2000, FB Alpha 2012, PCSX-ReARMed, Beetle PCE Fast, BlueMSX, fMSX, GME, NGP, WonderSwan, Pokémon Mini, QuickNES, SMS Plus GX, SNES9x, Stella 2014, MAME2003 Plus, PrBoom, etc.

Ensuite rassemble frontend + cores :

```bash
make picoarch-output
```

Vérifie :

```bash
ls -lah /workspace/output/picoarch/
ls -lah /workspace/output/picoarch/cores/
```

Et surtout :

```bash
file /workspace/output/picoarch/picoarch
file /workspace/output/picoarch/cores/*_libretro.so
```

Ils doivent être ARM, pas x86-64.

---

### 6. Vérification finale de l'ancien crosstool-NG

Avant de packager :

```bash
grep -RIlE \
'/workspace/toolchain|arm-unknown-linux-gnueabi|/workspace/sysroot|/opt/trimui-toolchain/arm-buildroot-linux-gnueabi' \
/workspace/build \
/workspace/output \
/workspace/sources \
2>/dev/null
```

**Idéalement aucune sortie.**

C'est un test très intéressant parce qu'à ce moment-là absolument tout aura été généré depuis zéro avec le nouveau toolchain.

---

### 7. Construire les PAKs

PicoArch :

```bash
make picoarch-paks
```

Standalone :

```bash
make standalone-paks
```

PAKs MinUI additionnels :

```bash
make minui-extra-paks
```

Et l'outil PicoArch :

```bash
make picoarch-tool
```

`picoarch-tool` dépend déjà de `picoarch-output`, donc son entrée sera prête.

---

### 8. Faire la release MinUI complète

Enfin :

```bash
make minui-release
```

Puis :

```bash
find /workspace/output/minui-release -maxdepth 2 -type f -printf '%p  %k KB\n' | sort
```

Et pour voir le contenu du ZIP sans l'extraire :

```bash
unzip -l /workspace/output/minui-release/*.zip | less
```

### Donc, la séquence complète condensée

Si tu veux la suivre tranquillement commande par commande :

```bash
make clean-install-libs

rm -rf /workspace/sources
rm -rf /workspace/libs
rm -rf /workspace/build
rm -rf /workspace/output

make build-libs
make install-libs

make build-minui

make build-arnold
make install-arnold

make build-stella
make install-stella

make build-gngeo
make install-gngeo

make build-retro8
make install-retro8

make picoarch-frontend
make picoarch-validated
make picoarch-output

make picoarch-paks
make standalone-paks
make minui-extra-paks
make picoarch-tool

make minui-release
```

Je ferais **exactement ça maintenant**. C'est notre meilleur test pour savoir si le dépôt est réellement reproductible depuis un checkout propre, sans dépendre d'anciens artefacts.

# 9

```bash
file /workspace/build/picoarch/mame2003_libretro.so

readelf -d \
    /workspace/build/picoarch/mame2003_libretro.so \
    | grep NEEDED
```

# 10

Oui. Et tu as bien identifié la différence entre les deux launchers.

Dans les PAKs système, ton script construit actuellement :

```sh
ROM_DIR="/mnt/SDCARD/Roms/$rom_dir_name"
SYSTEM_DIR="$ROM_DIR/.picoarch-$core_name"
```

puis surtout :

```sh
HOME="$ROM_DIR"
```

PicoArch dérive ensuite lui-même ses répertoires depuis `HOME`, d'où par exemple :

```text
/mnt/SDCARD/Roms/MAME 2003/.picoarch-mame2003/
```

 

Dans le Tool, il n'y a effectivement **aucun `HOME=`**. Le launcher fait juste :

```sh
cd "$PAK_DIR/cores"
"$PAK_DIR/picoarch"
```



C'est pour ça qu'on obtenait :

```text
Config dir: //.picoarch-mame2003/
Save dir: //.picoarch-mame2003/
System dir: //.picoarch-mame2003/
```



## 1. Un seul dossier de config par core, partagé PAK + Tool

Je ferais quelque chose de très simple :

```text
/mnt/SDCARD/.picoarch-mame2003/
/mnt/SDCARD/.picoarch-mame2000/
/mnt/SDCARD/.picoarch-gambatte/
/mnt/SDCARD/.picoarch-picodrive/
...
```

Autrement dit :

```sh
HOME="/mnt/SDCARD"
```

partout.

### Dans `package-picoarch-paks.sh`

Remplace :

```sh
SYSTEM_DIR="\$ROM_DIR/.picoarch-$core_name"
```

par :

```sh
SYSTEM_DIR="/mnt/SDCARD/.picoarch-$core_name"
```

Et plus bas remplace :

```sh
HOME="\$ROM_DIR"
```

par :

```sh
HOME="/mnt/SDCARD"
```

Donc un MAME2003 lancé normalement utilisera :

```text
/mnt/SDCARD/.picoarch-mame2003/picoarch.cfg
```

Le `SYSTEM_DIR` doit suivre le même déplacement, car ton script s'en sert aussi pour installer certains fichiers nécessaires aux cores, par exemple les BIOS PSX et les assets blueMSX. 

### Dans `package-picoarch-tool.sh`

Juste avant :

```sh
cd "$PAK_DIR/cores"
```

ajoute :

```sh
HOME="/mnt/SDCARD"
export HOME
```

Donc :

```sh
HOME="/mnt/SDCARD"
export HOME

cd "$PAK_DIR/cores"

"$PAK_DIR/picoarch"
```

Le Tool choisit ensuite son core et PicoArch construit automatiquement :

```text
mame2003 -> /mnt/SDCARD/.picoarch-mame2003/
gambatte -> /mnt/SDCARD/.picoarch-gambatte/
...
```

Tu obtiens donc exactement le partage recherché :

```text
MAME 2003.pak ──┐
                ├── /mnt/SDCARD/.picoarch-mame2003/picoarch.cfg
PicoArch Tool ──┘
```

Je préfère ça à essayer de faire calculer un `SYSTEM_DIR` au Tool : **le Tool ne connaît pas encore le core au moment où son `launch.sh` démarre**, puisque c'est PicoArch qui te fait choisir le core.

---

## 2. `scale_size` par défaut sur Aspect

Dans ton `set_defaults()` tu as actuellement :

```c
scale_size = SCALE_SIZE_NONE;
```

La modification est effectivement à cet endroit.

Il faut d'abord confirmer le nom exact de l'enum dans **ta version** :

```sh
grep -Rni 'SCALE_SIZE_' \
    /workspace/build/picoarch \
    --include='*.h' \
    --include='*.c' \
    | head -30
```

Si, comme prévu, tu as bien une valeur :

```c
SCALE_SIZE_ASPECT
```

alors la modification sera simplement :

```c
scale_size = SCALE_SIZE_ASPECT;
```

à la place de :

```c
scale_size = SCALE_SIZE_NONE;
```

C'est bien `set_defaults()` qu'il faut modifier : cela changera le **défaut initial**, tout en laissant une config existante contenant par exemple :

```ini
scale_size = 0
```

prendre le dessus ensuite.

Je l'ajouterais à notre `0002-trimui-hotkeys.patch` ou, encore plus propre maintenant qu'il contient déjà des adaptations TrimUI, je le renommerais éventuellement en quelque chose comme :

```text
0002-trimui-defaults.patch
```

et on y garde :

```text
MENU+B -> FF
MENU+X -> FPS
scale par défaut -> Aspect
```

Pour le déplacement des configs, par contre, **pas besoin de patcher PicoArch** : les deux scripts de packaging suffisent.
