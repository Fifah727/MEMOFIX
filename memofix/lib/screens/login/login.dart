import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  final Function(int) onChangedStep;
  const Login({super.key, required this.onChangedStep});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _nom = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slogan stylisé
                RichText(
                  text: TextSpan(
                    text: "Get up\n".toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "rise and shine".toUpperCase(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  "Be better today",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 50.0),

                // Formulaire
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Quel est votre nom ?",
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        onChanged: (value) => setState(() => _nom = value),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? "Veuillez entrer un nom"
                            : null,
                        decoration: InputDecoration(
                          hintText: "Ex : morning@sunrise",
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      // Bouton animé
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _nom.isEmpty ? 0.5 : 1.0,
                        child: ElevatedButton.icon(
                          onPressed: _nom.isEmpty
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    widget.onChangedStep(1);
                                  }
                                },
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text(
                            "Continuer",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
