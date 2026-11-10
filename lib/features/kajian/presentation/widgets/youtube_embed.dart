import 'package:flutter/material.dart';

import '../../domain/youtube_video.dart';
import 'youtube_embed_stub.dart'
    if (dart.library.js_interop) 'youtube_embed_web.dart'
    as implementation;
import 'youtube_embed_unavailable.dart';

/// YouTube playback is isolated here so the rest of the app never depends on
/// platform-specific embed code.
class YoutubeEmbed extends StatelessWidget {
  const YoutubeEmbed({
    super.key,
    required this.videoId,
    required this.title,
    required this.fallbackUrl,
  });

  final String videoId;
  final String title;
  final String fallbackUrl;

  @override
  Widget build(BuildContext context) {
    if (!YoutubeVideo.isValidId(videoId)) {
      return YoutubeEmbedUnavailable(
        title: 'Video tidak dapat diputar',
        fallbackUrl: fallbackUrl,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: Colors.black,
        child: implementation.buildYoutubeEmbed(
          videoId: videoId,
          title: title,
          fallbackUrl: fallbackUrl,
        ),
      ),
    );
  }
}
