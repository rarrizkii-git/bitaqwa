import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system.
///
/// Fraunces gives the interface a warm editorial voice for headlines, while
/// Plus Jakarta Sans keeps long-form Indonesian copy calm and legible. Amiri is
/// used for Arabic text because of its generous, readable naskh letterforms.
abstract final class AppTypography {
  static const arabicFallback = <String>[
    'Amiri',
    'Noto Naskh Arabic',
    'Traditional Arabic',
    'serif',
  ];

  static TextStyle serif({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      height: height ?? 1.1,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  static TextStyle sans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle arabic({
    double fontSize = 28,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double height = 2.0,
  }) {
    return GoogleFonts.amiri(
  fontSize: fontSize,
  color: color,
  fontWeight: fontWeight,
  height: height,
).copyWith(
  fontFamilyFallback: arabicFallback,
);
  }

  static TextTheme textTheme({required Color text, required Color muted}) {
    final display = serif(color: text);
    final body = sans(color: text);

    return TextTheme(
      displayLarge: display.copyWith(
        fontSize: 64,
        height: 1.04,
        letterSpacing: -2.2,
        fontWeight: FontWeight.w500,
      ),
      displayMedium: display.copyWith(
        fontSize: 52,
        height: 1.08,
        letterSpacing: -1.6,
      ),
      displaySmall: display.copyWith(
        fontSize: 40,
        height: 1.12,
        letterSpacing: -1.1,
      ),
      headlineLarge: display.copyWith(
        fontSize: 34,
        height: 1.15,
        letterSpacing: -0.8,
      ),
      headlineMedium: display.copyWith(
        fontSize: 28,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      headlineSmall: display.copyWith(
        fontSize: 23,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      titleLarge: body.copyWith(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: body.copyWith(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: body.copyWith(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: body.copyWith(fontSize: 16.5, height: 1.75),
      bodyMedium: body.copyWith(fontSize: 14.5, height: 1.7),
      bodySmall: body.copyWith(fontSize: 13, height: 1.65, color: muted),
      labelLarge: body.copyWith(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: body.copyWith(
        fontSize: 12.5,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: body.copyWith(
        fontSize: 11.5,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: muted,
      ),
    );
  }
}
