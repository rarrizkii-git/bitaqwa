import 'package:flutter/foundation.dart';

@immutable
class City {
  const City({
    required this.id,
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.utcOffset,
    required this.timezoneLabel,
  });

  final String id;
  final String name;
  final String region;
  final double latitude;
  final double longitude;

  /// Fixed UTC offset in hours. See the note on the prayer page: daylight
  /// saving transitions are not applied to international cities.
  final double utcOffset;
  final String timezoneLabel;

  String get label => '$name, $region';

  String get shortLabel => name;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'region': region,
        'latitude': latitude,
        'longitude': longitude,
        'utcOffset': utcOffset,
        'timezoneLabel': timezoneLabel,
      };

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String? ?? 'jakarta',
      name: json['name'] as String? ?? 'Jakarta',
      region: json['region'] as String? ?? 'Indonesia',
      latitude: (json['latitude'] as num?)?.toDouble() ?? -6.2088,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 106.8456,
      utcOffset: (json['utcOffset'] as num?)?.toDouble() ?? 7,
      timezoneLabel: json['timezoneLabel'] as String? ?? 'WIB (UTC+7)',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City &&
          other.id == id &&
          other.name == name &&
          other.region == region &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.utcOffset == utcOffset;

  @override
  int get hashCode =>
      Object.hash(id, name, region, latitude, longitude, utcOffset);
}
