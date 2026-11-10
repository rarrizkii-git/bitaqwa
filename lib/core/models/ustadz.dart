import 'package:flutter/foundation.dart';

/// A verified teacher whose lectures are published in the Kajian Online
/// catalogue.
///
/// Biographies are intentionally limited to what can be observed on the
/// cited YouTube channel. Credentials are only included when they appear in
/// the source video titles.
@immutable
class Ustadz {
  const Ustadz({
    required this.id,
    required this.name,
    required this.honorific,
    required this.bio,
    required this.channelName,
    required this.channelUrl,
    required this.verified,
    this.credentials,
    this.imageUrl,
  });

  final String id;

  /// Name without the honorific, e.g. `Khalid Basalamah`.
  final String name;

  /// `Ustadz`, `Syaikh`, or a title verified from the source channel.
  final String honorific;

  final String bio;
  final String channelName;
  final String channelUrl;
  final bool verified;

  /// Academic or professional credentials shown by the source channel, if any.
  final String? credentials;

  final String? imageUrl;

  String get displayName => '$honorific $name';

  /// Initials used for the monogram avatar when no verified portrait exists.
  String get monogram {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
