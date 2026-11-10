import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme-aware brand palette exposed through [ThemeData.extensions].
///
/// Keeping these colours in a [ThemeExtension] means widgets never have to
/// branch on brightness manually, and theme transitions interpolate smoothly.
@immutable
class BitaqwaPalette extends ThemeExtension<BitaqwaPalette> {
  const BitaqwaPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.primaryDeep,
    required this.primarySoft,
    required this.text,
    required this.muted,
    required this.border,
    required this.gold,
    required this.goldInk,
    required this.heroPanel,
    required this.heroArch,
    required this.pattern,
    required this.navSurface,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color primary;
  final Color primaryDeep;
  final Color primarySoft;
  final Color text;
  final Color muted;
  final Color border;
  final Color gold;

  /// Gold tone reserved for small text and metadata, where [gold] would not
  /// reach an accessible contrast ratio on light surfaces.
  final Color goldInk;
  final Color heroPanel;
  final Color heroArch;
  final Color pattern;
  final Color navSurface;

  static const light = BitaqwaPalette(
    background: AppColors.cream,
    surface: AppColors.white,
    surfaceAlt: AppColors.warmBeige,
    primary: AppColors.emerald,
    primaryDeep: AppColors.deepEmerald,
    primarySoft: AppColors.softEmerald,
    text: AppColors.darkText,
    muted: AppColors.mutedText,
    border: AppColors.border,
    gold: AppColors.gold,
    goldInk: AppColors.goldInk,
    heroPanel: Color(0xFFF1EADB),
    heroArch: Color(0xFFFCFAF6),
    pattern: AppColors.emerald,
    navSurface: Color(0xF7FCFAF6),
  );

  static const dark = BitaqwaPalette(
    background: AppColors.night,
    surface: AppColors.nightSurface,
    surfaceAlt: AppColors.nightSurfaceAlt,
    primary: AppColors.emeraldLight,
    primaryDeep: Color(0xFF0B3B2C),
    primarySoft: Color(0xFF143428),
    text: AppColors.nightText,
    muted: AppColors.nightMuted,
    border: AppColors.nightBorder,
    gold: AppColors.goldLight,
    goldInk: AppColors.goldLight,
    heroPanel: Color(0xFF0F241C),
    heroArch: Color(0xFF0A1A14),
    pattern: Color(0xFF9FD4BC),
    navSurface: Color(0xF707130F),
  );

  @override
  BitaqwaPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? primary,
    Color? primaryDeep,
    Color? primarySoft,
    Color? text,
    Color? muted,
    Color? border,
    Color? gold,
    Color? goldInk,
    Color? heroPanel,
    Color? heroArch,
    Color? pattern,
    Color? navSurface,
  }) {
    return BitaqwaPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      primary: primary ?? this.primary,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      primarySoft: primarySoft ?? this.primarySoft,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      gold: gold ?? this.gold,
      goldInk: goldInk ?? this.goldInk,
      heroPanel: heroPanel ?? this.heroPanel,
      heroArch: heroArch ?? this.heroArch,
      pattern: pattern ?? this.pattern,
      navSurface: navSurface ?? this.navSurface,
    );
  }

  @override
  BitaqwaPalette lerp(ThemeExtension<BitaqwaPalette>? other, double t) {
    if (other is! BitaqwaPalette) return this;
    return BitaqwaPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldInk: Color.lerp(goldInk, other.goldInk, t)!,
      heroPanel: Color.lerp(heroPanel, other.heroPanel, t)!,
      heroArch: Color.lerp(heroArch, other.heroArch, t)!,
      pattern: Color.lerp(pattern, other.pattern, t)!,
      navSurface: Color.lerp(navSurface, other.navSurface, t)!,
    );
  }
}

extension BitaqwaPaletteContext on BuildContext {
  BitaqwaPalette get palette =>
      Theme.of(this).extension<BitaqwaPalette>() ?? BitaqwaPalette.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
