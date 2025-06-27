Voici comment **exécuter ton projet Flutter sur un simulateur mobile** (Android ou iOS), étape par étape :

---

## 📱 1. Simulateur Android

### 🔧 A. Pré-requis

✔️ Installe [Android Studio](https://developer.android.com/studio)
✔️ Assure-toi d’avoir :

* Flutter SDK configuré
* Java JDK installé
* Android Emulator + SDK installé

### ✅ B. Vérification rapide

Dans un terminal, exécute :

```bash
flutter doctor
```

Tu dois voir **✓ Flutter, ✓ Android toolchain, ✓ Android Studio**
S’il y a des "X", suis les instructions pour corriger.

---

### ▶️ C. Lancer un simulateur Android

1. Ouvre **Android Studio**
2. En haut, clique **"More Actions" → AVD Manager**
3. Clique **"Create Virtual Device"** (si aucun appareil n’est là)
4. Choisis un modèle (Pixel, etc.), installe un système (API 30+)
5. Clique **"Play"** ▶️ à côté de l'appareil → il démarre

> 💡 Tu peux aussi le lancer via terminal :

```bash
emulator -list-avds               # Liste les simulateurs
emulator -avd NOM_DU_SIMULATEUR   # Lance celui choisi
```

---

### 🚀 D. Exécuter ton app

Va dans ton dossier de projet, puis :

```bash
flutter run
```

Tu verras :

```text
Launching lib/main.dart on Pixel_4_API_30 in debug mode...
```

Ton app se lance dans le simulateur.

---

## 🍎 2. Simulateur iOS (macOS uniquement)

### 🔧 A. Pré-requis

* Mac obligatoire
* Xcode installé (via App Store)
* Flutter installé avec `flutter doctor`

### ▶️ B. Lancer le simulateur iOS

```bash
open -a Simulator
```

Puis :

```bash
flutter run
```

---

## 🧠 Astuces

| Astuce                       | Commande / Info                 |
| ---------------------------- | ------------------------------- |
| Lister les appareils dispos  | `flutter devices`               |
| Choisir un device spécifique | `flutter run -d NOM_DEVICE`     |
| Hot Reload                   | Appuie sur `r` dans le terminal |
| Hot Restart                  | Appuie sur `R` (majuscule)      |
| Fermer app (CTRL+C)          | Interrompt le run dans terminal |

---

Souhaites-tu que je t’aide à configurer Android Studio + AVD, ou VSCode + simulateur ?
