import 'package:flutter/material.dart';
import 'package:memofix/models/fixme/FixMeItems.dart';
import 'package:memofix/services/query/fixme/bug_service.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:memofix/screens/fixme/bugDetailScreen.dart';
import 'package:memofix/screens/fixme/bugAddScreen.dart';

class BugListScreen extends StatefulWidget {
  const BugListScreen({super.key});

  @override
  State<BugListScreen> createState() => _BugListScreenState();
}

class _BugListScreenState extends State<BugListScreen> {
  final BugService _bugService = BugService();
  List<BugItem> _bugs = [];

  Future<void> loadBugs() async {
    try {
      final bugs = await _bugService.getBugs();
      setState(() {
        _bugs = bugs;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des bugs : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadBugs();
  }

  int _selectedIndex = 2;

  final List<String> _routes = [
    '/home',
    '/memo',
    '/bugListe',
    '/screen-deverouiller',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pushNamed(context, _routes[index]);
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchKey = 'Toutes';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BugItem> get _filteredBugs {
    List<BugItem> filtered = _bugs;
    if (_searchKey != "Toutes") {
      filtered = filtered
          .where(
            (memo) => memo.description.toLowerCase().contains(
              _searchKey.toLowerCase(),
            ),
          )
          .toList();
    }

    return filtered;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text(
          'Tous les bugs',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pushNamed(
            context,
            "/home",
          ), // Plus simple et plus efficace
        ),
        actions: [
          IconButton(
            tooltip: 'Ajouter',
            icon: const Icon(LineIcons.plus, color: Colors.black87),
            onPressed: () {
              //
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddBugScreen()),
              );
            },
          ),
        ],
      ),

      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(_bugs.length),
                const SizedBox(height: 13),

                // Barre de recherche moderne
                _buildSearchBar(),
                const SizedBox(height: 16),

                // Section des bugs
                _buildBugsSection(),

                // Boutons d'action
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white.withOpacity(0.95),
          indicatorColor: theme.primaryColor.withOpacity(0.15),
          elevation: 10,
          height: 68,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              );
            }
            return const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: theme.primaryColor, size: 26);
            }
            return const IconThemeData(color: Colors.black54, size: 24);
          }),
        ),
        child: NavigationBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.08),
          animationDuration: const Duration(milliseconds: 400),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_filled),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.sticky_note_2_sharp),
              label: 'Mémos',
            ),
            NavigationDestination(
              icon: Icon(Icons.bug_report_sharp),
              label: 'Bugs',
            ),
            NavigationDestination(
              icon: Icon(Icons.lock),
              label: 'Déverouillage',
            ),
          ],
        ),
      ),
    );
  }

  //
  Color _getCategoryColor(String category) {
    final colors = {
      'ui': const Color.fromARGB(255, 49, 72, 133), // bleu nuit foncé
      'backend': const Color.fromARGB(255, 110, 133, 66), // vert matcha
      'performance': const Color.fromARGB(255, 84, 34, 121), // violet profond
    };

    // On convertit la catégorie en minuscules pour correspondre aux clés
    final key = category.toLowerCase();

    // Si la catégorie est connue, on retourne sa couleur exacte
    if (colors.containsKey(key)) return colors[key]!;

    // Sinon, fallback basique (ex : gris neutre)
    return const Color.fromARGB(255, 128, 128, 128);
  }

  Color _getProgressColor(double progress) {
    // Variante fluide rouge → vert
    progress = progress.clamp(0, 100);
    double t = progress / 100;

    final hsl = HSLColor.fromAHSL(1.0, 0 + (120 * t), 0.75, 0.55);
    return hsl.toColor();
  }

  Widget _buildBugCard(BugItem bug) {
    final categoryColor = _getCategoryColor(bug.categorie);
    final statusColor = _getStatutColor(bug.statut);

    return GestureDetector(
      onTap: () {
        // vers BugDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BugDetailScreen(id_bug: bug.id_bug),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 236, 236, 236),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: bug.icon != null && bug.icon!.isNotEmpty
                            ? Icon(
                                _getIconFromString(bug.icon),
                                color: categoryColor,
                                size: 26,
                              )
                            : Text(
                                bug.categorie.characters.first.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bug.description,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                // 🔹 Barre de progression
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Avancement',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${bug.avancement}%',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ],
                    ),
                    if (bug.avancement != 0) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                Container(
                                  height: 6,
                                  width: double.infinity,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                  width:
                                      (bug.avancement / 100) *
                                      constraints.maxWidth,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getProgressColor(
                                          bug.avancement.toDouble(),
                                        ).withOpacity(0.95),
                                        _getProgressColor(
                                          bug.avancement.toDouble(),
                                        ).withOpacity(0.7),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
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

                const SizedBox(height: 16),

                // 🔹 Pied de carte
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: statusColor.withOpacity(0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        _getStatut(bug.statut),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {},
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          size: 18,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBugsSection() {
    final hasBugs = _filteredBugs.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasBugs)
          Column(
            children: _filteredBugs
                .map(
                  (bug) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: _buildBugCard(bug),
                  ),
                )
                .toList(),
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 130),
              child: Column(
                children: [
                  Icon(
                    Icons.sentiment_satisfied_alt_outlined,
                    color: Colors.grey.shade400,
                    size: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Aucun bug trouvé',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(int nombreBugs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Liste des bugs',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$nombreBugs bugs enregistrés',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      child: ClipRRect(
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _searchKey = val;
              });
            }
          },
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            hintText: "Recherchez un bug...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            alignLabelWithHint: true,
            isDense: true,
            labelStyle: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF2E7D32),
                width: 1.5,
              ),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Color.fromARGB(120, 11, 54, 13),
              size: 25,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 45, // largeur de l'icône
              minHeight: 45, // force la hauteur à rester visible
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
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
            onPressed: () {
              // Navigation vers BugEditScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddBugScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white, size: 22),
            label: const Text(
              'Nouveau Bug à Corriger',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Bouton secondaire : Statistiques
        // Container(
        //   width: double.infinity,
        //   height: 50,
        //   decoration: BoxDecoration(
        //     color: Colors.white.withOpacity(0.25),
        //     borderRadius: BorderRadius.circular(22),
        //     border: Border.all(color: Colors.grey.withOpacity(0.15)),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.05),
        //         blurRadius: 12,
        //         offset: const Offset(0, 4),
        //       ),
        //     ],
        //   ),
        //   child: ElevatedButton(
        //     onPressed: () {
        //       // Navigation vers statistiques
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.transparent,
        //       shadowColor: Colors.transparent,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(22),
        //       ),
        //     ),
        //     child: Text(
        //       'Voir mes statistiques',
        //       style: TextStyle(
        //         color: Colors.grey.shade900,
        //         fontWeight: FontWeight.w500,
        //         fontSize: 14,
        //         letterSpacing: 0.3,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
