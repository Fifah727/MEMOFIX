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