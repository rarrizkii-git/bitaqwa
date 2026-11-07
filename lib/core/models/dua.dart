import 'package:flutter/foundation.dart';

enum DuaCategory {
  harian('Harian'),
  ibadah('Ibadah'),
  perlindungan('Perlindungan'),
  perjalanan('Perjalanan'),
  keluarga('Keluarga'),
  rezeki('Rezeki'),
  kesehatan('Kesehatan'),
  ilmu('Ilmu');

  const DuaCategory(this.label);
  final String label;
}

@immutable
class Dua {
  const Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.source,
    required this.category,
    this.note,
  });

  final String id;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String source;
  final DuaCategory category;
  final String? note;
}
