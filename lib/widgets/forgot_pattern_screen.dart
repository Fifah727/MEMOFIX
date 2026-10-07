import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:memofix/services/auth_service.dart';

import 'pattern_lock_screen.dart';

/// Réinitialisation du motif.
///
/// L'identité est confirmée par le verrouillage du téléphone (biométrie ou
/// code), jamais par un email : l'app est 100 % locale et ne doit embarquer
/// aucun identifiant de messagerie.
class ForgotPatternScreen extends StatefulWidget {
  const ForgotPatternScreen({super.key});

  @override
  State<ForgotPatternScreen> createState() => _ForgotPatternScreenState();
}

class _ForgotPatternScreenState extends State<ForgotPatternScreen> {
  final _storage = const FlutterSecureStorage();
  final _auth = AuthService();
  bool _isLoading = false;

  Future<void> _verifyAndReset() async {
    setState(() => _isLoading = true);
    try {
      final ok = await _auth.authenticateWithDeviceCredentials(
        reason: 'Confirmez votre identité pour redéfinir le motif',
      );
      if (!mounted) return;

      if (!ok) {
        Fluttertoast.showToast(
          msg:
              'Vérification impossible. Un verrouillage (code, schéma ou '
              'biométrie) doit être activé sur le téléphone.',
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      await _storage.delete(key: 'pattern_code');
      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Motif réinitialisé. Définissez-en un nouveau.',
        gravity: ToastGravity.CENTER,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PatternLockScreen(isSetupMode: true),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motif oublié')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'Confirmez votre identité avec le verrouillage de votre '
                'téléphone pour redéfinir votre motif.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _verifyAndReset,
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Vérifier mon identité'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
