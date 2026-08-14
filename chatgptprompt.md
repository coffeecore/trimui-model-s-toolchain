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
