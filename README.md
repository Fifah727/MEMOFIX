<div align="center">

# 📝 MemoFix

**Notes, mémos audio et suivi de « bugs IRL » — 100 % local, protégé par motif.**

[![CI](https://github.com/Fifah727/memofix/actions/workflows/ci.yml/badge.svg)](https://github.com/Fifah727/memofix/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.8+-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Android-iOS-3DDC84?logo=android&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## Sommaire

- [Présentation](#présentation)
- [Fonctionnalités](#fonctionnalités)
- [Captures d'écran](#captures-décran)
- [Stack technique](#stack-technique)
- [Démarrage rapide](#démarrage-rapide)
- [Configuration](#configuration)
- [Structure du projet](#structure-du-projet)
- [Qualité et tests](#qualité-et-tests)
- [CI/CD et releases](#cicd-et-releases)
- [Sécurité et confidentialité](#sécurité-et-confidentialité)
- [Feuille de route](#feuille-de-route)
- [Contribuer](#contribuer)
- [Licence](#licence)

## Présentation

MemoFix est une application mobile Flutter pour organiser ses idées et ses problèmes du quotidien.
Toutes les données restent **sur l'appareil** (SQLite) : aucun compte, aucun serveur, aucune synchronisation.

## Fonctionnalités

| Module                   | Description                                                                                                                                               |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 🗒️ **Mémos**             | Notes par catégorie, listes de tâches, images, enregistrements audio.                                                                                     |
| 🔒 **Mémos verrouillés** | Accès protégé par un motif à tracer.                                                                                                                      |
| 🐞 **FixMe**             | Suivi de « bugs IRL » : description, cause, impact, deadline, plan d'action, avancement en %. Détails : [`docs/modules/fixme.md`](docs/modules/fixme.md). |
| 🔑 **Motif oublié**      | Réinitialisation après confirmation par le verrouillage du téléphone (biométrie ou code).                                                                 |
| 🎵 **Musique**           | Récupération des métadonnées d'un lien Spotify et téléchargement d'un fichier audio. _Optionnel, nécessite une configuration (voir plus bas)._            |
| 🌗 **Thèmes**            | Mode clair et sombre, suivant le système.                                                                                                                 |

## Captures d'écran

> _À ajouter : placez vos images dans `docs/screenshots/` puis référencez-les ici._

<!--
| Accueil | Mémos | FixMe | Verrouillage |
|---------|-------|-------|--------------|
| ![](docs/screenshots/home.png) | ![](docs/screenshots/memos.png) | ![](docs/screenshots/fixme.png) | ![](docs/screenshots/lock.png) |
-->

## Stack technique

| Domaine              | Packages                                                                              |
| -------------------- | ------------------------------------------------------------------------------------- |
| Données              | `sqflite`, `path_provider`, `path`                                                    |
| Sécurité             | `flutter_secure_storage`, `local_auth`                                                |
| Audio                | `record`, `just_audio`                                                                |
| Médias & permissions | `image_picker`, `photo_view`, `permission_handler`                                    |
| Réseau               | `dio`, `http`                                                                         |
| Interface            | `google_fonts`, `lottie`, `line_icons`, `fluttertoast`, `flutter_staggered_grid_view` |

Versions exactes : [`pubspec.yaml`](pubspec.yaml) et `pubspec.lock`.

## Démarrage rapide

**Prérequis** : Flutter stable (Dart ≥ 3.8.1), SDK Android, JDK 17.

```bash
git clone https://github.com/Fifah727/memofix.git
cd memofix
flutter pub get
flutter run
```

> Les dossiers `android/` et `ios/` doivent être présents. S'ils manquent, restaurez-les
> depuis votre projet d'origine (en conservant le même `applicationId`).

### Sans installer Android Studio ni Visual Studio

Visual Studio n'est nécessaire que pour la cible Windows desktop, pas pour Android.
Pour ne rien installer en local, laissez GitHub compiler :

1. Poussez le code sur GitHub.
2. Onglet **Actions → CI → Run workflow** (ou simplement un push).
3. Une fois le job terminé, téléchargez l'artefact **memofix-debug-apk** et installez-le sur votre téléphone.

Les logs de `flutter analyze` et `flutter test` y sont aussi disponibles.

## Configuration

L'application fonctionne sans configuration. Seul le module **Musique** a besoin d'identifiants Spotify.
Ils ne sont **jamais** écrits dans le code : ils sont injectés à la compilation.

```bash
flutter run \
  --dart-define=SPOTIFY_CLIENT_ID=votre_client_id \
  --dart-define=SPOTIFY_CLIENT_SECRET=votre_client_secret
```

| Variable                | Rôle                                           |
| ----------------------- | ---------------------------------------------- |
| `SPOTIFY_CLIENT_ID`     | Identifiant de l'application Spotify Developer |
| `SPOTIFY_CLIENT_SECRET` | Secret associé                                 |

> ⚠️ Une valeur `--dart-define` est embarquée dans l'APK et donc extractible. Pour une
> distribution publique, passez par un petit backend/proxy. Voir [`docs/AUDIT.md`](docs/AUDIT.md).

Sans ces variables, le module affiche simplement une erreur de configuration.

## Structure du projet

```text
lib/
├── core/config/        Configuration injectée (--dart-define)
├── db/                 Ouverture de la base SQLite
├── models/             Modèles de données
├── screens/
│   ├── home_screen.dart
│   ├── memos/          Mémos
│   ├── fixme/          Suivi de bugs
│   └── spotify_download/
├── services/           Accès aux données (queries) et services (auth, audio)
├── theme/              Couleurs
└── widgets/            Composants, écrans de verrouillage
assets/                 animations/ · images/ · db/ (base vierge) · icon/
docs/                   Audit, feuille de route, spécifications
test/                   Tests unitaires
```

La cible d'architecture (organisation par fonctionnalité) est décrite dans [`docs/AUDIT.md`](docs/AUDIT.md).

## Qualité et tests

```bash
dart format .          # formatage
flutter analyze        # analyse statique (règles : analysis_options.yaml)
flutter test           # tests unitaires
```

## CI/CD et releases

| Workflow                                       | Déclencheur                   | Actions                                                                 |
| ---------------------------------------------- | ----------------------------- | ----------------------------------------------------------------------- |
| [`ci.yml`](.github/workflows/ci.yml)           | push sur `main`, pull request | format, analyse, tests, scan de secrets (gitleaks), build Android debug |
| [`release.yml`](.github/workflows/release.yml) | tag `vX.Y.Z`                  | build signé APK + AAB, publication d'une GitHub Release                 |

**Mettre en place une release**

1. Dans _Settings → Secrets and variables → Actions_, créer :
   `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`
   (+ `SPOTIFY_CLIENT_ID` et `SPOTIFY_CLIENT_SECRET` si le module Musique est utilisé).
2. Encoder le keystore : `base64 -w0 upload-keystore.jks` (Linux) ou `base64 -i upload-keystore.jks` (macOS).
3. Vérifier que `android/app/build.gradle(.kts)` lit `android/key.properties`
   ([guide Flutter](https://docs.flutter.dev/deployment/android#sign-the-app)).
4. Publier :

   ```bash
   git tag v1.0.1 && git push origin v1.0.1
   ```

Utilisez la **même clé de signature** que l'application déjà publiée, sinon les mises à jour seront refusées.

## Sécurité et confidentialité

- Données stockées localement ; aucune donnée envoyée à un serveur par l'application, hormis le module Musique (API Spotify et URL de téléchargement saisie par l'utilisateur).
- Aucun secret dans le dépôt ; scan automatique des secrets à chaque push.
- Signalement de vulnérabilité : voir [`SECURITY.md`](SECURITY.md).
- État du durcissement (motif haché, base chiffrée, etc.) : voir [`docs/AUDIT.md`](docs/AUDIT.md).

## Feuille de route

- [ ] Hash salé du motif et limitation des essais
- [ ] Chiffrement de la base SQLite (SQLCipher)
- [ ] Découpage des gros écrans en widgets
- [ ] Couche repository et gestion d'état unifiée
- [ ] Schéma SQL versionné (migrations)
- [ ] Polices embarquées (suppression du téléchargement à l'exécution)
- [ ] Tests de repositories et de widgets

## Contribuer

1. Créez une branche : `git checkout -b feat/ma-fonctionnalite`
2. Avant de pousser : `dart format . && flutter analyze && flutter test`
3. Ouvrez une pull request ; la CI doit être verte.

Messages de commit recommandés : [Conventional Commits](https://www.conventionalcommits.org/fr/) (`feat:`, `fix:`, `chore:`…).

## Licence

Distribué sous licence [MIT](LICENSE).
