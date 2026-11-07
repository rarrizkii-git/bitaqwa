import 'dart:math' as math;

import '../models/city.dart';
import '../models/prayer_times.dart';

/// Local astronomical prayer-time calculation.
///
/// The implementation follows the standard solar position / hour-angle method
/// used by prayer-time calculators (NOAA solar equations, depression angles).
/// It does not call a third-party service, so the site keeps working offline.
/// Results are an astronomical estimate and should be verified against the
/// official schedule of the local mosque or authority.
abstract final class PrayerCalculator {
  static const _deg2rad = math.pi / 180.0;
  static const _rad2deg = 180.0 / math.pi;

  static PrayerTimes calculate({
    required City city,
    required CalculationMethod method,
    required AsrMadhab madhab,
    DateTime? date,
  }) {
    final day = date ?? DateTime.now();
    final jd = _julianDay(day);
    final n = jd - 2451545.0;

    final meanLongitude = _normalize360(280.460 + 0.9856474 * n);
    final meanAnomaly = _normalize360(357.528 + 0.9856003 * n) * _deg2rad;
    final apparentLongitude = _normalize360(
      meanLongitude +
          1.915 * math.sin(meanAnomaly) +
          0.020 * math.sin(2 * meanAnomaly),
    );
    final obliquity = 23.439 - 0.0000004 * n;

    final declination = math.asin(
      math.sin(obliquity * _deg2rad) *
          math.sin(apparentLongitude * _deg2rad),
    );

    final rightAscension = _normalize360(
          math.atan2(
                math.cos(obliquity * _deg2rad) *
                    math.sin(apparentLongitude * _deg2rad),
                math.cos(apparentLongitude * _deg2rad),
              ) *
              _rad2deg,
        );

    final equationOfTimeHours =
        _normalize180(meanLongitude - rightAscension) / 15.0;

    // Solar noon in local wall-clock hours.
    final noon = 12 +
        city.utcOffset -
        (city.longitude / 15.0) -
        equationOfTimeHours;

    final latRad = city.latitude * _deg2rad;

    bool highLatitude = false;

    double? hourAngle(double altitude) {
      final cosH =
          (math.sin(altitude * _deg2rad) - math.sin(latRad) * math.sin(declination)) /
              (math.cos(latRad) * math.cos(declination));
      if (cosH.isNaN || cosH < -1 || cosH > 1) return null;
      return math.acos(cosH) * _rad2deg / 15.0;
    }

    final fajrAngle = hourAngle(-method.fajrAngle);
    final sunriseAngle = hourAngle(-0.833);
    final sunsetAngle = sunriseAngle;

    final asrAltitude = math.atan(
          1 /
              (madhab.factor +
                  math.tan((city.latitude - declination * _rad2deg).abs() * _deg2rad)),
        ) *
        _rad2deg;
    final asrAngle = hourAngle(asrAltitude);

    var fajrHours = fajrAngle != null ? noon - fajrAngle : noon - 1.35;
    var sunriseHours = sunriseAngle != null ? noon - sunriseAngle : noon - 0.95;
    var maghribHours = sunsetAngle != null ? noon + sunsetAngle : noon + 0.95;
    final asrHours = asrAngle != null ? noon + asrAngle : noon + 3.2;

    double ishaHours;
    if (method.ishaIntervalMinutes != null) {
      ishaHours = maghribHours + method.ishaIntervalMinutes! / 60.0;
    } else {
      final angle = hourAngle(-(method.ishaAngle ?? 17));
      if (angle == null) {
        ishaHours = noon + 1.35;
      } else {
        ishaHours = noon + angle;
      }
    }

    if (fajrAngle == null || sunriseAngle == null || ishaHours.isNaN) {
      highLatitude = true;
      fajrHours = noon - 1.35;
      sunriseHours = noon - 0.95;
      maghribHours = noon + 0.95;
      if (method.ishaIntervalMinutes == null) {
        ishaHours = noon + 1.35;
      }
    }

    // A small safety margin, as is conventional in printed prayer tables.
    const ihtiyatiMinutes = 2;
    final fajr = _timeOn(day, fajrHours, addMinutes: ihtiyatiMinutes);
    final sunrise = _timeOn(day, sunriseHours);
    final dhuhr = _timeOn(day, noon, addMinutes: ihtiyatiMinutes);
    final asr = _timeOn(day, asrHours, addMinutes: ihtiyatiMinutes);
    final maghrib = _timeOn(day, maghribHours, addMinutes: ihtiyatiMinutes);
    final isha = _timeOn(day, ishaHours, addMinutes: ihtiyatiMinutes);

    return PrayerTimes(
      city: city,
      date: day,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      method: method,
      madhab: madhab,
      highLatitudeFallback: highLatitude,
    );
  }

  static DateTime _timeOn(
    DateTime date,
    double hours, {
    int addMinutes = 0,
  }) {
    final total = (hours * 60).round() + addMinutes;
    final normalized = ((total % 1440) + 1440) % 1440;
    return DateTime(
      date.year,
      date.month,
      date.day,
      normalized ~/ 60,
      normalized % 60,
    );
  }

  static double _julianDay(DateTime date) {
    var year = date.year;
    var month = date.month;
    final day = date.day + 0.5;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    final a = year ~/ 100;
    final b = 2 - a + (a ~/ 4);

    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }

  static double _normalize360(double value) {
    final result = value % 360;
    return result < 0 ? result + 360 : result;
  }

  static double _normalize180(double value) {
    var result = _normalize360(value);
    if (result > 180) result -= 360;
    return result;
  }
}

/// Great-circle bearing and distance helpers used by the Qibla compass.
abstract final class GeoMath {
  static const _kaabaLat = 21.4224779;
  static const _kaabaLng = 39.8251832;

  static double qiblaBearing({
    required double latitude,
    required double longitude,
  }) {
    final lat = latitude * math.pi / 180;
    final kaabaLat = _kaabaLat * math.pi / 180;
    final deltaLng = (_kaabaLng - longitude) * math.pi / 180;

    final y = math.sin(deltaLng);
    final x = math.cos(lat) * math.tan(kaabaLat) -
        math.sin(lat) * math.cos(deltaLng);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  static double distanceToKaabaKm({
    required double latitude,
    required double longitude,
  }) {
    const earthRadius = 6371.0088;
    final lat1 = latitude * math.pi / 180;
    final lat2 = _kaabaLat * math.pi / 180;
    final dLat = ( _kaabaLat - latitude) * math.pi / 180;
    final dLng = (_kaabaLng - longitude) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static String compassPoint(double bearing) {
    const points = <String>[
      'Utara',
      'Timur Laut',
      'Timur',
      'Tenggara',
      'Selatan',
      'Barat Daya',
      'Barat',
      'Barat Laut',
    ];
    final index = ((bearing + 22.5) % 360) ~/ 45;
    return points[index];
  }
}
