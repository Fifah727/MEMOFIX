import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Langues disponibles
  final List<String> _languages = ['Français', 'English', 'Malagasy'];

  // États des paramètres
  String _selectedLanguage = 'Français';
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Préférences générales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // Choix de la langue
          ListTile(
            title: const Text('Langue'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: _languages
                  .map(
                    (lang) => DropdownMenuItem(value: lang, child: Text(lang)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  // TODO : Implémenter la modification réelle de langue dans l'app
                }
              },
            ),
          ),

          // Choix du thème clair/sombre
          SwitchListTile(
            title: const Text('Mode sombre'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // TODO : Appliquer le thème dans l'app via un state management global
            },
          ),

          // Notifications activées ou non
          SwitchListTile(
            title: const Text('Activer les notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // TODO : Gérer l’état des notifications ici
            },
          ),

          const Divider(height: 32),

          const Text(
            'Sécurité',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Changer le mot de passe'),
            onTap: () {
              // TODO : Ajouter navigation vers écran changement mot de passe
            },
          ),

          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Configurer la biométrie'),
            onTap: () {
              // TODO : Ajouter gestion biométrie
            },
          ),
        ],
      ),
    );
  }
}
