import 'package:flutter/material.dart';
import 'dart:ui';

class PatternPoint {
  final int id;
  Offset position;
  bool selected;

  PatternPoint({
    required this.id,
    this.position = Offset.zero,
    this.selected = false,
  });
}

class PatternPainterAnimated extends CustomPainter {
  final List<PatternPoint> points;
  final Offset? dragPosition;
  final Color lineColor;
  final Animation<double> animation;

  PatternPainterAnimated({
    required this.points,
    this.dragPosition,
    required this.lineColor,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final paintPoint = Paint()..color = const Color.fromARGB(255, 56, 56, 56);

    final selectedPoints = points.where((p) => p.selected).toList();

    // Lignes entre les points
    for (int i = 0; i < selectedPoints.length - 1; i++) {
      canvas.drawLine(
        selectedPoints[i].position,
        selectedPoints[i + 1].position,
        paintLine,
      );
    }

    if (selectedPoints.isNotEmpty && dragPosition != null) {
      canvas.drawLine(selectedPoints.last.position, dragPosition!, paintLine);
    }

    // Dessiner les points
    for (var p in points) {
      double radius = p.selected ? 12 + animation.value * 4 : 20;
      canvas.drawCircle(p.position, 20, paintPoint);
      if (p.selected) {
        canvas.drawCircle(p.position, radius, paintLine);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
