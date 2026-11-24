import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF6FBFF);
  static const Color surface = Colors.white;

  static const Color skyBlue = Color(0xFF4FB3FF);
  static const Color skyBlueLight = Color(0xFFE3F4FF);
  static const Color sunYellow = Color(0xFFFFCA3A);
  static const Color sunYellowLight = Color(0xFFFFF6D6);
  static const Color softPink = Color(0xFFFF7AA2);
  static const Color softPinkLight = Color(0xFFFFE6EE);
  static const Color mintGreen = Color(0xFF38C98F);
  static const Color mintGreenLight = Color(0xFFE0FAEE);
  static const Color lavender = Color(0xFF9B7BFF);
  static const Color lavenderLight = Color(0xFFF0EBFF);
  static const Color peach = Color(0xFFFF9B6A);
  static const Color peachLight = Color(0xFFFFECE3);

  static const Color textDark = Color(0xFF1F2D3D);
  static const Color textMuted = Color(0xFF5E6F82);
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFFF5C77);
  static const Color border = Color(0xFFE2EDF7);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.skyBlue,
        brightness: Brightness.light,
        primary: AppColors.skyBlue,
        secondary: AppColors.softPink,
        tertiary: AppColors.sunYellow,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textDark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          height: 1.3,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.skyBlue.withAlpha(35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.skyBlue,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: AppColors.skyBlue.withAlpha(90),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.3),
        headlineMedium: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.3),
        titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.35),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.4),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textDark, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMuted, height: 1.45),
      ),
    );
  }

  static Color pastelForIndex(int index) {
    const palette = [
      AppColors.skyBlue,
      AppColors.softPink,
      AppColors.sunYellow,
      AppColors.mintGreen,
      AppColors.lavender,
      AppColors.peach,
    ];
    return palette[index % palette.length];
  }

  static Color lightPastelForIndex(int index) {
    const palette = [
      AppColors.skyBlueLight,
      AppColors.softPinkLight,
      AppColors.sunYellowLight,
      AppColors.mintGreenLight,
      AppColors.lavenderLight,
      AppColors.peachLight,
    ];
    return palette[index % palette.length];
  }
}
