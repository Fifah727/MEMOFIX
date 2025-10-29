import 'package:flutter/material.dart';
import 'dart:ui';
import 'shemaPatterPoint.dart';
import 'package:collection/collection.dart';

class PatternLockScreen extends StatefulWidget {
  final List<int> correctPattern; // ex: [0,1,2,5]

  const PatternLockScreen({super.key, required this.correctPattern});

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

    Future.delayed(const Duration(milliseconds: 600), () {
      resetPattern(error: !isCorrect);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gridSize = size.width - 40;
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
      backgroundColor: Colors.grey.shade200.withOpacity(0.2),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: gridSize + 40,
              height: gridSize + 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: GestureDetector(
                onPanStart: (details) =>
                    handleDrag(details.localPosition, size),
                onPanUpdate: (details) =>
                    handleDrag(details.localPosition, size),
                onPanEnd: (details) => handleEnd(),
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
        ),
      ),
    );
  }
}
