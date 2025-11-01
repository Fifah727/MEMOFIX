import 'package:flutter/material.dart';
import 'dart:ui';
import 'shemaPatterPoint.dart';
import 'package:memofix/models/MemoItem.dart';
import 'package:collection/collection.dart';
import 'package:memofix/widgets/memo/addMemoPlus.dart';

class PatternLockScreen extends StatefulWidget {
  final List<int> correctPattern; // ex: [0,1,2,5]
  final MemoItem memo;

  const PatternLockScreen({
    super.key,
    required this.correctPattern,
    required this.memo,
  });

  @override
  State<PatternLockScreen> createState() => _PatternLockScreenState();
}

class _PatternLockScreenState extends State<PatternLockScreen>
    with SingleTickerProviderStateMixin {
  List<PatternPoint> points = [];
  List<int> currentPattern = [];
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
  }

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

  void handleEnd() {
    dragPosition = null;

    // Comparaison avec toString() - simple et efficace
    bool isCorrect =
        currentPattern.length == widget.correctPattern.length &&
        currentPattern.toString() == widget.correctPattern.toString();

    setState(() {
      lineColor = isCorrect ? Colors.green.shade400 : Colors.red.shade400;
    });

    if (isCorrect) {
      // retourne au ecran precedant
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddMemoPlus(memo: widget.memo)),
      );
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      resetPattern(error: !isCorrect);
    });
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
                  'Schéma de déverrouillage',
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

                // Message subtil
                Text(
                  'Tracez votre motif',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
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
