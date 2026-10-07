import 'package:flutter/material.dart';
import 'dart:ui';
import 'schema_pattern_point.dart';
import 'package:memofix/models/memo_item.dart';
import 'package:collection/collection.dart';
import 'package:memofix/widgets/memo/add_memo_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/gestures.dart';


class SchemaScreen extends StatefulWidget {
  final List<int> correctPattern; // ex: [0,1,2,5]
  final MemoItem memo;
  final bool deverouiller;

  const SchemaScreen({
    super.key,
    required this.correctPattern,
    required this.memo,
    required this.deverouiller,
  });

  @override
  State<SchemaScreen> createState() => _SchemaScreenState();
}

class _SchemaScreenState extends State<SchemaScreen>
    with SingleTickerProviderStateMixin {
  List<PatternPoint> points = [];
  Offset? dragPosition;

  Color lineColor = Colors.green.shade400;
  late AnimationController _pulseController;

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
    _checkIfPatternExists();
  }

  final _storage = const FlutterSecureStorage();
  String message = "Tracez votre motif";
  bool hasStoredPattern = false;
  static const String _key = "pattern_code";

  List<int> currentPattern = [];

  Future<void> _checkIfPatternExists() async {
    final stored = await _storage.read(key: _key);
    setState(() {
      hasStoredPattern = stored != null;
      if (!hasStoredPattern) {
        // se rediriger vers patternLockScreen : pour la 1er fois que aucun schema ou email
        Navigator.pushReplacementNamed(context, '/lock-false');

        //message = "Aucun code défini — créez-en un d'abord";
      }
    });
  }

  // comparer avec secureStorage
  void handleEnd() async {
    dragPosition = null;

    // Récupérer le motif stocké depuis FlutterSecureStorage
    final stored = await _storage.read(key: _key);

    bool isCorrect = false;

    if (stored != null) {
      // Stocké sous forme de String, par ex "[1, 2, 3]"
      // On peut le convertir en List<int>
      List<int> storedPattern = stored
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .toList();

      // Comparaison
      isCorrect =
          currentPattern.length == storedPattern.length &&
          currentPattern.toString() == storedPattern.toString();
    }

    setState(() {
      lineColor = isCorrect ? Colors.green.shade400 : Colors.red.shade400;
    });

    if (isCorrect) {
      if (widget.deverouiller) {
        // go to patternSreen
        Navigator.pushReplacementNamed(context, '/lock-false');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddMemoPlus(memo: widget.memo)),
        );
      }
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      resetPattern(error: !isCorrect);
    });
  }

  // comparer avec widget.correctPattern
  // void handleEnd() {
  //   dragPosition = null;
  //   // Comparaison avec toString() - simple et efficace
  //   bool isCorrect =
  //       currentPattern.length == widget.correctPattern.length &&
  //       currentPattern.toString() == widget.correctPattern.toString();
  //   setState(() {
  //     lineColor = isCorrect ? Colors.green.shade400 : Colors.red.shade400;
  //   });
  //   if (isCorrect) {
  //     // retourne au ecran precedant
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => AddMemoPlus(memo: widget.memo)),
  //     );
  //   }
  //   Future.delayed(const Duration(milliseconds: 600), () {
  //     resetPattern(error: !isCorrect);
  //   });
  // }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void resetPattern({bool error = false}) {
    setState(() {
      for (var p in points) p.selected = false;
      currentPattern.clear();
      dragPosition = null;
      lineColor = Colors.green.shade400;
    });
  }

  void handleDrag(Offset localPos, Size size) {
    dragPosition = localPos;
    for (var p in points) {
      final rect = Rect.fromCircle(center: p.position, radius: 30);
      if (rect.contains(localPos) && !p.selected) {
        p.selected = true;
        currentPattern.add(p.id);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône minimaliste
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 28,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 48),

                // Titre discret
                Text(
                  'Tracer votre motif pour continuer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 56),

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

                const SizedBox(height: 24),

                // À placer dans ton build() où tu veux afficher le Text.rich
                  Text.rich(
                    TextSpan(
                      text: "Motif oublié ? ",
                      children: [
                        TextSpan(
                          text: "Réinitialiser",
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(
                                context,
                                "/forgot",
                              );
                            },
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
