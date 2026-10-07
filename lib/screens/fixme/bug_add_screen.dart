import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memofix/services/query/fixme/bug_service.dart';
import 'package:memofix/models/fixme/fixme_items.dart';
import 'package:line_icons/line_icons.dart';

class AddBugScreen extends StatefulWidget {
  const AddBugScreen({Key? key}) : super(key: key);

  @override
  State<AddBugScreen> createState() => _AddBugScreenState();
}

class _AddBugScreenState extends State<AddBugScreen> {
  final BugService _bugService = BugService();
  final description = TextEditingController();
  final cause = TextEditingController();
  final impact = TextEditingController();
  final deadline = TextEditingController();
  String? categorie;
  String? icon;

  String? _getIconNameForCategory(String? cat) {
    switch (cat) {
      case 'UI':
        return 'ui';
      case 'Backend':
        return 'backend';
      case 'Performance':
        return 'performance';
      case 'Base de données':
        return 'fix';
      case 'Sécurité':
        return 'warning';
      default:
        return 'bug';
    }
  }

  final List<String> categories = [
    'UI',
    'Backend',
    'Performance',
    'Base de données',
    'Sécurité',
    'Autre',
  ];

  IconData _getIconForCategory(String cat) {
    switch (cat) {
      case 'UI':
        return Icons.design_services_rounded;
      case 'Backend':
        return Icons.developer_mode_rounded;
      case 'Performance':
        return Icons.speed_rounded;
      case 'Base de données':
        return Icons.storage_rounded;
      case 'Sécurité':
        return Icons.lock_rounded;
      default:
        return Icons.bug_report_rounded;
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        deadline.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveBug() async {
    if (description.text.isEmpty || categorie == null || categorie == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir les champs obligatoires.'),
        ),
      );
      return;
    }

    final newBug = BugItem(
      description: description.text,
      cause: cause.text,
      impact: impact.text,
      deadline: DateTime.tryParse(deadline.text),
      statut: 'en_cours',
      date_creation: DateTime.now(),
      date_cloture: null,
      avancement: 0,
      categorie: categorie ?? '',
      icon: _getIconNameForCategory(categorie) ?? 'bug',
    );

    debugPrint('🪲 Bug créé : ${newBug.toMap()}');
    await _bugService.ajouterBug(newBug);

    Navigator.pushReplacementNamed(context, "/bugListe");
  }

  IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'bug':
      case 'bug_report':
        return Icons.bug_report;
      case 'add':
        return Icons.add;
      case 'vie':
        return Icons.person_pin;
      case 'étude':
        return Icons.book;
      case 'fix':
      case 'tools':
        return Icons.build;
      case 'ui':
        return Icons.design_services;
      case 'warning':
        return Icons.warning;
      case 'done':
      case 'check':
        return Icons.check_circle;
      case 'play':
        return Icons.play_arrow;
      case 'info':
        return Icons.info;
      case 'backend':
        return Icons.storage;
      case 'performance':
        return Icons.speed;
      default:
        return Icons.bug_report; // icône par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedCategorie = "UI";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFFFAFAFA),
        title: Text(
          "Nouveau bug",
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            "/bugListe",
          ), // Plus simple et plus efficace
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildInputField(
              controller: description,
              label: "Description",
              icon: Icons.bug_report_rounded,
              maxLines: 4,
              hint: "Décrivez en détails votre problème...",
            ),
            _buildInputField(
              controller: cause,
              label: "Cause",
              icon: Icons.info_outline_rounded,
              maxLines: 2,
              hint: "Donner la cause en question...",
            ),
            _buildInputField(
              controller: impact,
              label: "Impact",
              icon: Icons.warning_amber_rounded,
              maxLines: 2,
              hint: "Racontez l'impact du problème...",
            ),

            _buildDropdownField(
              label: "Catégorie",
              value: selectedCategorie,
              options: categories,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedCategorie = val;
                    categorie = val;
                    icon = val != null
                        ? _getIconForCategory(val).toString()
                        : null;
                  });
                }
              },
              icon: Icons.category_rounded,
            ),

            // 🔹 Deadline picker
            GestureDetector(
              onTap: () => _selectDeadline(context),
              child: AbsorbPointer(
                child: _buildInputField(
                  controller: deadline,
                  label: "Deadline",
                  icon: Icons.calendar_today_rounded,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 Bouton d’enregistrement
            Row(
              children: [
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/bugListe");
                    },
                    label: const Text(
                      "Annuler",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: const Color.fromARGB(135, 121, 121, 121),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.black26,
                    ),
                  ),
                ),
                const Spacer(),
                if (description.text.isNotEmpty &&
                    categorie != null &&
                    categorie != "") ...[
                  _buildBtns(),
                  const SizedBox(height: 15),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String hint = "",
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          alignLabelWithHint: true,
          isDense: true,
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          prefixIcon: Icon(
            icon,
            color: Color.fromARGB(120, 11, 54, 13),
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40, // largeur de l'icône
            minHeight: 40, // force la hauteur à rester visible
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
        ),
      ),
    );
  }

  /// --- Champ dropdown stylé identique à _buildInputField ---
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    final Color accentColor = const Color(0xFF2E7D32); // vert foncé
    final Color bgColor = const Color(0xFFF9F9F9); // blanc cassé

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          labelStyle: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: bgColor, // blanc cassé
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 15,
              color: const Color.fromARGB(120, 11, 54, 13), // vert foncé
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0, // réduire pour le container
            horizontal: 16,
          ),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            filled: false,
            border: InputBorder.none, // pas de bordure
            enabledBorder: InputBorder.none, // pas de bordure quand activé
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            focusedBorder: InputBorder.none,
          ),
          dropdownColor: Colors.white, // fond de la liste déroulante
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          items: options.map((String option) {
            return DropdownMenuItem<String>(value: option, child: Text(option));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBtns() {
    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: Colors.black26, // légère ombre
          ),
          onPressed: _saveBug,
          label: const Text(
            "Enregistrer le bug",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complètez ces informations',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'A propos de votre problème (bug)',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
