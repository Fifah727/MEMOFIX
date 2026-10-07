/// Configuration injectée à la compilation via `--dart-define`.
///
/// Aucun secret ne doit être écrit dans le code source ni commité.
///
/// Exemple :
/// ```
/// flutter run \
///   --dart-define=SPOTIFY_CLIENT_ID=xxx \
///   --dart-define=SPOTIFY_CLIENT_SECRET=yyy
/// ```
///
/// ⚠️ Une valeur passée par `--dart-define` est embarquée dans l'APK et donc
/// extractible. Cela évite seulement de la publier dans Git. Pour un vrai
/// secret (Spotify client secret), il faut passer par un petit backend/proxy.
class AppConfig {
  const AppConfig._();

  static const String spotifyClientId = String.fromEnvironment(
    'SPOTIFY_CLIENT_ID',
  );
  static const String spotifyClientSecret = String.fromEnvironment(
    'SPOTIFY_CLIENT_SECRET',
  );

  static bool get hasSpotifyCredentials =>
      spotifyClientId.isNotEmpty && spotifyClientSecret.isNotEmpty;
}
