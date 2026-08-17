# Trimui Model S — systèmes disponibles

> État de référence après validation de l'étape 8.
>
> Ce document décrit les systèmes actuellement prévus dans notre build MinUI Legacy pour Trimui Model S.
> Il sera à mettre à jour après les tests réels sur console.
>
> Légende :
>
> - **MinUI natif** : émulateur/PAK fourni par MinUI Legacy.
> - **Standalone** : émulateur compilé séparément.
> - **PicoArch** : notre frontend PicoArch + core libretro validé.
> - **Oui (alt.)** : alternative supplémentaire au support déjà présent.
> - **Externe** : fichier BIOS/firmware que nous ne distribuons pas.

## Vue d'ensemble

| Système | MinUI natif | Standalone | PicoArch | Core / émulateur PicoArch | Notes |
|---|---:|---:|---:|---|---|
| Nintendo / NES | Oui | — | Oui | FCEUmm, QuickNES | Deux alternatives PicoArch |
| Famicom Disk System | — | — | Oui | FCEUmm | `disksys.rom` externe obligatoire |
| Game Boy | Oui | — | Oui | Gambatte | |
| Game Boy Color | Oui | — | Oui | Gambatte | |
| Game Boy Advance | Oui | — | Oui | gpSP | BIOS externe non obligatoire ; BIOS intégré |
| Game Gear | Oui | — | Oui | SMS Plus GX | |
| Master System | Oui | — | Oui | SMS Plus GX | |
| SG-1000 | — | — | Oui | blueMSX | Assets blueMSX packagés |
| ColecoVision | — | — | Oui | blueMSX | Assets blueMSX packagés |
| Genesis / Mega Drive | Oui | — | Oui | PicoDrive | |
| Sega CD / Mega CD | Entrée additionnelle MinUI possible | — | Oui | PicoDrive | BIOS Sega CD externe obligatoire |
| Sega 32X | Entrée additionnelle MinUI possible | — | Oui | PicoDrive | BIOS 32X externe non requis par défaut |
| Super Nintendo / SNES | Oui | — | Oui | SNES9x 2002, 2005, 2005 Plus, 2010 | Quatre alternatives PicoArch |
| Satellaview / BS-X | — | — | Oui | SNES9x 2010 | `BS-X.bin` ou `BS-X.bios` externe |
| Sufami Turbo | — | — | Oui | SNES9x 2010 | Images combinées avec notre PicoArch actuel ; `STBIOS.bin` externe |
| PlayStation | Oui | — | Oui | PCSX-ReARMed | Copie de `scph5502.bin` depuis le NAND si disponible ; HLE en secours |
| TurboGrafx-16 / PC Engine | Oui | — | Oui | Beetle PCE Fast | |
| TurboGrafx-CD / PC Engine CD | Entrée additionnelle MinUI possible | — | Oui | Beetle PCE Fast | `syscard3.pce` externe obligatoire |
| SuperGrafx | — | — | **Non actuellement** | — | Notre Beetle PCE Fast ne supporte pas SuperGrafx |
| Neo Geo Pocket | Oui | — | Oui | Mednafen NGP | |
| Neo Geo Pocket Color | Oui | — | Oui | Mednafen NGP | |
| WonderSwan | Oui | — | Oui | Mednafen WonderSwan | |
| WonderSwan Color | Entrée additionnelle MinUI possible | — | Oui | Mednafen WonderSwan | |
| Pokémon Mini | Oui | — | Oui | PokeMini | |
| MSX | — | — | Oui | blueMSX, fMSX | Deux alternatives ; assets/ROMs fournis dans les sources des cores |
| Atari 2600 | — | Oui | Oui | Stella 2014 | Standalone Stella + alternative PicoArch |
| Arcade | — | Oui | Oui | MAME 2000, MAME 2003 Plus, FBA 2012 | Standalone GnGeo pour Neo Geo ; romsets compatibles requis |
| Neo Geo | — | Oui | via Arcade | FBA 2012 / MAME selon romset | GnGeo standalone dédié |
| Amstrad GX4000 | — | Oui | — | — | Arnold standalone |
| PICO-8 | — | Oui | Oui | Fake-08 | Retro8 standalone + Fake-08 |
| Game Music | — | — | Oui | Game Music Emu | Formats AY/GBS/GYM/HES/KSS/NSF/NSFE/SAP/SPC/VGM/VGZ |
| Doom | — | — | Oui | PrBoom | IWAD utilisateur |
| Heretic | — | — | Oui | PrBoom | IWAD utilisateur |
| Hexen | — | — | Oui | PrBoom | IWAD utilisateur |

