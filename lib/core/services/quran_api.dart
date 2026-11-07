import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/quran_text.dart';

class QuranException implements Exception {
  const QuranException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Loads Qur'an text from the public Al Quran Cloud API.
///
/// The Qur'an is never bundled or transcribed by hand here. Text and the
/// Indonesian translation are served by a verified API and clearly attributed
/// in the reading screen.
class QuranApi {
  QuranApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<int, SurahText> _memoryCache = <int, SurahText>{};

  Future<SurahText> fetchSurah(int number) async {
    final cached = _memoryCache[number];
    if (cached != null) return cached;

    final uri = Uri.parse(
      '${AppConstants.quranApiBase}/surah/$number/editions/'
      'quran-uthmani,id.indonesian,en.transliteration',
    );

    http.Response response;
    try {
      response = await _client
          .get(uri, headers: const <String, String>{
            'Accept': 'application/json',
          })
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const QuranException(
        'Sumber Al-Qur\u2019an tidak merespons. Periksa koneksi lalu coba lagi.',
      );
    } catch (_) {
      throw const QuranException(
        'Tidak dapat terhubung ke sumber Al-Qur\u2019an. Periksa koneksi internetmu.',
      );
    }

    if (response.statusCode != 200) {
      throw QuranException(
        'Sumber Al-Qur\u2019an sedang tidak tersedia (${response.statusCode}). Coba lagi nanti.',
      );
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected payload');
      }
      final data = decoded['data'];
      if (data is! List) {
        throw const FormatException('Missing editions');
      }

      Map<String, dynamic>? arabicEdition;
      Map<String, dynamic>? translationEdition;
      Map<String, dynamic>? latinEdition;

      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final edition = item['edition'];
        final identifier = edition is Map
            ? (edition['identifier'] as String? ?? '')
            : '';
        if (identifier.contains('quran-uthmani') ||
            identifier.contains('quran-simple')) {
          arabicEdition = item;
        } else if (identifier.contains('id.indonesian') ||
            identifier.contains('id.kemenag')) {
          translationEdition = item;
        } else if (identifier.contains('transliteration')) {
          latinEdition = item;
        }
      }

      // Fall back to API ordering if an edition identifier is unexpected.
      if (arabicEdition == null && data.isNotEmpty) {
        arabicEdition = data[0] as Map<String, dynamic>;
      }
      if (translationEdition == null && data.length > 1) {
        translationEdition = data[1] as Map<String, dynamic>;
      }
      if (latinEdition == null && data.length > 2) {
        latinEdition = data[2] as Map<String, dynamic>;
      }

      final arabicAyahs = arabicEdition?['ayahs'];
      if (arabicAyahs is! List || arabicAyahs.isEmpty) {
        throw const FormatException('No ayahs');
      }

      final translations = _ayahMap(translationEdition?['ayahs']);
      final latin = _ayahMap(latinEdition?['ayahs']);

      final ayahs = <Ayah>[];
      for (final item in arabicAyahs) {
        if (item is! Map<String, dynamic>) continue;
        final ayahNumber = item['numberInSurah'] is int
            ? item['numberInSurah'] as int
            : ayahs.length + 1;
        ayahs.add(
          Ayah(
            number: ayahNumber,
            arabic: (item['text'] as String? ?? '').trim(),
            latin: latin[ayahNumber] ?? '',
            translation: translations[ayahNumber] ?? '',
          ),
        );
      }

      if (ayahs.isEmpty) {
        throw const FormatException('No ayahs');
      }

      final result = SurahText(
        surahNumber: number,
        ayahs: ayahs,
        fetchedAt: DateTime.now(),
      );
      _memoryCache[number] = result;
      return result;
    } on QuranException {
      rethrow;
    } catch (_) {
      throw const QuranException(
        'Format data Al-Qur\u2019an tidak dikenali. Coba muat ulang halaman.',
      );
    }
  }

  Map<int, String> _ayahMap(dynamic value) {
    if (value is! List) return const <int, String>{};
    final map = <int, String>{};
    for (final item in value) {
      if (item is! Map<String, dynamic>) continue;
      final number = item['numberInSurah'];
      final text = item['text'];
      if (number is int && text is String) {
        map[number] = text.trim();
      }
    }
    return map;
  }
}
