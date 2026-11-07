import 'package:flutter/foundation.dart';

enum Revelation {
  makkiyah('Makkiyah'),
  madaniyah('Madaniyah');

  const Revelation(this.label);
  final String label;
}

@immutable
class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.translation,
    required this.ayahCount,
    required this.revelation,
  });

  final int number;
  final String name;
  final String arabicName;
  final String translation;
  final int ayahCount;
  final Revelation revelation;

  String get numberLabel => number.toString().padLeft(3, '0');
}
