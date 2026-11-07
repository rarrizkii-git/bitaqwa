import 'package:flutter/foundation.dart';

@immutable
class Ayah {
  const Ayah({
    required this.number,
    required this.arabic,
    required this.latin,
    required this.translation,
  });

  final int number;
  final String arabic;
  final String latin;
  final String translation;
}

@immutable
class SurahText {
  const SurahText({
    required this.surahNumber,
    required this.ayahs,
    required this.fetchedAt,
  });

  final int surahNumber;
  final List<Ayah> ayahs;
  final DateTime fetchedAt;
}
