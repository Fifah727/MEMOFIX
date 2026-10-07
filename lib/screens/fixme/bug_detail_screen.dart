import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/material.dart';
import 'package:memofix/models/fixme/fixme_items.dart';
import 'package:memofix/services/query/fixme/bug_service.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:intl/intl.dart';

class BugDetailScreen extends StatefulWidget {
  final int id_bug;

  const BugDetailScreen({super.key, required this.id_bug});

  @override
  State<BugDetailScreen> createState() => _BugDetailScreenState();
}

class _BugDetailScreenState extends State<BugDetailScreen> {
  final BugService _bugService = BugService();
  BugItem bug = BugItem(date_creation: DateTime.now());
  List<ObjectifItem> _objectifs = [];
  List<BugProgressItem> _progress = [];

  @override
  void initState() {
    super.initState();
    _loadBug(widget.id_bug);
    _loadDetails();
    _loadCategories();
  }

  List<String> categoriesOptions = [];
  String selectedCategorie = ""; // valeur initiale
  Future<void> _ajouterObjectif() async {
    final valeur = TextEditingController();
    final periode = TextEditingController();

    final ajout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F5F5), // fond doux gris clair
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Ajouter un objectif",
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              TextField(
                maxLines: 5,
                controller: valeur,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Par exemple : Se lever tôt',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  alignLabelWithHint: true,
                  isDense: true,
                  labelText: "Valeur cible",
                  labelStyle: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.star_border_purple500,
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
                ),
              ),
              const SizedBox(height: 20),

              // Champ Date avec picker
              _buildDateField(
                controller: periode,
                label: "Date cible",
                icon: Icons.calendar_today_rounded,
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 133, 133, 133),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (ajout == true) {
      // Création d'un nouvel ObjectifItem
      DateTime selectedDate = DateTime.tryParse(periode.text) ?? DateTime.now();
      DateTime fullDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
      );

      final newObj = ObjectifItem(
        valeur_cible: valeur.text,
        periode: fullDateTime.toIso8601String(),
        id_bug: widget.id_bug,
        date_creation: DateTime.now(),
        statut: "en_cours",
      );

      await _bugService.ajouterObjectif(newObj);
      _loadDetails(); // rafraîchissement de la liste ou UI
      _loadBug(widget.id_bug);
    }
  }

  Future<void> _modifierObjectif(ObjectifItem obj) async {
    if (obj == null) return;

    final valeur = TextEditingController(text: obj.valeur_cible);
    final periode = TextEditingController(
      text: _formatDateOnly(DateTime.tryParse(obj.periode ?? "")),
    );

    final modif = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF5F5F5), // fond doux gris clair
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Modifier l'objectif",
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              // Champ multiligne "Valeur cible"
              TextField(
                maxLines: 5,
                controller: valeur,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Par exemple : Se lever tôt',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  alignLabelWithHint: true,
                  isDense: true,
                  labelText: "Valeur cible",
                  labelStyle: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.star_border_purple500,
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
                ),
              ),
              const SizedBox(height: 20),

              // Champ Date avec picker
              _buildDateField(
                controller: periode,
                label: "Date cible",
                icon: Icons.calendar_today_rounded,
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 133, 133, 133),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (modif == true) {
      obj.valeur_cible = valeur.text;
      obj.periode = periode.text;
      await _bugService.updateObj(obj);
      _loadDetails();
    }
  }

  Future<void> _loadCategories() async {
    final categoriesFromDb = await _bugService.getCategories();
    setState(() {
      categoriesOptions = categoriesFromDb.isNotEmpty
          ? categoriesFromDb
          : ["UX"]; // fallback

      selectedCategorie = bug?.categorie ?? "UX"; // valeur initiale
    });
  }

  Future<void> _loadBug(int bug_id) async {
    final bugDetail = await _bugService.getBug(bug_id);

    setState(() {
      if (bugDetail != null) bug = bugDetail;
    });
  }

  Future<void> _loadDetails() async {
    final objectifs = await _bugService.getObjectifs(widget.id_bug);
    final progress = await _bugService.getProgress(widget.id_bug);

    setState(() {
      _objectifs = objectifs;
      _progress = progress;
    });
  }

  Color _getProgressColor(double progress) {
    // Variante fluide rouge → vert
    progress = progress.clamp(0, 100);
    double t = progress / 100;

    final hsl = HSLColor.fromAHSL(1.0, 0 + (120 * t), 0.75, 0.55);
    return hsl.toColor();
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'corrigé':
        return Colors.green;
      case 'abandonné':
        return Colors.red;
      case 'en_cours':
      default:
        return Colors.orange;
    }
  }

  String _getStatut(String statut) {
    switch (statut) {
      case 'corrigé':
        return "Corrigé";
      case 'abandonné':
        return "Abandonné";
      case 'en_cours':
        return "En cours";
      default:
        return "En cours";
    }
  }

  Widget _buildBugHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: const Border(
          bottom: BorderSide(
            color: Colors.black12, // couleur de la “bordure”
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Bug #${bug.id_bug}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatutColor(bug.statut).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatut(bug.statut),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getStatutColor(bug.statut),
                    ),
                  ),
                ),
              ],
            ),

            if (bug.statut == "corrigé" && bug.date_cloture != null) ...[
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Clôturé : ${_formatDateHeure(bug.date_cloture)}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            Text(
              bug.description,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            if (bug.cause != "" || bug.cause != null) ...[
              _buildInfoRow(Icons.info_outline, "Cause", bug.cause),
              const SizedBox(height: 16),
            ],
            _buildInfoRow(Icons.category_outlined, "Catégorie", bug.categorie),
            const SizedBox(height: 16),
            if (bug.deadline != "" || bug.deadline != null) ...[
              _buildInfoRow(
                Icons.calendar_today_outlined,
                "Deadline",
                _formatDateOnly(bug.deadline),
              ),
            ],
            if (bug.avancement != 0) ...[
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Progression",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Text(
                    "${bug.avancement}%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getProgressColor(bug.avancement.toDouble()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          color: const Color(0xFFF0F0F0),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          width: (bug.avancement / 100) * constraints.maxWidth,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getProgressColor(bug.avancement.toDouble()),
                                _getProgressColor(
                                  bug.avancement.toDouble(),
                                ).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    final months = {
      1: 'JAN',
      2: 'FÉV',
      3: 'MAR',
      4: 'AVR',
      5: 'MAI',
      6: 'JUI',
      7: 'JUL',
      8: 'AOÛ',
      9: 'SEP',
      10: 'OCT',
      11: 'NOV',
      12: 'DÉC',
    };

    return months[month] ?? '$month';
  }

  String _formatDateHeure(DateTime? dt) {
    if (dt == null) return "Aucune date"; // ou "Non définie", selon ton UI

    final now = DateTime.now();
    final diff = now.difference(dt);

    // Format des heures et minutes
    final hourMinute =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (diff.inDays == 0) return "Aujourd’hui à $hourMinute";
    if (diff.inDays == 1) return "Hier à $hourMinute";

    return '${dt.day} ${_getMonth(dt.month)} à $hourMinute';
  }

  String _formatDateOnly(DateTime? dt) {
    if (dt == null) return "Aucune date"; // ou "Non définie", selon ton UI

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) return "Aujourd’hui";
    if (diff.inDays == 1) return "Hier";

    return '${dt.day} ${_getMonth(dt.month)}';
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF999999)),
        const SizedBox(width: 8),
        Text(
          "$label : ",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 66, 66, 66),
          ),
        ),
        const SizedBox(width: 8), // petit espace
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 17, 17, 17),
            ),
            textAlign: TextAlign.right, // texte aligné à droite
            softWrap: true, // autorise retour à la ligne
          ),
        ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: const Border(
          bottom: BorderSide(
            color: Colors.black12, // couleur de la “bordure”
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Plan d'action",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                // boutton plus objectif
                GestureDetector(
                  onTap: () =>
                      _ajouterObjectif(), // appelle la fonction d'ajout
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_objectifs.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: const Text(
                    "Aucun objectif défini",
                    style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                  ),
                ),
              )
            else
              ...List.generate(_objectifs.length, (index) {
                final obj = _objectifs[index];
                final isCompleted = obj.statut == "fait";
                return GestureDetector(
                  onTap: () {
                    // vers BugDetailScreen
                    _modifierObjectif(obj);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFF0F7FF)
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFF0F0F0),
                        width: 1,
                      ),
                    ),
                    child: Dismissible(
                      key: ValueKey(obj),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) async {
                        await _bugService.supprimerObjectif(obj.id_obj);
                        _loadDetails();
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Supprimer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isCompleted,
                            onChanged: (val) async {
                              if (obj.statut == "fait") {
                                return; // ⚡ déjà fait, on ne fait rien
                              }

                              setState(() {
                                obj.statut = val! ? "fait" : "en_cours";
                              });

                              await _bugService.updateObjectifAndBugAvancement(
                                obj,
                              );

                              _loadBug(widget.id_bug);
                              _loadDetails();
                            },

                            activeColor: const Color(0xFF2196F3),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _modifierObjectif(obj),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      obj.valeur_cible,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: const Color(0xFF1A1A1A),
                                        fontWeight: FontWeight.w500,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Échéance : ${_formatDateHeure(DateTime.tryParse(obj.periode))}",
                                      style: const TextStyle(
                                        color: Color(0xFF999999),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: const Border(
          bottom: BorderSide(
            color: Colors.black12, // couleur de la “bordure”
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Progressions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_progress.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: const Text(
                    "Aucun progrès effectué",
                    style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                  ),
                ),
              )
            else
              ...List.generate(_progress.length, (index) {
                final item = _progress[index];
                final isFirst = index == 0;
                return Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2196F3),
                                  const Color(0xFF1976D2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2196F3,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "${item.avancement}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          if (index < _progress.length - 1)
                            Container(
                              width: 2,
                              height: 40,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF2196F3).withOpacity(0.3),
                                    const Color(0xFF2196F3).withOpacity(0.1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.commentaire,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 13,
                                    color: Color(0xFF999999),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${_formatDateHeure(item.date_modif)}",
                                    style: const TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFFFAFAFA),
        title: Text(
          bug.id_bug == 0 ? "Nouveau bug" : 'Détails du Bug',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            "/bugListe",
          ), // Plus simple et plus efficace
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Color.fromARGB(221, 101, 165, 93),
            ),
            tooltip: "Modifier le bug",
            onPressed: () async {
              _showBugForm(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBugHeader(),
            _buildChecklist(),
            _buildHistory(),

            if (bug.avancement == 100) ...[
              const SizedBox(height: 12),
              _buildRelance(),
            ],
            const SizedBox(height: 15),
            _buildSupp(),

            // Center(
            //   child: ElevatedButton.icon(
            //     onPressed: () async {
            //       // action pour refaire le bug
            //       await _bugService.supprimerBug(widget.id_bug);
            //       Navigator.pushReplacementNamed(context, "/bugListe");
            //     },
            //     icon: const Icon(
            //       Icons.delete_forever_sharp,
            //       size: 20,
            //       color: Colors.white,
            //     ),
            //     label: const Text(
            //       "Supprimer ce bug",
            //       style: TextStyle(
            //         fontWeight: FontWeight.w600,
            //         fontSize: 14,
            //         letterSpacing: 0.5,
            //       ),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(
            //         vertical: 14,
            //         horizontal: 40,
            //       ),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(14),
            //       ),
            //       backgroundColor: const Color.fromARGB(255, 218, 85, 85),
            //       foregroundColor: Colors.white,
            //       elevation: 3,
            //       shadowColor: Colors.black26, // légère ombre
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showBugForm(BuildContext context) {
    final theme = Theme.of(context);

    // 🧩 Contrôleurs des champs
    final description = TextEditingController(text: bug?.description ?? "");
    final cause = TextEditingController(text: bug?.cause ?? "");
    final impact = TextEditingController(text: bug?.impact ?? "");
    final deadline = TextEditingController(
      text: bug?.deadline != null
          ? DateFormat('yyyy-MM-dd').format(bug!.deadline!)
          : "",
    );

    final categorie = TextEditingController(text: bug?.categorie ?? "");
    String selectedCategorie = bug?.categorie ?? "UX";
    final icon = TextEditingController(text: bug?.icon ?? "bug_report");
    final statut = TextEditingController(text: bug?.statut ?? "en_cours");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Barre de glissement ---
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 22),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),

                // --- Titre dynamique ---
                Text(
                  bug == null ? "Nouveau Bug" : "Modifier le Bug",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Champs ---
                _buildInputField(
                  controller: description,
                  label: "Description",
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                _buildInputField(
                  controller: cause,
                  label: "Cause",
                  icon: Icons.warning_amber_rounded,
                  maxLines: 2,
                ),
                _buildInputField(
                  controller: impact,
                  label: "Impact",
                  icon: Icons.bolt_rounded,
                  maxLines: 2,
                ),
                _buildDropdownField(
                  label: "Catégorie",
                  value: selectedCategorie,
                  options: categoriesOptions,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedCategorie = val; // met à jour le dropdown
                        categorie.text =
                            val; // synchronise le controller si besoin
                      });
                    }
                  },
                  icon: Icons.category_rounded,
                ),

                _buildDateField(
                  controller: deadline,
                  label: "Deadline (AAAA-MM-JJ)",
                  icon: Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 16),

                // --- Bouton principal ---
                ElevatedButton.icon(
                  onPressed: () async {
                    if (description.text.isEmpty ||
                        cause.text.isEmpty ||
                        impact.text.isEmpty ||
                        categorie.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tous les champs sont obligatoires."),
                        ),
                      );
                      return;
                    }

                    final bugData = BugItem(
                      id_bug: bug?.id_bug ?? 0,
                      description: description.text,
                      cause: cause.text,
                      impact: impact.text,
                      deadline: deadline.text.isNotEmpty
                          ? DateTime.tryParse(deadline.text)
                          : null,
                      icon: icon.text,
                      statut: statut.text,
                      categorie: selectedCategorie,
                      avancement: bug?.avancement ?? 0,
                      date_creation: bug?.date_creation ?? DateTime.now(),
                    );

                    if (bug == null) {
                      debugPrint("Ajout en cours...");
                      await _bugService.ajouterBug(bugData);
                    } else {
                      debugPrint("Modification en cours...");
                      await _bugService.updateBug(bugData);
                    }

                    _loadBug(bugData.id_bug);
                    Navigator.pop(context);
                  },
                  label: Text(
                    bug == null ? "Enregistrer" : "Mettre à jour",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 2,
                  ),
                ),
                const SizedBox(height: 10),

                // --- Bouton annuler (optionnel) ---
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 133, 133, 133),
                    backgroundColor: const Color.fromARGB(0, 133, 133, 133),
                    elevation: 3,
                  ),
                  child: Text(
                    "Annuler",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// --- Champ de saisie réutilisable ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1, // valeur par défaut 1
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        maxLines: maxLines, // ✅ ici
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 15,
              color: const Color.fromARGB(120, 11, 54, 13),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  /// --- Champ de saisie pour date ---
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        readOnly: true, // Empêche la saisie directe
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: const Color(0xFFF9F9F9), // blanc cassé
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF2E7D32), // vert foncé
              width: 2,
            ),
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
            vertical: 18,
            horizontal: 16,
          ),
        ),
        onTap: () async {
          // Ouvre le DatePicker
          DateTime initialDate = DateTime.now();
          if (controller.text.isNotEmpty) {
            try {
              initialDate = DateTime.parse(controller.text);
            } catch (_) {}
          }

          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF2E7D32), // vert foncé
                    onPrimary: Colors.white,
                    onSurface: Colors.black87,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            controller.text = pickedDate.toIso8601String().split("T").first;
          }
        },
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

  Widget _buildSupp() {
    return Column(
      children: [
        // Bouton principal : Nouveau Bug
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade400.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () async {
              // action pour refaire le bug
              await _bugService.supprimerBug(widget.id_bug);
              Navigator.pushReplacementNamed(context, "/bugListe");
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: const Color.fromARGB(255, 218, 85, 85),
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: Colors.black26, // légère ombre
            ),
            icon: const Icon(
              Icons.delete_forever_sharp,
              size: 20,
              color: Colors.white,
            ),
            label: const Text(
              "Supprimer ce bug",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelance() {
    return Column(
      children: [
        // Bouton principal : Nouveau Bug
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade400.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: Colors.black26, // légère ombre
            ),
            onPressed: () async {
              // action pour refaire le bug
              await _bugService.relancerBug(bug);
              _loadDetails(); // rafraîchissement de la liste ou UI
              _loadBug(widget.id_bug);
            },
            icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
            label: const Text(
              "Relancer ce bug",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
