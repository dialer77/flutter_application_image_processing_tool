import 'package:flutter/material.dart';

class AppTheme {
  // 기본 색상 팔레트
  static const Color primaryColor = Color(0xFF37474F);
  static const Color secondaryColor = Color(0xFF455A64);
  static const Color accentColor = Color(0xFF607D8B);

  // 배경 색상
  static const Color scaffoldBackground = Color(0xFFECEFF1);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFFAFAFA);
  static const Color paletteBackground = Color(0xFFE0E0E0);
  static const Color editorBackground = Color(0xFFF8F9FA);

  // 텍스트 색상
  static const Color primaryText = Color(0xFF37474F);
  static const Color secondaryText = Color(0xFF455A64);
  static const Color mutedText = Color(0xFF757575);

  // 테두리 색상
  static const Color borderColor = Color(0xFFBDBDBD);
  static const Color activeBorderColor = Color(0xFF1565C0);

  // 아이콘 색상
  static const Color iconColor = Color(0xFF607D8B);
  static const Color deleteIconColor = Color(0xFFD32F2F);

  // 버튼 색상
  static const Color successButtonColor = Color(0xFF2E7D32);
  static const Color dangerButtonColor = Color(0xFFD32F2F);

  // 블록 색상
  static const Map<String, Color> blockColors = {
    'loadImage': Color(0xFF2E7D32),
    'grayscale': Color(0xFF1565C0),
    'blur': Color(0xFFEF6C00),
    'brightness': Color(0xFF6A1B9A),
    'display': Color(0xFFC62828),
  };

  // Material 테마 생성
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blueGrey,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
