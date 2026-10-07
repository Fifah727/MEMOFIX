import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'patternLockScreen.dart';

class EnterRecoveryCodeScreen extends StatefulWidget {
  const EnterRecoveryCodeScreen({super.key});

  @override
  State<EnterRecoveryCodeScreen> createState() =>
      _EnterRecoveryCodeScreenState();
}

class _EnterRecoveryCodeScreenState extends State<EnterRecoveryCodeScreen> {
  final storage = const FlutterSecureStorage();
  final controller = TextEditingController();
  bool verified = false;

  Future<void> _verifyCode() async {
    final savedCode = await storage.read(key: 'recovery_code');
    if (controller.text.trim() == savedCode) {
      Fluttertoast.showToast(msg: "Code correct");
      setState(() => verified = true);
      await storage.delete(key: 'recovery_code'); // Nettoyer après usage
    } else {
      Fluttertoast.showToast(msg: "Code incorrect");
    }
  }

  Future<void> _resetPatternOrEmail() async {
    // Supprimer le motif
    await storage.delete(key: 'pattern_code');

    // Supprimer le code de récupération si existant
    await storage.delete(key: 'recovery_code');

    Fluttertoast.showToast(
      msg: "Schéma et email réinitialisés. Vous pouvez en définir un nouveau.",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatternLockScreen(isSetupMode: true),
      ),
    );
  }

  Future<void> _resendCode() async {
    Navigator.pushReplacementNamed(context, "/forgot");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entrer le code reçu")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Veuillez entrer le code reçu par email :",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Code à 6 chiffres",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _verifyCode,
              child: const Text("Vérifier le code"),
            ),
            const SizedBox(height: 20),
            if (verified)
              ElevatedButton.icon(
                onPressed: _resetPatternOrEmail,
                icon: const Icon(Icons.lock_open),
                label: const Text("Redéfinir le schéma"),
              )
            else
              ElevatedButton.icon(
                onPressed: _resendCode,
                icon: const Icon(Icons.restore_rounded),
                label: const Text("Renvoyer le code"),
              ),
          ],
        ),
      ),
    );
  }
}
