import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:memofix/widgets/memo/shemaPatterPoint.dart';
import 'package:memofix/models/MemoItem.dart';
import 'package:collection/collection.dart';
import 'package:memofix/widgets/memo/addMemoPlus.dart';
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

  // DEFINIR email
  final storage = const FlutterSecureStorage();
  bool isLoading = false;
  String? recoveryEmail;

  Future<void> _loadEmail() async {
    recoveryEmail = await storage.read(key: 'recovery_email');
    setState(() {});

    if (recoveryEmail == null) {
      final email = TextEditingController();

      await showModalBottomSheet(
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
                  Text(
                    "Définir votre adresse email de récupération",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInputField(
                    controller: email,
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),

                  ElevatedButton.icon(
                    onPressed: () async {
                      if (email.text.isNotEmpty) {
                        await storage.write(
                          key: 'recovery_email',
                          value: email.text,
                        );
                        setState(() {
                          recoveryEmail = email.text;
                        });
                        Navigator.pop(context);
                      }
                    },
                    label: const Text("Valider"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _changerEmail() async {
    final email = TextEditingController(
      text: recoveryEmail != "" ? recoveryEmail : "",
    );

    await showModalBottomSheet(
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
                Text(
                  "Définir votre adresse email de récupération",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 24),

                _buildInputField(
                  controller: email,
                  label: "Email",
                  icon: Icons.email_outlined,
                ),

                ElevatedButton.icon(
                  onPressed: () async {
                    if (email.text.isNotEmpty) {
                      await storage.write(
                        key: 'recovery_email',
                        value: email.text,
                      );
                      setState(() {
                        recoveryEmail = email.text;
                      });
                      Navigator.pop(context);
                    }
                  },
                  label: const Text("Valider"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FIN

  static const String _key = "pattern_code";

  @override
  void initState() {
    super.initState();
    _loadEmail();

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
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 40,
                      ),
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
                      await _changerEmail();
                    },

                    label: const Text(
                      "Modifier email de récuperation",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
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
