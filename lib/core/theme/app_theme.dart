import 'package:flutter/material.dart';

/// Paleta de colores de la marca Grano & Co.
class AppColors {
  static const terracota = Color(0xFFB5543C);
  static const espresso = Color(0xFF3B2A22);
  static const crema = Color(0xFFF3E6D3);
  static const oliva = Color(0xFF7A8450);
  static const blanco = Color(0xFFFFFBF6);
  static const arena = Color(0xFFEBD3BC);
  static const salvia = Color(0xFFE2E5CF);
}

/// Tema único de la app: todos los colores y tipografías salen de aquí.
class AppTheme {
  static const fuenteTitulos = 'GranoSerif';

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppColors.terracota,
      primary: AppColors.terracota,
      onPrimary: AppColors.blanco,
      primaryContainer: AppColors.arena,
      onPrimaryContainer: AppColors.espresso,
      secondary: AppColors.oliva,
      secondaryContainer: AppColors.salvia,
      onSecondaryContainer: AppColors.espresso,
      tertiary: AppColors.espresso,
      tertiaryContainer: AppColors.arena,
      onTertiaryContainer: AppColors.espresso,
      surface: AppColors.blanco,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColors.crema,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.espresso,
        foregroundColor: AppColors.crema,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fuenteTitulos,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.crema,
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontFamily: fuenteTitulos, color: AppColors.espresso),
        titleLarge: TextStyle(fontFamily: fuenteTitulos, color: AppColors.espresso),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.blanco,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.terracota,
          foregroundColor: AppColors.blanco,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.espresso,
        contentTextStyle: TextStyle(color: AppColors.crema),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
