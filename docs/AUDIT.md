# Audit MemoFix & feuille de route

Audit réalisé sur l'archive `memofix.zip` (35 fichiers Dart, ≈ 10 500 lignes).
Statut : ✅ corrigé dans cette version · ⏳ à faire.

## 1. Bloquants avant publication

| # | Constat | Statut |
|---|---------|--------|
| 1 | **Mot de passe d'application Gmail en dur** (`forgot_pattern_screen.dart`), embarqué dans chaque APK déjà distribué. | ✅ code retiré · ⏳ **révoquer le mot de passe** (compte Google → Mots de passe d'application) |
| 2 | **Client ID + Client Secret Spotify en dur** (`affiche_song.dart`). | ✅ code retiré (`--dart-define`) · ⏳ **régénérer le secret** (Spotify Developer Dashboard) |
| 3 | Imports avec une **casse erronée** (`TacheItem.dart`, `FixMeItems.dart` alors que les fichiers s'appelaient `tacheItem.dart`, `FixmeItems.dart`). Ça passe sous Windows, **échoue sur Linux (CI)**. | ✅ |
| 4 | `home_screen.dart` importait `../../widgets/…` (hors de `lib/`) : ne compilait pas. | ✅ |
| 5 | `android/` et `ios/` absents de l'archive : la CI ne peut pas construire l'app. | ⏳ restaurer depuis le projet d'origine (garder le même `applicationId`) |
| 6 | Les secrets restent dans l'**historique Git** s'ils ont été poussés. | ⏳ `git filter-repo --replace-text` (ou BFG), puis force-push ; ou repartir d'un dépôt neuf |

## 2. Sécurité

- ✅ **Récupération par email supprimée** : le code était stocké localement et envoyé via un compte
  Gmail partagé embarqué dans l'app (aucune sécurité réelle). Remplacée par une
  réauthentification via le verrouillage du téléphone (`local_auth`).
- ⏳ **Motif stocké en clair** (`pattern.join(',')` dans le secure storage) → stocker un hash
  salé (PBKDF2/Argon2, ex. package `cryptography`) et comparer en temps constant.
- ⏳ **Aucune limitation d'essais** sur le motif → verrouillage progressif (30 s, 1 min, 5 min…).
- ⏳ **Base SQLite non chiffrée** → `sqflite_sqlcipher` avec clé générée et gardée dans
  `flutter_secure_storage`. Sinon un mémo « verrouillé » reste lisible hors de l'app (appareil rooté, backup).
- ⏳ Vérifier `android:allowBackup="false"` (ou règles de backup) dans `AndroidManifest.xml`.
- ⏳ Module musique : `Permission.storage` + écriture dans `/storage/emulated/0/Download` ne
  fonctionnent plus correctement depuis Android 13 et posent problème au Play Store → MediaStore / SAF.
  Valider aussi l'URL téléchargée (https uniquement, taille et type maximum).
- ⏳ Le client secret Spotify, même en `--dart-define`, reste **extractible de l'APK** : utiliser un proxy
  (fonction serverless) ou le endpoint public oEmbed (sans secret).
- ⏳ `google_fonts` télécharge la police à l'exécution : embarquer Raleway dans `assets/fonts/`.

## 3. Architecture (état actuel → cible)

Constats :
- **Fichiers monolithiques** : `add_memo_plus.dart` 1 617 lignes, `bug_detail_screen.dart` 1 503,
  `memo_screen.dart` 1 181, `home_screen.dart` 827.
- UI → services → SQL directement, sans couche repository ni état centralisé (`setState` partout).
- Navigation par routes nommées en `String` (`'/lock-false'`, `'/screen-deverouiller'`…).
- Modèles mutables, champs en `snake_case` (`id_memo`, `nom_img`), `fromMap/toMap` seulement sur certains.
- Thème clair/sombre dupliqué (~200 lignes) dans `main.dart`.
- Schéma SQL livré dans un `.db` binaire, sans `version` / `onUpgrade` : toute évolution du schéma est impossible
  proprement.
- Code commenté et paramètres morts (ex. `correctPattern` de `SchemaScreen`, ignoré).

Structure cible (par fonctionnalité) :

```
lib/
  main.dart / app.dart
  core/        config, theme, router, utils, errors
  data/        database (schéma versionné), repositories
  features/
    memos/     data · domain · presentation (screens, widgets, providers)
    fixme/
    lock/      motif, biométrie, réinitialisation
    music/     métadonnées + téléchargement
```

Ordre conseillé :
1. **P0** Révoquer/rotater les secrets, purger l'historique, restaurer `android/`.
2. **P1** Premier run de la CI (`dart format .`, corriger les warnings remontés).
3. **P2** Durcissement : hash du motif, limitation d'essais, SQLCipher.
4. **P3** Découper les 4 gros fichiers en widgets (sans changer le comportement).
5. **P4** Couche repository + gestion d'état (Riverpod **ou** `ChangeNotifier`, un seul choix), `go_router` si besoin.
6. **P5** Schéma SQL versionné (`onCreate/onUpgrade`) ; tests de repositories (`sqflite_common_ffi`).

## 4. Nettoyage effectué

- Supprimés : copie de sauvegarde `addMemoPlus new.md` (54 Ko, dans `lib/`), `memo.dart`/`memo.g.dart` (Hive jamais utilisé),
  `desktop.ini`, `memofix.iml`, `.flutter-plugins-dependencies`, fichier parasite
  `_buildBugCard(bug)).toList()`, dossiers vides (`core`, `utils`, `objectifs`, `profil`, `widgets/fixme`).
- Assets : 9 fichiers inutilisés retirés (dont `secret-4.html` 1,9 Mo + ses ~450 fichiers, page web enregistrée) ;
  seuls les assets référencés sont déclarés dans `pubspec.yaml` ; réorganisés en `animations/ images/ db/ icon/`.
- Dépendances retirées (jamais importées) : `flutter_riverpod`, `go_router`, `mailer`, `speech_to_text`,
  `file_picker`, `fl_chart`, `shimmer`, `animated_text_kit`, `animations`, `audio_session`,
  `flutter_local_notifications`, `timezone`, `hive_generator`, `build_runner`.
- 18 fichiers renommés en `snake_case` (règle Dart `file_names`) ; `SPOTIFY_download/` → `spotify_download/`.
- 65 `print` → `debugPrint` ; imports inutiles retirés ; fins de ligne normalisées en LF (`.gitattributes`).
- `pubspec.lock` n'est plus ignoré (à regénérer avec `flutter pub get` puis commiter).

## 5. Dette technique connue (infos de l'analyseur)

- ≈ 86 `withOpacity` (déprécié) → `.withValues(alpha: …)`.
- `ColorScheme.surfaceVariant/background/onBackground` dépréciés dans `main.dart`.
- ≈ 62 `Navigator`/`ScaffoldMessenger` à revoir pour `use_build_context_synchronously` (`if (!mounted) return;`).
- Attributs de modèles en `snake_case` (`id_memo`…) : lint `non_constant_identifier_names`.

## 6. Licence & contenu tiers

- Code : MIT proposée (voir `LICENSE`, **renseigner le nom**). Alternatives : Apache-2.0 (brevets), GPL-3.0 (copyleft),
  ou « tous droits réservés » si le dépôt reste privé.
- ⏳ **Provenance des images** (`assets/images/*`, `work.json` Lottie) : vérifier le droit de les redistribuer
  publiquement (la page enregistrée supprimée contenait des images issues de recherches web).
- ⏳ Télécharger des fichiers audio ou utiliser l'API Spotify implique le respect des conditions de Spotify et du
  droit d'auteur ; à clarifier avant une publication sur le Play Store.
