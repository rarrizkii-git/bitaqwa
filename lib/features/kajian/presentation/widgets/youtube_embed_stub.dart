import 'package:flutter/widgets.dart';

import 'youtube_embed_unavailable.dart';

/// Non-web fallback used by tests and any future desktop build.
Widget buildYoutubeEmbed({
  required String videoId,
  required String title,
  required String fallbackUrl,
}) {
  return YoutubeEmbedUnavailable(title: title, fallbackUrl: fallbackUrl);
}
