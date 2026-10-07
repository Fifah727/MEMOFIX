import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memofix/widgets/memo/schema_pattern_point.dart';
import 'package:collection/collection.dart';
import 'package:line_icons/line_icons.dart';

class PatternLockScreen extends StatefulWidget {
  final bool isSetupMode; // true : on définit ou modifie le schéma
  const PatternLockScreen({super.key, this.isSetupMode = false});

  @override
  State<PatternLockScreen> createState() => _PatternLockScreenState();
}

class _PatternLockScreenState extends State<PatternLockScreen>
    with SingleTickerProviderStateMixin {
  final _storage = const FlutterSecureStorage();
  List<int> _currentPattern = [];
  List<int> _firstPattern = [];
  List<PatternPoint> points = [];
  Offset? dragPosition;
  Color lineColor = Colors.green.shade400;

  late AnimationController _pulseController;
  String message = "Tracez votre motif";
  bool hasStoredPattern = false;

  static const String _key = "pattern_code";

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 9; i++) {
      points.add(PatternPoint(id: i));
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    // _checkIfPatternExists();
  }

  int _selectedIndex = 3;

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

  // Future<void> _checkIfPatternExists() async {
  //   final stored = await _storage.read(key: _key);
  //   setState(() {
  //     hasStoredPattern = stored != null;
  //     if (!widget.isSetupMode && !hasStoredPattern) {
  //       message = "Aucun code défini — créez-en un d'abord";
  //     }
  //   });
  // }

  Future<void> _savePattern(List<int> pattern) async {
    await _storage.write(key: _key, value: pattern.join(','));
  }

  void resetPattern({bool error = false}) {
    setState(() {
      for (var p in points) p.selected = false;
      _currentPattern.clear();
      dragPosition = null;
      lineColor = Colors.green.shade400;
    });
  }

  Future<List<int>?> _getStoredPattern() async {
    final value = await _storage.read(key: _key);
    if (value == null) return null;
    return value.split(',').map(int.parse).toList();
  }

  void handleDrag(Offset localPos, Size size) {
    dragPosition = localPos;
    for (var p in points) {
      final rect = Rect.fromCircle(center: p.position, radius: 30);
      if (rect.contains(localPos) && !p.selected) {
        p.selected = true;
        _currentPattern.add(p.id);
      }
    }
    setState(() {});
  }

  // apres reglage
  void handleEnd() async {
    dragPosition = null;

    if (_currentPattern.isEmpty) return;

    if (widget.isSetupMode) {
      // 1. Mode configuration : sauvegarder ou confirmer le code

      if (_firstPattern.isEmpty) {
        // Premier tracé : on demande confirmation
        _firstPattern = List.from(_currentPattern);
        setState(() {
          message = "Tracez à nouveau pour confirmer le motif";
        });
      } else {
        // Deuxième tracé : on compare avec le premier
        if (ListEquality().equals(_firstPattern, _currentPattern)) {
          // Sauvegarde définitive
          await _savePattern(_currentPattern);
          setState(() {
            message = "Motif enregistré avec succès !";
          });

          Future.delayed(const Duration(milliseconds: 800), () {
            resetPattern();
            Navigator.pushNamed(context, "/home");
          });
        } else {
          setState(() {
            message = "Les motifs ne correspondent pas, réessayez";
            lineColor = Colors.red.shade400;
          });
          Future.delayed(const Duration(milliseconds: 800), () {
            resetPattern(error: true);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final gridSize = size.width - 80;
    final spacing = gridSize / 3;

    // Calculer les positions des points
    for (int i = 0; i < 9; i++) {
      final row = i ~/ 3;
      final col = i % 3;
      points[i].position = Offset(
        col * spacing + spacing / 2 + 20,
        row * spacing + spacing / 2 + 20,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFFFAFAFA),
        title: Text(
          widget.isSetupMode ? "Définir le code" : "Déverrouillage",
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(LineIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pushNamed(context, "/home"),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Icon(Icons.lock_outline, size: 60, color: Colors.grey.shade700),
                const SizedBox(height: 15),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 30),
                // Conteneur du schéma épuré
                Container(
                  width: gridSize + 40,
                  height: gridSize + 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: GestureDetector(
                    onPanStart: (details) =>
                        handleDrag(details.localPosition, size),
                    onPanUpdate: (details) =>
                        handleDrag(details.localPosition, size),
                    onPanEnd: (details) => handleEnd(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        size: Size(gridSize, gridSize),
                        painter: PatternPainterAnimated(
                          points: points,
                          dragPosition: dragPosition,
                          lineColor: lineColor,
                          animation: _pulseController,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                if (hasStoredPattern && !widget.isSetupMode)
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PatternLockScreen(isSetupMode: true),
                      ),
                    ),
                    child: const Text(
                      "Modifier le motif",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
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
}
