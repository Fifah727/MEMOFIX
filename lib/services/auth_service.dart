import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Authentification locale (biométrie / code de l'appareil).
class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Biométrie uniquement (empreinte / visage).
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      return await _auth.authenticate(
        localizedReason: 'Déverrouiller MemoFix',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Biométrie OU code / schéma / mot de passe de verrouillage du téléphone.
  /// Retourne `false` si l'appareil n'a aucun verrouillage configuré.
  Future<bool> authenticateWithDeviceCredentials({
    String reason = 'Confirmez votre identité',
  }) async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
