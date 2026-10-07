import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/memo/add_memo_plus.dart';
import 'package:line_icons/line_icons.dart';
import 'package:memofix/models/memo_item.dart';
import 'package:memofix/screens/fixme/bug_add_screen.dart';
import 'package:memofix/services/query/memo/memo_service.dart';
import 'package:memofix/models/fixme/fixme_items.dart';
import 'package:memofix/services/query/fixme/bug_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MemoService memoService = MemoService();
  List<MemoItem> _memos = [];
  int nbMemos = 0;
  final memoVide = MemoItem(
    id: 0,
    titre: "",
    text: "",
    category: 1,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  Future<void> loadMemos() async {
    try {
      final memos = await memoService.getMemos();
      setState(() {
        _memos = memos;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des memos : $e");
    }
  }

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
    loadMemos();
    loadBugs();
  }

  int _selectedIndex = 0;

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

  final List<DashboardCard> dashboardItems = [
    DashboardCard(
      title: 'FixMe',
      subtitle: '3 bugs en cours',
      description: 'Améliore-toi jour après jour',
      colors: [Color(0xFFFFF3CD), Color(0xFFFFE4B5)],
      emoji: '🐛',
      progress: 0.45,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text(
          'MémoFix',
          style: TextStyle(fontSize: 22, color: Colors.black87),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header personnalisé
                _buildHeader(),
                const SizedBox(height: 30),

                // Question d'humeur du jour
                Text(
                  "Tableau de bord",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                // _buildDailyMoodCheck(),
                //const SizedBox(height: 32),

                // Dashboard cards
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  child: Wrap(
                    spacing: 16, // espace horizontal entre les cartes
                    runSpacing: 16, // espace vertical si ça passe sur 2 lignes
                    alignment: WrapAlignment.center,
                    children: [
                      // ─── Carte Mémos ─────────────────────────────
                      Container(
                        width: 150,
                        height: 150, // un peu plus haut pour éviter l’overflow
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC8E6C9).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.note_alt_outlined,
                                      color: Color.fromARGB(221, 66, 66, 66),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    "Mémos",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _memos.length.toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ─── Carte Bugs actifs ─────────────────────────────
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFF3CD), Color(0xFFFFE4B5)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFE4B5).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.bug_report_outlined,
                                      color: Color.fromARGB(221, 66, 66, 66),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    "Bugs actifs",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _bugs.length.toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Actions rapides
                _buildQuickActions(),
                // const SizedBox(height: 32),

                // Progression de la semaine
                // _buildWeeklyProgress(),
                // const SizedBox(height: 24),

                // // Citation inspirante
                // _buildDailyInspiration(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B8E23), Color(0xFF8FBC8F)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8E23).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prêt pour une journée productive?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getCurrentDate()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text('🌱', style: TextStyle(fontSize: 28)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: dashboardItems.length,
          itemBuilder: (context, index) {
            return _buildDashboardCard(dashboardItems[index]);
          },
        ),
      ],
    );
  }

  Widget _buildDashboardCard(DashboardCard item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: item.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Icon(Icons.more_vert, color: Colors.grey[600], size: 16),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                // Progress indicator
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: item.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddMemoPlus(memo: memoVide)),
              ), // appelle la fonction d'ajout
              child: Container(
                width: 70,
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(0xFF6B8E23).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF6B8E23).withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF6B8E23),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nouveau mémo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddBugScreen()),
              ),
              child: Container(
                width: 70,
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(0xFFA0522D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFFA0522D).withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.bug_report_outlined,
                        color: Color(0xFFA0522D),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajouter un bug',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression Hebdomadaire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '75%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(7, (index) {
              final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
              final heights = [0.4, 0.8, 0.6, 0.9, 0.7, 0.3, 0.5];
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        width: 20,
                        height: 60 * heights[index],
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF6B8E23),
                              const Color(0xFF8FBC8F),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        days[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyInspiration() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inspiration du jour',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"Chaque petit progrès compte. Tu es plus forte que tu ne le penses."',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// Modèles de données
class DashboardCard {
  final String title;
  final String subtitle;
  final String description;
  final List<Color> colors;
  final String emoji;
  final double progress;

  DashboardCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.colors,
    required this.emoji,
    required this.progress,
  });
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;

  final void Function(void) goTo;

  QuickAction(this.title, this.icon, this.color, this.goTo);
}
