/// YouTube video identifier helpers.
///
/// Playback is always delegated to YouTube, so the application never needs to
/// download or re-host a video. Keeping parsing and validation in one place
/// makes it impossible for a malformed ID to reach the embed player.
abstract final class YoutubeVideo {
  static final RegExp _idPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

  static bool isValidId(String value) => _idPattern.hasMatch(value);

  /// Extracts a video ID from a raw ID or any common YouTube URL form.
  ///
  /// Returns `null` when the input cannot be resolved to a valid 11-character
  /// YouTube video ID.
  static String? parseId(String input) {
    final value = input.trim();
    if (value.isEmpty) return null;
    if (isValidId(value)) return value;

    final uri = Uri.tryParse(value) ??
        Uri.tryParse('https://$value');
    if (uri == null || uri.host.isEmpty) return null;

    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);

    String? candidate;

    if (host == 'youtu.be') {
      candidate = segments.isNotEmpty ? segments.first : null;
    } else if (host == 'youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'music.youtube.com') {
      if (segments.length >= 2 &&
          (segments.first == 'shorts' ||
              segments.first == 'embed' ||
              segments.first == 'live' ||
              segments.first == 'v')) {
        candidate = segments[1];
      } else {
        candidate = uri.queryParameters['v'];
      }
    }

    return candidate != null && isValidId(candidate) ? candidate : null;
  }

  static String watchUrl(String videoId) =>
      'https://www.youtube.com/watch?v=$videoId';
}
