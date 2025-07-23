import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme(String languageCode) {
    final bool isArabic = languageCode == 'ar';

    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: isArabic ? 'Almarai' : 'Poppins',
      textTheme: isArabic ? _getArabicTextTheme() : _getEnglishTextTheme(),
    );
  }

  static TextTheme _getArabicTextTheme() {
    return TextTheme(
      displayLarge:
          GoogleFonts.almarai(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium:
          GoogleFonts.almarai(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall:
          GoogleFonts.almarai(fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge:
          GoogleFonts.almarai(fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium:
          GoogleFonts.almarai(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall:
          GoogleFonts.almarai(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge:
          GoogleFonts.almarai(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium:
          GoogleFonts.almarai(fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall:
          GoogleFonts.almarai(fontSize: 12, fontWeight: FontWeight.w500),
      bodyLarge:
          GoogleFonts.almarai(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium:
          GoogleFonts.almarai(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall:
          GoogleFonts.almarai(fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge:
          GoogleFonts.almarai(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium:
          GoogleFonts.almarai(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall:
          GoogleFonts.almarai(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }

  static TextTheme _getEnglishTextTheme() {
    return TextTheme(
      displayLarge:
          GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium:
          GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall:
          GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge:
          GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium:
          GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall:
          GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge:
          GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium:
          GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall:
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      bodyLarge:
          GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium:
          GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall:
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge:
          GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium:
          GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall:
          GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }

  // Helper method to get font family based on text content
  static String getFontFamily(String text) {
    // Check if text contains Arabic characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text) ? 'Almarai' : 'Poppins';
  }

  // Helper method to get text style based on content
  static TextStyle getTextStyle(
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);

    if (isArabic) {
      return GoogleFonts.almarai(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } else {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }
  }
}
