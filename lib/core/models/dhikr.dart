import 'package:flutter/foundation.dart';

@immutable
class DhikrPreset {
  const DhikrPreset({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.reference,
    required this.defaultTarget,
    this.note,
  });

  final String id;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String reference;
  final int defaultTarget;
  final String? note;
}
