import 'package:flutter/material.dart';

class AppTheme {
  //renkler
  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color terracotta = Color(0xFFC4956A);
  static const Color terracottaLight = Color(0xFFF0E8DC);
  static const Color textPrimary = Color(0xFF2C2420);
  static const Color textSecondary = Color(0xFF9A8478);
  static const Color border = Color(0xFFEDE8E3);

  //text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0.5,
  );
}