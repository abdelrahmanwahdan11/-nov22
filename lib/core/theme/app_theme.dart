import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color defaultPrimary = Color(0xFF2F80ED);
  static const Color secondary = Color(0xFFF2C94C);
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color backgroundDark = Color(0xFF111111);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color textPrimaryLight = Color(0xFF111111);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBBBBBB);

  static ThemeData light(
    Color primaryColor, {
    bool highContrast = false,
    bool reduceMotion = false,
  }) {
    final base = ThemeData.light(useMaterial3: true);
    final contrastOverlay = highContrast ? Colors.black.withOpacity(0.06) : Colors.transparent;
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: secondary,
        background: backgroundLight,
        surface: highContrast ? Colors.white : cardLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: highContrast ? Colors.white : cardLight,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: textPrimaryLight,
        displayColor: textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: (highContrast ? Colors.white : cardLight).withOpacity(0.98),
        selectedColor: primaryColor.withOpacity(0.18),
        labelStyle: TextStyle(color: highContrast ? Colors.black : textPrimaryLight, fontWeight: highContrast ? FontWeight.w600 : null),
      ),
      cardTheme: CardTheme(shadowColor: contrastOverlay),
      pageTransitionsTheme: reduceMotion
          ? const PageTransitionsTheme(builders: {
              TargetPlatform.android: NoTransitionsBuilder(),
              TargetPlatform.iOS: NoTransitionsBuilder(),
              TargetPlatform.macOS: NoTransitionsBuilder(),
              TargetPlatform.windows: NoTransitionsBuilder(),
              TargetPlatform.linux: NoTransitionsBuilder(),
              TargetPlatform.fuchsia: NoTransitionsBuilder(),
            })
          : base.pageTransitionsTheme,
    );
  }

  static ThemeData dark(
    Color primaryColor, {
    bool highContrast = false,
    bool reduceMotion = false,
  }) {
    final base = ThemeData.dark(useMaterial3: true);
    final contrastOverlay = highContrast ? Colors.white.withOpacity(0.06) : Colors.transparent;
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: secondary,
        background: backgroundDark,
        surface: highContrast ? const Color(0xFF0F0F0F) : cardDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: highContrast ? const Color(0xFF0F0F0F) : cardDark,
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
        bodyColor: textPrimaryDark,
        displayColor: textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: (highContrast ? const Color(0xFF0F0F0F) : cardDark).withOpacity(0.98),
        selectedColor: primaryColor.withOpacity(0.24),
        labelStyle: TextStyle(color: textPrimaryDark, fontWeight: highContrast ? FontWeight.w600 : null),
      ),
      cardTheme: CardTheme(shadowColor: contrastOverlay),
      pageTransitionsTheme: reduceMotion
          ? const PageTransitionsTheme(builders: {
              TargetPlatform.android: NoTransitionsBuilder(),
              TargetPlatform.iOS: NoTransitionsBuilder(),
              TargetPlatform.macOS: NoTransitionsBuilder(),
              TargetPlatform.windows: NoTransitionsBuilder(),
              TargetPlatform.linux: NoTransitionsBuilder(),
              TargetPlatform.fuchsia: NoTransitionsBuilder(),
            })
          : base.pageTransitionsTheme,
    );
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
