# Momentum

Une to-do list gamifiée, noir et blanc, **100 % locale**. Aucun compte, aucun
serveur, aucune API : tâches, routines, série, XP et statistiques vivent dans une
base SQLite sur le téléphone.

Implémentation Flutter de la maquette *Momentum — to-do gamifiée*.

## Installer l'APK

Les APK de release sont dans `build/app/outputs/flutter-apk/` :

| Fichier | Pour qui |
| --- | --- |
| `app-release.apk` | Universel — marche sur tous les téléphones |
| `app-arm64-v8a-release.apk` | Téléphones Android récents (le plus léger) |

Copie le fichier sur le téléphone, ouvre-le, et autorise l'installation depuis
des sources inconnues si Android le demande.

> Les APK sont signés avec la clé de debug de Flutter. C'est suffisant pour une
> installation perso ; il faudra une vraie keystore pour publier sur le Play
> Store ou pour livrer des mises à jour installables par-dessus.

## Rebuild

```bash
flutter build apk --release
```

## Comment l'app fonctionne

**Le jour.** À chaque ouverture, Momentum rattrape les jours écoulés : les jours
passés sont archivés en `day_logs`, les tâches ponctuelles encore ouvertes
remontent à aujourd'hui, et les routines actives réimpriment leurs étapes. Une
étape de routine manquée reste sur le jour qui la demandait.

**L'XP.** Chaque liste porte sa propre récompense (Maison 10, Routine et Focus
15, Famille 25). Fermer une tâche paie ; la rouvrir reprend. L'échelle des
niveaux est définie dans `level.dart` et reprend les paliers de la maquette
(6 Régulière, 7 Constante, 8 Fiable, 9 Inébranlable).

**La quête du jour.** Trois étapes de routine fermées dans la journée paient un
bonus de 40 XP, une fois par jour.

**La série.** Un jour compte dès qu'une tâche y est fermée. Un jour qui ne
demandait rien est neutre (« repos »), il ne casse rien. Un jour manqué est
couvert par un gel — deux par mois calendaire.

**Les stats.** Tout est calculé depuis les tâches réellement fermées : la
régularité sur 28 jours comparée aux 28 précédents, l'XP par jour de la semaine
en cours, et des tendances qui n'apparaissent que quand l'historique permet de
les défendre.

**Le rappel du soir.** Une notification locale à 20h30, replanifiée à chaque
changement d'état et annulée dès qu'il ne reste plus rien d'ouvert.

## Structure

Architecture OSDD : couches techniques réutilisables d'un côté, couche
fonctionnelle métier de l'autre, en clean architecture.

```text
lib/
  main.dart                      composition root (câblage des gateways)
  layers/
    technical/
      theme/                     couleurs, typo, motion, icônes, widgets de base
      persistence/               connexion sqflite et schéma
      notifications/             planification des notifications locales
      formatting/                noms de jours et de mois en français
    functional/
      habit_tracker/
        domain/                  entités, contrats de gateway, use cases
        data/                    modèles de ligne, data sources SQL, gateways
        presentation/            cubit, vues, widgets
```

Le domaine ne connaît ni Flutter, ni SQL : il est testé sans base de données via
les doublures de `test/fakes/`.

## Tests

```bash
flutter test
```

40 tests : l'échelle des niveaux, la série et ses gels, la bascule de jour, la
complétion et son bonus de quête, plus le rendu de chaque écran à taille
téléphone (un débordement de layout y fait échouer le test).

## Écarts assumés par rapport à la maquette

- **Le foyer partagé est retiré.** « Moreau · 3 personnes », « 14 partagées » et
  la synchro sur trois téléphones supposent un backend. La carte est remplacée
  par une carte qui dit où vivent les données.
- **L'onboarding a une quatrième carte** qui demande le prénom — l'app a besoin
  d'un nom pour le « Bonjour », et la maquette ne le demandait nulle part. La
  troisième carte parle désormais du stockage local au lieu du partage.
- **Ajouts nécessaires à un vrai usage** : supprimer une tâche (feuille de
  détail), supprimer une routine (appui long), modifier son prénom (carte
  profil).
- **Les chiffres de la maquette étaient figés** (série 24, record 31, 82 %,
  435/600, tendances écrites d'avance). Ils sont tous calculés. Une installation
  neuve démarre donc à zéro, avec deux routines d'exemple pour ne pas ouvrir sur
  un écran vide.
- **« Bilan hebdomadaire »** est retiré du profil : la ligne ouvrait un ailleurs
  qui n'existe pas.
