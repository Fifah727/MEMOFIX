import 'package:flutter/material.dart';

class AppColors {
  static const Color lightPrimary = Color(0xFF6B8E23); // Vert olive calme
  static const Color lightSecondary = Color(0xFF8FBC8F); // Vert sauge doux
  static const Color lightAccent = Color(0xFFA0522D); // Brun sienna harmonieux
  static const Color lightBackground = Color(
    0xFFF5F5DC,
  ); // Beige naturel très clair
  static const Color lightSurface = Color(0xFFFAFAF8); // Blanc cassé chaleureux
  static const Color lightSurfaceVariant = Color(0xFFE8F5E8); // Vert très pâle
  static const Color lightTextPrimary = Color(0xFF2F4F2F); // Vert foncé naturel
  static const Color lightTextSecondary = Color(0xFF696969); // Gris chaud

  static const Color darkPrimary = Color(0xFF9ACD32); // Vert jaune lumineux
  static const Color darkSecondary = Color(0xFF556B2F); // Vert olive foncé
  static const Color darkAccent = Color(0xFFCD853F); // Brun doré chaleureux
  static const Color darkBackground = Color(
    0xFF1C2415,
  ); // Vert très sombre, presque noir
  static const Color darkSurface = Color(0xFF252B1F); // Vert anthracite
  static const Color darkSurfaceVariant = Color(
    0xFF2F3B28,
  ); // Vert foncé pour variations
  static const Color darkTextPrimary = Color(0xFFE8F5E8); // Vert très clair
  static const Color darkTextSecondary = Color(0xFFC0C9B8); // Vert gris doux

  static const Color success = Color(0xFF228B22); // Vert forêt
  static const Color warning = Color(0xFFDAA520); // Doré terreux
  static const Color error = Color(0xFFB22222); // Rouge brique naturel
  static const Color info = Color(0xFF708090); // Gris ardoise

  static const LinearGradient lightGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9ACD32), // Vert jaune
      Color(0xFF6B8E23), // Vert olive
    ],
  );

  static const LinearGradient brownGreenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF8FBC8F), // Vert sauge
      Color(0xFFA0522D), // Brun sienna
    ],
  );
}
