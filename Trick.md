| Ancien nom    | Nouveau nom       |
| ------------- | ----------------- |
| headline1     | displayLarge      |
| headline2     | displayMedium     |
| headline3     | displaySmall      |
| headline4     | headlineLarge     |
| **headline5** | **headlineSmall** |
| headline6     | titleLarge        |
| subtitle1     | titleMedium       |
| subtitle2     | titleSmall        |
| bodyText1     | bodyLarge         |
| bodyText2     | bodyMedium        |


| 🧱 **Ancien widget / méthode (déprécié)**       | ✅ **Nouveau recommandé**                                 | 💬 **Remarques**                                                       |
| ----------------------------------------------- | -------------------------------------------------------- | ---------------------------------------------------------------------- |
| `RaisedButton`                                  | `ElevatedButton`                                         | Bouton avec ombre et élévation                                         |
| `FlatButton`                                    | `TextButton`                                             | Bouton sans ombre                                                      |
| `OutlineButton`                                 | `OutlinedButton`                                         | Bouton avec bordure                                                    |
| `ButtonTheme`                                   | `ElevatedButtonTheme`, `TextButtonTheme`, etc.           | Nouveau système de theming                                             |
| `AppBar.actionsIconTheme`                       | `AppBar.actions.iconTheme`                               | Accès via la hiérarchie `actions`                                      |
| `showModalBottomSheet` avec `builder`           | Ajoute `useSafeArea: true` ou `isScrollControlled: true` | Pour éviter le débordement sur clavier                                 |
| `accentColor`                                   | `colorScheme.secondary`                                  | Gère la couleur secondaire dans le thème                               |
| `primaryColorBrightness`                        | `colorScheme.brightness`                                 | Utilise `Brightness.light` ou `Brightness.dark`                        |
| `ThemeData.buttonColor`                         | Supprimé (géré via ButtonTheme ou `ButtonStyle`)         | Personnalise chaque type de bouton individuellement                    |
| `TextTheme.body1`, `body2`                      | `bodyLarge`, `bodyMedium`, `bodySmall`                   | Nouvelle hiérarchie plus claire                                        |
| `TextTheme.subtitle1`, `subtitle2`              | `titleMedium`, `titleSmall`                              | Renommage pour plus de cohérence                                       |
| `Navigator.pop(context, result)`                | inchangé                                                 | Toujours d'actualité                                                   |
| `showDialog(..., child: ...)`                   | `builder: (context) => ...`                              | Le paramètre `child` est déprécié                                      |
| `AppBar.brightness`                             | Géré via `systemOverlayStyle`                            | Pour gérer la couleur des icônes dans la barre de statut               |
| `showDatePicker(...)`                           | inchangé mais thème personnalisable via `theme`          | Utilise `ThemeData` pour styliser                                      |
| `TextField.decoration.collapsed(hintText: ...)` | `InputDecoration.collapsed(hintText: ...)`               | Toujours d’actualité mais renommé                                      |
| `CupertinoPageScaffold.navigationBar`           | `CupertinoNavigationBar`                                 | Même widget, mais parfois utilisé autrement avec `SliverNavigationBar` |
| Ancien (ou Flutter mobile-only) | Nouveau pour Web/Desktop      | Remarques                        |
| ------------------------------- | ----------------------------- | -------------------------------- |
| `GestureDetector` pour clic     | `InkWell`, `MouseRegion`      | Pour gestion du survol           |
| `AlertDialog`                   | `Dialog`, `Dialog.fullscreen` | Meilleure adaptation sur desktop |
Bien sûr ! Voici un résumé clair et compact des types et modificateurs en Dart :

---

## Types de variables en Dart - Résumé

### 1. Types de base (primitifs)

* `int` : nombres entiers
* `double` : nombres à virgule flottante
* `num` : parent de `int` et `double`
* `bool` : vrai/faux
* `String` : texte
* `null` : valeur nulle (avec null safety)

### 2. Collections

* `List<T>` : liste ordonnée
* `Set<T>` : ensemble unique
* `Map<K, V>` : clé-valeur

### 3. Types spéciaux importants

* `Duration` : durée (ex: 5 secondes)
* `DateTime` : date et heure
* `Future<T>` : valeur asynchrone
* `Stream<T>` : flux asynchrone

### 4. Modificateurs et mots-clés

* `var` : type inféré automatiquement
* `dynamic` : type flexible, sans vérification de type
* `final` : variable assignée une fois (immutable runtime)
* `const` : constante connue à la compilation
* `late` : initialisation différée d’une variable non-nullable

### 5. Null safety

* Types non-nullables par défaut (`int a = 5;`)
* Types nullable avec `?` (`int? a = null;`)


| Fonction                                          | Description                                        |
| ------------------------------------------------- | -------------------------------------------------- |
| `Navigator.push(context, MaterialPageRoute(builder: (context) => Setting()))` | Va à un nouvel écran                               |
| `Navigator.pop(context)`                          | Revient à l’écran précédent                        |
| `Navigator.pushReplacement(...)`                  | Remplace l’écran actuel                            |
| `Navigator.pushAndRemoveUntil(...)`               | Supprime les écrans précédents selon une condition |
