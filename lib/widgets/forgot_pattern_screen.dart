import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'enter_recovery_code_screen.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ForgotPatternScreen extends StatefulWidget {
  const ForgotPatternScreen({super.key});

  @override
  State<ForgotPatternScreen> createState() => _ForgotPatternScreenState();
}

class _ForgotPatternScreenState extends State<ForgotPatternScreen> {
  final storage = const FlutterSecureStorage();
  bool isLoading = false;
  String? recoveryEmail;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final email = await storage.read(key: 'recovery_email');
    setState(() {
      recoveryEmail = email;
    });
  }

  Future<void> _sendRecoveryEmail() async {
    if (recoveryEmail == null || recoveryEmail!.isEmpty) {
      Fluttertoast.showToast(
        msg: "Aucun email de récupération trouvé.",
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    setState(() => isLoading = true);

    final code = (100000 + Random().nextInt(900000)).toString();

    try {
      // Sauvegarde du code localement
      await storage.write(key: 'recovery_code', value: code);

      // SMTP Gmail - mot de passe d'application nécessaire
      final smtpServer = gmail(
        'ssarobidyfifaliana@gmail.com',
        'uhif kosn igvo pfns', // mot de passe d'application
      );

      final message = Message()
        ..from = Address('ssarobidyfifaliana@gmail.com', 'MemoFix-Build')
        ..recipients.add(recoveryEmail!)
        ..subject = 'Code de récupération MemoFix'
        ..text =
            'Bonjour,\n\nVoici votre code de récupération : $code\n\nMemoFix';

      await send(message, smtpServer);

      Fluttertoast.showToast(
        msg: "Email envoyé à $recoveryEmail",
        gravity: ToastGravity.CENTER,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EnterRecoveryCodeScreen()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg:
            "Erreur envoi email : Vérifiez votre connexion ou votre adresse email",
        gravity: ToastGravity.CENTER,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mot de passe oublié")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Nous allons envoyer un code à votre adresse :",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              recoveryEmail == null
                  ? const CircularProgressIndicator()
                  : Text(
                      recoveryEmail ?? 'Chargement…',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: recoveryEmail == null
                          ? null
                          : _sendRecoveryEmail,
                      icon: const Icon(Icons.send),
                      label: const Text("Envoyer le code"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
