import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String currentMood = '';
  String currentEmoji = '😊';

  final List<DashboardCard> dashboardItems = [
    DashboardCard(
      title: 'MemoFix',
      subtitle: '12 mémos actifs',
      description: 'Tes notes et pensées du moment',
      colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
      emoji: '📝',
      progress: 0.7,
    ),
    DashboardCard(
      title: 'FixMe',
      subtitle: '3 bugs en cours',
      description: 'Améliore-toi jour après jour',
      colors: [Color(0xFFFFF3CD), Color(0xFFFFE4B5)],
      emoji: '🐛',
      progress: 0.45,
    ),
    DashboardCard(
      title: 'Mood Tracker',
      subtitle: 'Aujourd\'hui: Motivé',
      description: 'Suis ton humeur quotidienne',
      colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
      emoji: '😊',
      progress: 0.85,
    ),
    DashboardCard(
      title: 'Statistiques',
      subtitle: 'Semaine productive',
      description: 'Analyse tes progrès',
      colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
      emoji: '📊',
      progress: 0.6,
    ),
  ];

  final List<QuickAction> quickActions = [
    QuickAction('Nouveau Mémo', Icons.add_circle_outline, Color(0xFF6B8E23)),
    QuickAction('Bug à Corriger', Icons.bug_report_outlined, Color(0xFFA0522D)),
    QuickAction('Mon Humeur', Icons.sentiment_satisfied_alt, Color(0xFF4FC3F7)),
    QuickAction('Statistiques', Icons.analytics_outlined, Color(0xFFBA68C8)),
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
        actions: [
          IconButton(
            tooltip: 'Audio',
            icon: const Icon(LineIcons.stickyNote, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/audio');
            },
          ),
          IconButton(
            tooltip: 'Checklist',
            icon: const Icon(LineIcons.stickyNote, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/checklist');
            },
          ),
          IconButton(
            tooltip: 'Lock-Schema',
            icon: const Icon(LineIcons.stickyNote, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/lock');
            },
          ),
          IconButton(
            tooltip: 'Memos',
            icon: const Icon(LineIcons.stickyNote, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/memo');
            },
          ),
          IconButton(
            tooltip: 'FixMe',
            icon: const Icon(LineIcons.tools, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/fixme');
            },
          ),
          IconButton(
            tooltip: 'Animation',
            icon: const Icon(LineIcons.playCircle, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/lottie');
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
                // Header personnalisé
                _buildHeader(),
                const SizedBox(height: 32),

                // Question d'humeur du jour
                _buildDailyMoodCheck(),
                const SizedBox(height: 32),

                // Dashboard cards
                _buildDashboardSection(),
                const SizedBox(height: 32),

                // Actions rapides
                _buildQuickActions(),
                const SizedBox(height: 32),

                // Progression de la semaine
                _buildWeeklyProgress(),
                const SizedBox(height: 24),

                // Citation inspirante
                _buildDailyInspiration(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B8E23), Color(0xFF8FBC8F)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8E23).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                  'Bonjour Sarah! 🌅',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prête pour une journée productive?',
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
                    '🗓️ ${_getCurrentDate()}',
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

  Widget _buildDailyMoodCheck() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF8E1).withOpacity(0.8),
            const Color(0xFFFFFBF0).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Sarah, comment te sens-tu aujourd\'hui?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),

          // Mood emoji sélecteur
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4B5),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(currentEmoji, style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentMood,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMoodOption('😴', 'Fatigué'),
              _buildMoodOption('😊', 'Motivé'),
              _buildMoodOption('😰', 'Stressé'),
              _buildMoodOption('🤔', 'Pensif'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodOption(String emoji, String label) {
    final isSelected = label == currentMood;
    return GestureDetector(
      onTap: () => setState(() {
        currentMood = label;
        currentEmoji = emoji;
      }),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFCC02).withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tableau de Bord',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Voir tout',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B8E23),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
          children: quickActions.map((action) {
            return _buildQuickActionButton(action);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(QuickAction action) {
    return Container(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: action.color.withOpacity(0.2)),
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            action.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
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
    return '${now.day} ${months[now.month - 1]}';
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

  QuickAction(this.title, this.icon, this.color);
}
