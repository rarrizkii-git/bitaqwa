import 'package:flutter/material.dart';

import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/external_url.dart';

/// Shown whenever an embedded player cannot be created (non-web builds, or an
/// invalid video ID). The original YouTube link always remains available.
///
/// The widget fills whatever space its parent provides — normally a 16:9 box —
/// and switches to a compact arrangement when that box is too short for the
/// full explanation. Without this, the fallback overflowed its player frame on
/// phone-sized screens.
class YoutubeEmbedUnavailable extends StatelessWidget {
  const YoutubeEmbedUnavailable({
    super.key,
    required this.title,
    required this.fallbackUrl,
  });

  final String title;
  final String fallbackUrl;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 240 || constraints.maxWidth < 380;
        return Container(
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          padding: EdgeInsets.all(compact ? 14 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!compact) ...<Widget>[
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: 38,
                  color: palette.primary,
                ),
                const SizedBox(height: 12),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: compact
                      ? Theme.of(context).textTheme.bodyMedium
                      : Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  compact
                      ? 'Pemutar tersemat hanya tersedia di versi web.'
                      : 'Pemutar tersemat hanya tersedia di versi web. '
                          'Kajian tetap dapat disimak melalui sumber aslinya.',
                  maxLines: compact ? 1 : 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: palette.muted),
                ),
              ),
              SizedBox(height: compact ? 8 : 12),
              TextButton.icon(
                onPressed: () => openExternalUrl(fallbackUrl),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Buka di YouTube'),
              ),
            ],
          ),
        );
      },
    );
  }
}
