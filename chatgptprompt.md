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