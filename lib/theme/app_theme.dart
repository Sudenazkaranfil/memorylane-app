import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ana Renkler
  static const Color background = Color(0xFFFDFAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color terracotta = Color(0xFFC4956A);
  static const Color terracottaLight = Color(0xFFF5EFE8);
  static const Color terracottaDark = Color(0xFF8B6440);
  static const Color sage = Color(0xFF5B8A6F);
  static const Color sageLight = Color(0xFFEAF3EE);
  static const Color navDark = Color(0xFF4A3222);
  static const Color cardBg = Color(0xFFFCF9F6);

  // Text Renkleri
  static const Color textPrimary = Color(0xFF1C110A);
  static const Color textSecondary = Color(0xFF786D66);
  static const Color textMuted = Color(0xFFB8A898);

  // Border
  static const Color border = Color(0xFFE5DACF);
  static const Color borderStrong = Color(0xFFEADBCE);

  // ThemeData
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: terracotta,
      colorScheme: ColorScheme.light(
        primary: terracotta,
        secondary: sage,
        surface: surface,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      textTheme: TextTheme(
        // Serif başlıklar — Playfair Display
        displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 32, fontWeight: FontWeight.w700,
            color: textPrimary, letterSpacing: -0.5),
        displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 26, fontWeight: FontWeight.w700,
            color: textPrimary, letterSpacing: -0.5),
        displaySmall: GoogleFonts.playfairDisplay(
            fontSize: 22, fontWeight: FontWeight.w700,
            color: textPrimary),
        headlineMedium: GoogleFonts.playfairDisplay(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: textPrimary),
        headlineSmall: GoogleFonts.playfairDisplay(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: textPrimary),
        // Sans body — Plus Jakarta Sans
        titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w400,
            color: textPrimary, height: 1.6),
        bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w400,
            color: textPrimary, height: 1.5),
        bodySmall: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
        labelSmall: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: terracotta,
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: border, width: 1)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: border, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: terracotta, width: 1.5)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13, color: textMuted),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: border, width: 0.5)),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 0.5),
    );
  }

  // Yardımcı metodlar
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: border, width: 0.5),
    boxShadow: [softShadow],
  );

  static BoxShadow get softShadow => BoxShadow(
    color: const Color(0xFF1C110A).withOpacity(0.06),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: const Color(0xFF1C110A).withOpacity(0.09),
    blurRadius: 28,
    spreadRadius: -4,
    offset: const Offset(0, 10),
  );

  static BoxShadow get floatingDockShadow => BoxShadow(
    color: const Color(0xFF1C110A).withOpacity(0.38),
    blurRadius: 36,
    spreadRadius: -6,
    offset: const Offset(0, 16),
  );

  // Dot grid arka plan
  static BoxDecoration get dotGridDecoration => BoxDecoration(
    color: background,
    image: const DecorationImage(
      image: AssetImage('assets/images/dot_grid.png'),
      repeat: ImageRepeat.repeat,
    ),
  );

  // Font helper metodlar
  static TextStyle serifDisplay(
      {double size = 22,
        FontWeight weight = FontWeight.w700,
        Color? color,
        bool italic = false}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: weight,
        color: color ?? textPrimary,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  static TextStyle sansBody(
      {double size = 14,
        FontWeight weight = FontWeight.w400,
        Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? textPrimary,
      );

  static TextStyle handwriting(
      {double size = 16,
        FontWeight weight = FontWeight.w400,
        Color? color}) =>
      GoogleFonts.caveat(
        fontSize: size,
        fontWeight: weight,
        color: color ?? textPrimary,
      );
}