## PAKs MinUI Legacy natifs

Les PAKs effectivement présents dans le PAYLOAD MinUI Legacy compilé sont :

| PAK | Système |
|---|---|
| `Game Boy Advance.pak` | Game Boy Advance |
| `Game Boy Color.pak` | Game Boy Color |
| `Game Boy.pak` | Game Boy |
| `Game Gear.pak` | Game Gear |
| `Genesis.pak` | Genesis / Mega Drive |
| `Lynx.pak` | Atari Lynx |
| `Master System.pak` | Sega Master System |
| `Neo Geo Pocket Color.pak` | Neo Geo Pocket Color |
| `Neo Geo Pocket.pak` | Neo Geo Pocket |
| `Nintendo.pak` | NES |
| `PlayStation.pak` | PlayStation |
| `Pokemon Mini.pak` | Pokémon Mini |
| `Super Nintendo.pak` | SNES |
| `TurboGrafx-16.pak` | PC Engine / TurboGrafx-16 |
| `WonderSwan.pak` | WonderSwan |

### Entrées additionnelles MinUI connues

Le pack additionnel MinUI examiné fournit des entrées/remappings pour :

- Famicom Disk System ;
- Sega CD / Mega CD ;
- Sega 32X ;
- TurboGrafx-CD / PC Engine CD-ROM² ;
- WonderSwan Color ;
- ainsi que plusieurs alias japonais (`Family Computer`, `Mega Drive`, `PC Engine`, `Super Famicom`).

Nous ne recopions pas directement ces launchers : ils servent de référence, mais notre packaging PicoArch utilise ses propres chemins et `system_dir`.

## Émulateurs standalone compilés

| Système | Émulateur | Sortie prévue |
|---|---|---|
| Amstrad GX4000 | Arnold | `GX4000.pak` |
| Atari 2600 | Stella | `Atari2600.pak` |
| Neo Geo | GnGeo | PAK standalone GnGeo |
| PICO-8 | Retro8 | `PICO-8.pak` |

## PAKs PicoArch prévus

### Nintendo

| PAK | Core | ROM_DIR |
|---|---|---|
| `Nintendo (FCEUmm).pak` | `fceumm` | `Nintendo` |
| `Nintendo (QuickNES).pak` | `quicknes` | `Nintendo` |
| `Famicom Disk System (FCEUmm).pak` | `fceumm` | `Famicom Disk System` |

### Game Boy

| PAK | Core | ROM_DIR |
|---|---|---|
| `Game Boy (PicoArch).pak` | `gambatte` | `Game Boy` |
| `Game Boy Color (PicoArch).pak` | `gambatte` | `Game Boy Color` |
| `Game Boy Advance (PicoArch).pak` | `gpsp` | `Game Boy Advance` |

### Sega 8-bit / Coleco

| PAK | Core | ROM_DIR |
|---|---|---|
| `Game Gear (PicoArch).pak` | `smsplus-gx` | `Game Gear` |
| `Master System (PicoArch).pak` | `smsplus-gx` | `Master System` |
| `ColecoVision (blueMSX).pak` | `bluemsx` | `ColecoVision` |
| `SG-1000 (blueMSX).pak` | `bluemsx` | `SG-1000` |

### Sega 16/32-bit et CD

| PAK | Core | ROM_DIR |
|---|---|---|
| `Genesis (PicoArch).pak` | `picodrive` | `Genesis` |
| `Sega CD (PicoArch).pak` | `picodrive` | `Sega CD` |
| `Sega 32X (PicoArch).pak` | `picodrive` | `Sega 32X` |

### Super Nintendo et dérivés

| PAK | Core | ROM_DIR |
|---|---|---|
| `Super Nintendo (Snes9x 2002).pak` | `snes9x2002` | `Super Nintendo` |
| `Super Nintendo (Snes9x 2005).pak` | `snes9x2005` | `Super Nintendo` |
| `Super Nintendo (Snes9x 2005 Plus).pak` | `snes9x2005_plus` | `Super Nintendo` |
| `Super Nintendo (Snes9x 2010).pak` | `snes9x2010` | `Super Nintendo` |
| `Satellaview (Snes9x 2010).pak` | `snes9x2010` | `Satellaview` |
| `Sufami Turbo (Snes9x 2010).pak` | `snes9x2010` | `Sufami Turbo` |

### Sony

| PAK | Core | ROM_DIR |
|---|---|---|
| `PlayStation (PicoArch).pak` | `pcsx_rearmed` | `PlayStation` |

