Voici un **guide complet étape par étape** pour **créer le projet Flutter `MemoFix`**, avec tout le setup initial (architecture, dépendances, configuration sécurité/audio/base de données, etc.).

---

## 🧱 Étape 1 — Créer le projet Flutter

```bash
flutter create memofix
cd memofix
```

Tu obtiendras la structure classique.

---

## 🧼 Étape 2 — Nettoyer le projet

Supprime les fichiers inutiles :

```bash
rm -rf lib/main.dart test/*
```

---

## 📁 Étape 3 — Créer l'arborescence

Dans `lib/`, crée les dossiers suivants :

```
lib/
├── main.dart
├── core/               # Thèmes, constantes, helpers
├── models/             # MemoModel, BugIRLModel
├── services/           # Audio, stockage, sécurité
├── db/                 # Hive ou Drift
├── screens/
│   ├── home/
│   ├── memo/
│   ├── fixme/
│   ├── settings/
├── widgets/            # Composants réutilisables
└── utils/              # Formatters, helpers
```

Tu peux le faire manuellement ou via terminal :

```bash
mkdir -p lib/{core,models,services,db,screens/{home,memo,fixme,settings},widgets,utils}
```

---

## 📦 Étape 4 — Configurer `pubspec.yaml`

Remplace ton `dependencies:` par ceci :

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1

  # Base de données locale
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1

  # Sécurité
  local_auth: ^2.1.6
  flutter_secure_storage: ^9.0.0

  # Notifications
  flutter_local_notifications: ^16.3.2
  timezone: ^0.9.2

  # Audio
  record: ^5.0.1
  just_audio: ^0.9.36

  # UI
  fl_chart: ^0.66.2
  cupertino_icons: ^1.0.6
```

Et ajoute dans `dev_dependencies:` pour Hive :

```yaml
dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

Puis exécute :

```bash
flutter pub get
```

---

## 🔌 Étape 5 — Initialiser Hive

Dans `lib/db/hive_setup.dart` :

```dart
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  // Hive.registerAdapter(MemoAdapter()); // à faire après création des modèles
}
```

Dans `main.dart` :

```dart
import 'package:flutter/material.dart';
import 'db/hive_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const MemoFixApp());
}

class MemoFixApp extends StatelessWidget {
  const MemoFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoFix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Placeholder(), // écran de démarrage provisoire
    );
  }
}
```

---

## 🔒 Étape 6 — Setup sécurité (biométrie)

Crée un service `lib/services/auth_service.dart` :

```dart
import 'package:local_auth/local_auth.dart';

class AuthService {
  final _auth = LocalAuthentication();

  Future<bool> authenticateWithBiometrics() async {
    bool canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return false;
    return await _auth.authenticate(
      localizedReason: 'Déverrouiller MemoFix',
      options: const AuthenticationOptions(
        biometricOnly: true,
      ),
    );
  }
}
```

---

## 🎤 Étape 7 — Setup enregistrement audio

Crée `lib/services/audio_service.dart` :

```dart
import 'package:record/record.dart';

class AudioService {
  final Record _recorder = Record();

  Future<void> startRecording(String path) async {
    if (await _recorder.hasPermission()) {
      await _recorder.start(path: path);
    }
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
  }

  Future<bool> isRecording() => _recorder.isRecording();
}
```

---

## 📝 Étape 8 — Créer les modèles Hive

Exemple pour `Memo` dans `lib/models/memo.dart` :

```dart
import 'package:hive/hive.dart';

part 'memo.g.dart';

@HiveType(typeId: 0)
class Memo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime createdAt;

  Memo({required this.title, required this.content, required this.createdAt});
}
```

Puis :

```bash
flutter pub run build_runner build
```

---

## 🏁 Étape 9 — Lancer un écran de test

Dans `main.dart`, teste la base Hive :

```dart
class MemoFixApp extends StatelessWidget {
  const MemoFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoFix',
      home: Scaffold(
        appBar: AppBar(title: const Text("Test MemoFix")),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final box = await Hive.openBox('memos');
              await box.put('example', 'Hello MemoFix!');
              print(box.get('example'));
            },
            child: const Text("Test Hive"),
          ),
        ),
      ),
    );
  }
}
```

---

## 📍 Prochaine étape ?

Souhaites-tu que je t’aide à :

1. Créer **l'écran des mémos (UI + CRUD)** ?
2. Intégrer **le module "FixMe"** ?
3. Gérer **la sécurité (verrouillage app ou notes)** ?
4. Ajouter **le système de rappels/notifications** ?

Tu peux choisir ce que tu veux faire maintenant.
