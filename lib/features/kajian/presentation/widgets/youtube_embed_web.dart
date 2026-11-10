import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

final Set<String> _registeredEmbeds = <String>{};

/// Web implementation that embeds the original YouTube player.
///
/// The privacy-enhanced domain is used, autoplay is disabled, and no video is
/// downloaded or mirrored. The user always interacts with YouTube's own player.
Widget buildYoutubeEmbed({
  required String videoId,
  required String title,
  required String fallbackUrl,
}) {
  final viewType = 'bitaqwa-youtube-$videoId';

  if (_registeredEmbeds.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe
        ..src = 'https://www.youtube-nocookie.com/embed/$videoId'
            '?rel=0&modestbranding=1&playsinline=1'
        ..title = title
        ..allow =
            'accelerometer; clipboard-write; encrypted-media; gyroscope; '
            'picture-in-picture; web-share'
        ..referrerPolicy = 'strict-origin-when-cross-origin'
        ..allowFullscreen = true
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
      iframe.setAttribute('allowfullscreen', 'true');
      iframe.setAttribute('loading', 'lazy');
      return iframe;
    });
  }

  return HtmlElementView(viewType: viewType);
}