### NEC

| PAK | Core | ROM_DIR |
|---|---|---|
| `TurboGrafx-16 (PicoArch).pak` | `beetle-pce-fast` | `TurboGrafx-16` |
| `TurboGrafx-CD (PicoArch).pak` | `beetle-pce-fast` | `TurboGrafx-CD` |

### SNK / Bandai

| PAK | Core | ROM_DIR |
|---|---|---|
| `Neo Geo Pocket (PicoArch).pak` | `mednafen_ngp` | `Neo Geo Pocket` |
| `Neo Geo Pocket Color (PicoArch).pak` | `mednafen_ngp` | `Neo Geo Pocket Color` |
| `WonderSwan (PicoArch).pak` | `mednafen_wswan` | `WonderSwan` |
| `WonderSwan Color (PicoArch).pak` | `mednafen_wswan` | `WonderSwan Color` |
| `Pokemon Mini (PicoArch).pak` | `pokemini` | `Pokemon Mini` |

### MSX

| PAK | Core | ROM_DIR |
|---|---|---|
| `MSX (blueMSX).pak` | `bluemsx` | `MSX` |
| `MSX (fMSX).pak` | `fmsx` | `MSX` |

### Atari

| PAK | Core | ROM_DIR |
|---|---|---|
| `Atari 2600 (PicoArch).pak` | `stella2014` | `Atari 2600` |

### Arcade

| PAK | Core | ROM_DIR |
|---|---|---|
| `Arcade (MAME 2000).pak` | `mame2000` | `Arcade` |
| `Arcade (MAME 2003 Plus).pak` | `mame2003_plus` | `Arcade` |
| `Arcade (FBA 2012).pak` | `fbalpha2012` | `Arcade` |

### Autres

| PAK | Core | ROM_DIR |
|---|---|---|
| `Game Music.pak` | `gme` | `Game Music` |
| `PICO-8 (Fake-08).pak` | `fake-08` | `PICO-8` |
| `Doom (PrBoom).pak` | `prboom` | `Doom` |
| `Heretic (PrBoom).pak` | `prboom` | `Heretic` |
| `Hexen (PrBoom).pak` | `prboom` | `Hexen` |

**Total PicoArch prévu : 38 PAKs pour 24 cores validés.**

## BIOS / fichiers système externes

| Système | Fichier | Statut |
|---|---|---|
| Famicom Disk System | `disksys.rom` | Obligatoire, externe |
| Game Boy Advance | `gba_bios.bin` | Optionnel ; gpSP possède un BIOS intégré |
| PlayStation | `scph5502.bin` | Copié depuis le NAND si disponible ; HLE en secours |
| Sega CD | BIOS Sega/Mega CD selon région | Obligatoire, externe |
| Sega 32X | BIOS 32X | Non requis par défaut dans notre packaging |
| TurboGrafx-CD | `syscard3.pce` | Obligatoire, externe |
| Satellaview | `BS-X.bin` ou `BS-X.bios` | Externe |
| Sufami Turbo | `STBIOS.bin` | Externe |
| Doom | IWAD (`doom.wad`, `doom2.wad`, etc.) | Contenu utilisateur, pas un BIOS |
| Heretic | IWAD (`heretic.wad`, etc.) | Contenu utilisateur |
| Hexen | IWAD Hexen | Contenu utilisateur |

## Assets packagés automatiquement

### blueMSX

Pour les trois entrées :

- MSX ;
- ColecoVision ;
- SG-1000 ;

nous copions les assets fournis par le core :

```text
Machines/
Databases/
```

dans le `system_dir` propre à chaque système.

### fMSX

Les ROMs nécessaires présentes dans le checkout fMSX pourront être packagées :

```text
MSX.ROM
MSX2.ROM
MSX2EXT.ROM
MSX2P.ROM
MSX2PEXT.ROM
DISK.ROM
KANJI.ROM
```

## Points à revalider sur matériel réel

- compatibilité/performance de chacun des 24 cores ;
- gestion du changement de disque via mmenu ;
- performances des quatre variantes SNES9x ;
- fonctionnement réel de Satellaview avec BIOS ;
- Sufami Turbo en image combinée ;
- Doom / Heretic / Hexen sur le Model S ;
- ROMsets exacts recommandés pour MAME 2000, MAME 2003 Plus et FBA 2012 ;
- intérêt éventuel d'ajouter ultérieurement un core SuperGrafx dédié ;
- choix final entre les alternatives lorsque plusieurs émulateurs couvrent le même système.

