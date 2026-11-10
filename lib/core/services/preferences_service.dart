import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences]. All user data stays on the device;
/// Bitaqwa has no accounts and makes no analytics calls.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'bitaqwa.theme_mode';
  static const _reduceMotionKey = 'bitaqwa.reduce_motion';
  static const _arabicScaleKey = 'bitaqwa.arabic_scale';
  static const _showTranslationKey = 'bitaqwa.show_translation';
  static const _showLatinKey = 'bitaqwa.show_latin';
  static const _cityKey = 'bitaqwa.city';
  static const _methodKey = 'bitaqwa.calc_method';
  static const _madhabKey = 'bitaqwa.asr_madhab';
  static const _surahBookmarksKey = 'bitaqwa.surah_bookmarks';
  static const _duaBookmarksKey = 'bitaqwa.dua_bookmarks';
  static const _kajianBookmarksKey = 'bitaqwa.kajian_bookmarks';
  static const _lastReadKey = 'bitaqwa.last_read';
  static const _dhikrCountsKey = 'bitaqwa.dhikr_counts';
  static const _dhikrPresetKey = 'bitaqwa.dhikr_preset';
  static const _dhikrTargetKey = 'bitaqwa.dhikr_target';

  ThemeMode readThemeMode() {
    final value = _prefs.getString(_themeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> writeThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  bool readReduceMotion() => _prefs.getBool(_reduceMotionKey) ?? false;

  Future<void> writeReduceMotion(bool value) =>
      _prefs.setBool(_reduceMotionKey, value);

  double readArabicScale() => _prefs.getDouble(_arabicScaleKey) ?? 1.0;

  Future<void> writeArabicScale(double value) =>
      _prefs.setDouble(_arabicScaleKey, value);

  bool readShowTranslation() =>
      _prefs.getBool(_showTranslationKey) ?? true;

  Future<void> writeShowTranslation(bool value) =>
      _prefs.setBool(_showTranslationKey, value);

  bool readShowLatin() => _prefs.getBool(_showLatinKey) ?? true;

  Future<void> writeShowLatin(bool value) =>
      _prefs.setBool(_showLatinKey, value);

  String? readCityId() => _prefs.getString(_cityKey);

  Future<void> writeCityId(String id) => _prefs.setString(_cityKey, id);

  String? readCalculationMethod() => _prefs.getString(_methodKey);

  Future<void> writeCalculationMethod(String value) =>
      _prefs.setString(_methodKey, value);

  String? readAsrMadhab() => _prefs.getString(_madhabKey);

  Future<void> writeAsrMadhab(String value) =>
      _prefs.setString(_madhabKey, value);

  Set<int> readSurahBookmarks() {
    final raw = _prefs.getStringList(_surahBookmarksKey) ?? const <String>[];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> writeSurahBookmarks(Set<int> bookmarks) => _prefs.setStringList(
        _surahBookmarksKey,
        bookmarks.map((id) => id.toString()).toList(growable: false),
      );

  Set<String> readDuaBookmarks() =>
      (_prefs.getStringList(_duaBookmarksKey) ?? const <String>[]).toSet();

  Future<void> writeDuaBookmarks(Set<String> bookmarks) =>
      _prefs.setStringList(_duaBookmarksKey, bookmarks.toList(growable: false));

  Set<String> readKajianBookmarks() =>
      (_prefs.getStringList(_kajianBookmarksKey) ?? const <String>[]).toSet();

  Future<void> writeKajianBookmarks(Set<String> bookmarks) =>
      _prefs.setStringList(_kajianBookmarksKey, bookmarks.toList(growable: false));

  int? readLastReadSurah() => _prefs.getInt(_lastReadKey);

  Future<void> writeLastReadSurah(int? number) {
    if (number == null) return _prefs.remove(_lastReadKey);
    return _prefs.setInt(_lastReadKey, number);
  }

  Map<String, int> readDhikrCounts() {
    final raw = _prefs.getString(_dhikrCountsKey);
    if (raw == null || raw.isEmpty) return <String, int>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, int>{};
      return decoded.map(
        (key, value) => MapEntry(
          key.toString(),
          value is int ? value : int.tryParse(value.toString()) ?? 0,
        ),
      );
    } catch (_) {
      return <String, int>{};
    }
  }

  Future<void> writeDhikrCounts(Map<String, int> counts) =>
      _prefs.setString(_dhikrCountsKey, jsonEncode(counts));

  String? readDhikrPreset() => _prefs.getString(_dhikrPresetKey);

  Future<void> writeDhikrPreset(String id) =>
      _prefs.setString(_dhikrPresetKey, id);

  int? readDhikrTarget() => _prefs.getInt(_dhikrTargetKey);

  Future<void> writeDhikrTarget(int target) =>
      _prefs.setInt(_dhikrTargetKey, target);

  Future<void> clearBookmarks() async {
    await _prefs.remove(_surahBookmarksKey);
    await _prefs.remove(_duaBookmarksKey);
    await _prefs.remove(_kajianBookmarksKey);
    await _prefs.remove(_lastReadKey);
  }

  Future<void> clearDhikr() async {
    await _prefs.remove(_dhikrCountsKey);
    await _prefs.remove(_dhikrPresetKey);
    await _prefs.remove(_dhikrTargetKey);
  }

  Future<void> resetPreferences() async {
    await _prefs.remove(_themeKey);
    await _prefs.remove(_reduceMotionKey);
    await _prefs.remove(_arabicScaleKey);
    await _prefs.remove(_showTranslationKey);
    await _prefs.remove(_showLatinKey);
    await _prefs.remove(_cityKey);
    await _prefs.remove(_methodKey);
    await _prefs.remove(_madhabKey);
  }
}
