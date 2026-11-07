import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cities.dart';
import '../data/dhikr_presets.dart';
import '../models/city.dart';
import '../models/dhikr.dart';
import '../models/prayer_times.dart';
import '../models/quran_text.dart';
import '../services/preferences_service.dart';
import '../services/quran_api.dart';
import '../utils/prayer_calculator.dart';

/// Overridden in `main.dart` with an initialised instance.
final preferencesProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('preferencesProvider must be overridden');
});

// ---------------------------------------------------------------------------
// Appearance & preferences
// ---------------------------------------------------------------------------

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(preferencesProvider).readThemeMode();

  void setMode(ThemeMode mode) {
    if (state == mode) return;
    state = mode;
    unawaited(ref.read(preferencesProvider).writeThemeMode(mode));
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ReduceMotionNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesProvider).readReduceMotion();

  void setValue(bool value) {
    state = value;
    unawaited(ref.read(preferencesProvider).writeReduceMotion(value));
  }
}

final reduceMotionProvider =
    NotifierProvider<ReduceMotionNotifier, bool>(ReduceMotionNotifier.new);

class ArabicScaleNotifier extends Notifier<double> {
  @override
  double build() => ref.read(preferencesProvider).readArabicScale();

  void setValue(double value) {
    state = value.clamp(0.8, 1.5);
    unawaited(ref.read(preferencesProvider).writeArabicScale(state));
  }
}

final arabicScaleProvider =
    NotifierProvider<ArabicScaleNotifier, double>(ArabicScaleNotifier.new);

class ShowTranslationNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesProvider).readShowTranslation();

  void setValue(bool value) {
    state = value;
    unawaited(ref.read(preferencesProvider).writeShowTranslation(value));
  }
}

final showTranslationProvider =
    NotifierProvider<ShowTranslationNotifier, bool>(
  ShowTranslationNotifier.new,
);

class ShowLatinNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesProvider).readShowLatin();

  void setValue(bool value) {
    state = value;
    unawaited(ref.read(preferencesProvider).writeShowLatin(value));
  }
}

final showLatinProvider =
    NotifierProvider<ShowLatinNotifier, bool>(ShowLatinNotifier.new);

// ---------------------------------------------------------------------------
// Location & prayer settings
// ---------------------------------------------------------------------------

class SelectedCityNotifier extends Notifier<City> {
  @override
  City build() {
    final id = ref.read(preferencesProvider).readCityId();
    return id == null ? Cities.jakarta : Cities.byId(id);
  }

  void select(City city) {
    if (city == state) return;
    state = city;
    unawaited(ref.read(preferencesProvider).writeCityId(city.id));
  }
}

final selectedCityProvider =
    NotifierProvider<SelectedCityNotifier, City>(SelectedCityNotifier.new);

class CalculationMethodNotifier extends Notifier<CalculationMethod> {
  @override
  CalculationMethod build() => CalculationMethod.fromKey(
        ref.read(preferencesProvider).readCalculationMethod(),
      );

  void select(CalculationMethod method) {
    state = method;
    unawaited(ref.read(preferencesProvider).writeCalculationMethod(method.name));
  }
}

final calculationMethodProvider =
    NotifierProvider<CalculationMethodNotifier, CalculationMethod>(
  CalculationMethodNotifier.new,
);

class AsrMadhabNotifier extends Notifier<AsrMadhab> {
  @override
  AsrMadhab build() =>
      AsrMadhab.fromKey(ref.read(preferencesProvider).readAsrMadhab());

  void select(AsrMadhab madhab) {
    state = madhab;
    unawaited(ref.read(preferencesProvider).writeAsrMadhab(madhab.name));
  }
}

final asrMadhabProvider =
    NotifierProvider<AsrMadhabNotifier, AsrMadhab>(AsrMadhabNotifier.new);

final prayerTimesProvider = Provider.family<PrayerTimes, DateTime>((ref, date) {
  final city = ref.watch(selectedCityProvider);
  final method = ref.watch(calculationMethodProvider);
  final madhab = ref.watch(asrMadhabProvider);
  final normalized = DateTime(date.year, date.month, date.day);
  return PrayerCalculator.calculate(
    city: city,
    method: method,
    madhab: madhab,
    date: normalized,
  );
});

final qiblaBearingProvider = Provider<double>((ref) {
  final city = ref.watch(selectedCityProvider);
  return GeoMath.qiblaBearing(
    latitude: city.latitude,
    longitude: city.longitude,
  );
});

final qiblaDistanceProvider = Provider<double>((ref) {
  final city = ref.watch(selectedCityProvider);
  return GeoMath.distanceToKaabaKm(
    latitude: city.latitude,
    longitude: city.longitude,
  );
});

// ---------------------------------------------------------------------------
// Bookmarks & reading state
// ---------------------------------------------------------------------------

class SurahBookmarksNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => ref.read(preferencesProvider).readSurahBookmarks();

  void toggle(int surahNumber) {
    final next = <int>{...state};
    if (!next.add(surahNumber)) next.remove(surahNumber);
    state = Set<int>.unmodifiable(next);
    unawaited(ref.read(preferencesProvider).writeSurahBookmarks(next));
  }

  void clear() {
    state = const <int>{};
    unawaited(ref.read(preferencesProvider).writeSurahBookmarks(const <int>{}));
  }
}

final surahBookmarksProvider =
    NotifierProvider<SurahBookmarksNotifier, Set<int>>(
  SurahBookmarksNotifier.new,
);

class DuaBookmarksNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.read(preferencesProvider).readDuaBookmarks();

  void toggle(String id) {
    final next = <String>{...state};
    if (!next.add(id)) next.remove(id);
    state = Set<String>.unmodifiable(next);
    unawaited(ref.read(preferencesProvider).writeDuaBookmarks(next));
  }

  void clear() {
    state = const <String>{};
    unawaited(
      ref.read(preferencesProvider).writeDuaBookmarks(const <String>{}),
    );
  }
}

final duaBookmarksProvider =
    NotifierProvider<DuaBookmarksNotifier, Set<String>>(
  DuaBookmarksNotifier.new,
);

class LastReadNotifier extends Notifier<int?> {
  @override
  int? build() => ref.read(preferencesProvider).readLastReadSurah();

  void setSurah(int number) {
    state = number;
    unawaited(ref.read(preferencesProvider).writeLastReadSurah(number));
  }

  void clear() {
    state = null;
    unawaited(ref.read(preferencesProvider).writeLastReadSurah(null));
  }
}

final lastReadSurahProvider =
    NotifierProvider<LastReadNotifier, int?>(LastReadNotifier.new);

// ---------------------------------------------------------------------------
// Dhikr
// ---------------------------------------------------------------------------

class DhikrState {
  const DhikrState({
    required this.counts,
    required this.presetId,
    required this.target,
  });

  final Map<String, int> counts;
  final String presetId;
  final int target;

  DhikrPreset get preset => DhikrPresets.byId(presetId);

  int get currentCount => counts[presetId] ?? 0;

  int get totalCount =>
      counts.values.fold(0, (previous, count) => previous + count);

  bool get isComplete => currentCount >= target;

  DhikrState copyWith({
    Map<String, int>? counts,
    String? presetId,
    int? target,
  }) {
    return DhikrState(
      counts: counts ?? this.counts,
      presetId: presetId ?? this.presetId,
      target: target ?? this.target,
    );
  }
}

class DhikrNotifier extends Notifier<DhikrState> {
  @override
  DhikrState build() {
    final prefs = ref.read(preferencesProvider);
    final presetId = prefs.readDhikrPreset() ?? DhikrPresets.all.first.id;
    final preset = DhikrPresets.byId(presetId);
    final target = prefs.readDhikrTarget() ?? preset.defaultTarget;
    return DhikrState(
      counts: prefs.readDhikrCounts(),
      presetId: preset.id,
      target: target,
    );
  }

  void selectPreset(DhikrPreset preset) {
    if (state.presetId == preset.id) return;
    state = state.copyWith(
      presetId: preset.id,
      target: preset.defaultTarget,
    );
    final prefs = ref.read(preferencesProvider);
    unawaited(prefs.writeDhikrPreset(preset.id));
    unawaited(prefs.writeDhikrTarget(preset.defaultTarget));
  }

  void setTarget(int target) {
    if (target <= 0 || state.target == target) return;
    state = state.copyWith(target: target);
    unawaited(ref.read(preferencesProvider).writeDhikrTarget(target));
  }

  void increment() {
    final next = <String, int>{...state.counts};
    next[state.presetId] = (next[state.presetId] ?? 0) + 1;
    state = state.copyWith(counts: Map<String, int>.unmodifiable(next));
    unawaited(ref.read(preferencesProvider).writeDhikrCounts(next));
  }

  void decrement() {
    final current = state.counts[state.presetId] ?? 0;
    if (current <= 0) return;
    final next = <String, int>{...state.counts};
    if (current == 1) {
      next.remove(state.presetId);
    } else {
      next[state.presetId] = current - 1;
    }
    state = state.copyWith(counts: Map<String, int>.unmodifiable(next));
    unawaited(ref.read(preferencesProvider).writeDhikrCounts(next));
  }

  void resetActive() {
    final next = <String, int>{...state.counts}..remove(state.presetId);
    state = state.copyWith(counts: Map<String, int>.unmodifiable(next));
    unawaited(ref.read(preferencesProvider).writeDhikrCounts(next));
  }

  void resetAll() {
    state = state.copyWith(counts: const <String, int>{});
    unawaited(
      ref.read(preferencesProvider).writeDhikrCounts(const <String, int>{}),
    );
  }
}

final dhikrProvider =
    NotifierProvider<DhikrNotifier, DhikrState>(DhikrNotifier.new);

// ---------------------------------------------------------------------------
// Scroll state (navbar chrome)
// ---------------------------------------------------------------------------

class NavScrollState {
  const NavScrollState({this.scrolled = false, this.progress = 0});

  final bool scrolled;
  final double progress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavScrollState &&
          other.scrolled == scrolled &&
          other.progress == progress;

  @override
  int get hashCode => Object.hash(scrolled, progress);
}

class NavScrollNotifier extends Notifier<NavScrollState> {
  @override
  NavScrollState build() => const NavScrollState();

  void update(double offset, double maxScrollExtent) {
    final progress = maxScrollExtent <= 0
        ? 0.0
        : (offset / maxScrollExtent).clamp(0.0, 1.0);
    final next = NavScrollState(
      scrolled: offset > 10,
      progress: progress,
    );
    if (next != state) state = next;
  }

  void reset() {
    if (state != const NavScrollState()) {
      state = const NavScrollState();
    }
  }
}

final navScrollProvider =
    NotifierProvider<NavScrollNotifier, NavScrollState>(NavScrollNotifier.new);

// ---------------------------------------------------------------------------
// Qur'an API
// ---------------------------------------------------------------------------

final quranApiProvider = Provider<QuranApi>((ref) => QuranApi());

final surahTextProvider = FutureProvider.family<SurahText, int>((ref, number) {
  return ref.watch(quranApiProvider).fetchSurah(number);
});
