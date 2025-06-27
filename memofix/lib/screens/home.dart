import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  final Map<int, bool> _hovering = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardsData = [
      {
        'icon': Icons.note_alt_rounded,
        'title': 'Mes Mémos',
        'subtitle': 'Textes, vocaux, rappels...',
        'route': '/memo',
      },
      {
        'icon': Icons.bug_report_rounded,
        'title': 'FixMe',
        'subtitle': 'Mes bugs IRL à corriger',
        'route': '/fixme',
      },
      {
        'icon': Icons.settings_rounded,
        'title': 'Paramètres',
        'subtitle': 'Préférences & options',
        'route': '/settings',
      },
      {
        'icon': Icons.image_rounded,
        'title': 'Image',
        'subtitle': 'Choisir une image',
        'route': '/photo',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.sticky_note_2_rounded, size: 28),
            const SizedBox(width: 8),
            Text(
              'MemoFix',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Paramètres',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;

            return GridView.builder(
              itemCount: cardsData.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 4 / 3,
              ),
              itemBuilder: (context, index) {
                final card = cardsData[index];
                final isHovering = _hovering[index] ?? false;

                return MouseRegion(
                  onEnter: (_) => setState(() => _hovering[index] = true),
                  onExit: (_) => setState(() => _hovering[index] = false),
                  cursor: SystemMouseCursors.click,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, card['route'] as String),

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isHovering
                              ? theme.colorScheme.secondary.withOpacity(0.1)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isHovering ? 0.3 : 0.15,
                              ),
                              blurRadius: isHovering ? 12 : 6,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              card['icon'] as IconData,
                              size: 56,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              card['title'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card['subtitle'] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
