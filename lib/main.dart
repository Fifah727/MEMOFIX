import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memofix/models/memo_item.dart';
import 'package:memofix/theme/colors.dart';
import 'package:memofix/widgets/memo/schema_screen.dart';

import 'screens/fixme/bug_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/memos/memo_screen.dart';
import 'widgets/forgot_pattern_screen.dart';
import 'widgets/pattern_lock_screen.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightPrimary,
  scaffoldBackgroundColor: AppColors.lightBackground,
  cardColor: AppColors.lightSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  colorScheme: const ColorScheme.light(
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightSecondary,
    tertiary: AppColors.lightAccent,
    surface: AppColors.lightSurface,
    surfaceVariant: AppColors.lightSurfaceVariant,
    background: AppColors.lightBackground,
    onPrimary: Colors.white,
    onSecondary: AppColors.lightTextPrimary,
    onSurface: AppColors.lightTextPrimary,
    onBackground: AppColors.lightTextPrimary,
    outline: AppColors.lightTextSecondary,
    shadow: Colors.black26,
  ),
  textTheme: GoogleFonts.ralewayTextTheme(ThemeData.dark().textTheme).copyWith(
    bodyMedium: GoogleFonts.raleway(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.white70,
    ),
    bodyLarge: GoogleFonts.raleway(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.white70,
    ),
    titleMedium: GoogleFonts.raleway(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.lightPrimary,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightSurface,
    hintStyle: TextStyle(color: AppColors.lightTextSecondary.withOpacity(0.7)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.lightTextSecondary.withOpacity(0.3),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.lightTextSecondary.withOpacity(0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.darkPrimary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  cardColor: AppColors.darkSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    centerTitle: true,
  ),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    tertiary: AppColors.darkAccent,
    surface: AppColors.darkSurface,
    surfaceVariant: AppColors.darkSurfaceVariant,
    background: AppColors.darkBackground,
    onPrimary: AppColors.darkBackground,
    onSecondary: AppColors.darkTextPrimary,
    onSurface: AppColors.darkTextPrimary,
    onBackground: AppColors.darkTextPrimary,
    outline: AppColors.darkTextSecondary,
    shadow: Colors.black54,
  ),
  textTheme: GoogleFonts.ralewayTextTheme(ThemeData.dark().textTheme).copyWith(
    bodyMedium: GoogleFonts.raleway(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: Colors.white70,
    ),
    bodyLarge: GoogleFonts.raleway(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: Colors.white70,
    ),
    titleMedium: GoogleFonts.raleway(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: Colors.white,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.darkPrimary,
    foregroundColor: AppColors.darkBackground,
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkBackground,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurface,
    hintStyle: TextStyle(color: AppColors.darkTextSecondary.withOpacity(0.7)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.darkTextSecondary.withOpacity(0.3),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.darkTextSecondary.withOpacity(0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
    ),
  ),
);

void main() {
  runApp(MemoFixApp());
}

class MemoFixApp extends StatelessWidget {
  MemoFixApp({super.key});
  // final List<int> correctPattern = [1,2,3,4];
  final memoVide = MemoItem(
    id: 0,
    titre: "",
    text: "",
    category: 1,
    createdAt: DateTime.now(),
    modifiedAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MemoFix',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/memo': (context) => const MemoScreen(),
        '/bugListe': (context) => const BugListScreen(),
        '/forgot': (context) => const ForgotPatternScreen(),
        '/lock-false': (context) => const PatternLockScreen(isSetupMode: true),
        '/screen-deverouiller': (context) => SchemaScreen(
          correctPattern: [0, 1, 2, 5],
          memo: memoVide,
          deverouiller: true,
        ),
      },
    );
    // Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (_) => PatternLockScreen(
    //                       correctPattern: [0, 1, 2, 5],
    //                       memo: result,
    //                     ),
    //                   ),
    //                 );
  }
}
