import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const seed = Color(0xFF6C63FF);
    //const background = Color(0xFF141A2E);
    const surface = Color(0xFF1B223C);
    const colorScheme = ColorScheme.dark(
      primary: seed,
      secondary: Color(0xFF5AC8FA),
      surface: surface,
    );
    final base = ThemeData.dark();
    final textTheme = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xCC141A2E),
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        elevation: 10,
        color: Color(0xCC1B223C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      shadowColor: const Color(0xFF6C63FF),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF12182C),
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: Color(0x2A6C63FF),
        backgroundColor: Color(0xFF151B2F),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: Colors.white),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: Color(0xFF8A93B2)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        elevation: 1,
        splashColor: Color(0xFF8C88FF),
        shape: StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          shadowColor: const Color(0xFF6C63FF),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: const StadiumBorder(),
          side: const BorderSide(color: Color(0xFF3A4568)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF8A93B2),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B223C),
        hintStyle: const TextStyle(color: Color(0xFF8A93B2)),
        labelStyle: const TextStyle(color: Color(0xFF8A93B2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A3352)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A3352)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
