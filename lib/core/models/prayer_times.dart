import 'city.dart';

enum PrayerName { fajr, sunrise, dhuhr, asr, maghrib, isha }

extension PrayerNameX on PrayerName {
  String get label => switch (this) {
        PrayerName.fajr => 'Subuh',
        PrayerName.sunrise => 'Terbit',
        PrayerName.dhuhr => 'Dzuhur',
        PrayerName.asr => 'Ashar',
        PrayerName.maghrib => 'Maghrib',
        PrayerName.isha => 'Isya',
      };

  String get arabic => switch (this) {
        PrayerName.fajr => 'الفجر',
        PrayerName.sunrise => 'الشروق',
        PrayerName.dhuhr => 'الظهر',
        PrayerName.asr => 'العصر',
        PrayerName.maghrib => 'المغرب',
        PrayerName.isha => 'العشاء',
      };

  String get key => name;

  bool get isPrayer => this != PrayerName.sunrise;
}

/// Prayer calculation conventions. Angles are degrees below the horizon.
enum CalculationMethod {
  kemenag(
    label: 'Kemenag',
    description: 'Kementerian Agama RI · Fajr 20°, Isya 18°',
    fajrAngle: 20,
    ishaAngle: 18,
  ),
  mwl(
    label: 'Muslim World League',
    description: 'Fajr 18°, Isya 17°',
    fajrAngle: 18,
    ishaAngle: 17,
  ),
  isna(
    label: 'ISNA',
    description: 'Islamic Society of North America · 15° / 15°',
    fajrAngle: 15,
    ishaAngle: 15,
  ),
  egypt(
    label: 'Egyptian Authority',
    description: 'Fajr 19,5°, Isya 17,5°',
    fajrAngle: 19.5,
    ishaAngle: 17.5,
  ),
  ummAlQura(
    label: 'Umm al-Qura',
    description: 'Fajr 18,5° · Isya 90 menit setelah Maghrib',
    fajrAngle: 18.5,
    ishaAngle: null,
    ishaIntervalMinutes: 90,
  );

  const CalculationMethod({
    required this.label,
    required this.description,
    required this.fajrAngle,
    required this.ishaAngle,
    this.ishaIntervalMinutes,
  });

  final String label;
  final String description;
  final double fajrAngle;
  final double? ishaAngle;
  final int? ishaIntervalMinutes;

  static CalculationMethod fromKey(String? key) {
    return CalculationMethod.values.firstWhere(
      (method) => method.name == key,
      orElse: () => CalculationMethod.kemenag,
    );
  }
}

enum AsrMadhab {
  shafi(label: "Syafi'i", factor: 1),
  hanafi(label: 'Hanafi', factor: 2);

  const AsrMadhab({required this.label, required this.factor});

  final String label;
  final int factor;

  static AsrMadhab fromKey(String? key) {
    return AsrMadhab.values.firstWhere(
      (madhab) => madhab.name == key,
      orElse: () => AsrMadhab.shafi,
    );
  }
}

class PrayerScheduleEntry {
  const PrayerScheduleEntry({
    required this.name,
    required this.time,
  });

  final PrayerName name;
  final DateTime time;
}

class PrayerTimes {
  const PrayerTimes({
    required this.city,
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.method,
    required this.madhab,
    this.highLatitudeFallback = false,
  });

  final City city;
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final CalculationMethod method;
  final AsrMadhab madhab;
  final bool highLatitudeFallback;

  DateTime timeFor(PrayerName name) => switch (name) {
        PrayerName.fajr => fajr,
        PrayerName.sunrise => sunrise,
        PrayerName.dhuhr => dhuhr,
        PrayerName.asr => asr,
        PrayerName.maghrib => maghrib,
        PrayerName.isha => isha,
      };

  List<PrayerScheduleEntry> get entries => <PrayerScheduleEntry>[
        PrayerScheduleEntry(name: PrayerName.fajr, time: fajr),
        PrayerScheduleEntry(name: PrayerName.sunrise, time: sunrise),
        PrayerScheduleEntry(name: PrayerName.dhuhr, time: dhuhr),
        PrayerScheduleEntry(name: PrayerName.asr, time: asr),
        PrayerScheduleEntry(name: PrayerName.maghrib, time: maghrib),
        PrayerScheduleEntry(name: PrayerName.isha, time: isha),
      ];

  List<PrayerScheduleEntry> get prayers =>
      entries.where((entry) => entry.name.isPrayer).toList(growable: false);

  /// Returns the next prayer on this date, or `null` after Isya.
  PrayerScheduleEntry? nextPrayerAfter(DateTime now) {
    for (final entry in prayers) {
      if (entry.time.isAfter(now)) return entry;
    }
    return null;
  }

  /// The prayer window that is currently active. Before Fajr this returns
  /// yesterday's Isya conceptually, so the UI uses "menuju Subuh" instead.
  PrayerScheduleEntry? activePrayerAt(DateTime now) {
    PrayerScheduleEntry? active;
    for (final entry in prayers) {
      if (!entry.time.isAfter(now)) {
        active = entry;
      }
    }
    return active;
  }

  PrayerTimes copyWithDate(DateTime newDate) => PrayerTimes(
        city: city,
        date: newDate,
        fajr: _atDate(fajr, newDate),
        sunrise: _atDate(sunrise, newDate),
        dhuhr: _atDate(dhuhr, newDate),
        asr: _atDate(asr, newDate),
        maghrib: _atDate(maghrib, newDate),
        isha: _atDate(isha, newDate),
        method: method,
        madhab: madhab,
        highLatitudeFallback: highLatitudeFallback,
      );

  static DateTime _atDate(DateTime time, DateTime date) => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
}
