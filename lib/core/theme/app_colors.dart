import 'package:flutter/material.dart';

/// Brand colours for Bitaqwa.
///
/// The palette is intentionally small: emerald, warm neutrals and a restrained
/// gold accent. Everything else is derived from these tokens in [AppTheme].
abstract final class AppColors {
  static const emerald = Color(0xFF126B4F);
  static const deepEmerald = Color(0xFF064E3B);
  static const softEmerald = Color(0xFFE6F1EB);
  static const warmBeige = Color(0xFFF5EFE3);
  static const cream = Color(0xFFFCFAF6);
  static const white = Color(0xFFFFFFFF);
  static const darkText = Color(0xFF202923);

  static const mutedText = Color(0xFF5E6B63);
  static const border = Color(0xFFE7E1D4);
  static const gold = Color(0xFFB08A4F);

  // Dark theme counterparts.
  static const night = Color(0xFF07130F);
  static const nightSurface = Color(0xFF0D1C16);
  static const nightSurfaceAlt = Color(0xFF12251D);
  static const nightBorder = Color(0xFF22382D);
  static const nightText = Color(0xFFF1F5F0);
  static const nightMuted = Color(0xFF9FB2A7);
  static const emeraldLight = Color(0xFF48C99D);
  static const goldLight = Color(0xFFD6B77C);

  static const success = Color(0xFF1E8A63);
  static const danger = Color(0xFFB4544B);
}
