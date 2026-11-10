import 'package:flutter/material.dart';

import '../../../../core/models/lecture.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/islamic_art.dart';

IconData kajianCategoryIcon(LectureCategory category) {
  return switch (category) {
    LectureCategory.aqidah => Icons.account_balance_outlined,
    LectureCategory.fiqih => Icons.balance_rounded,
    LectureCategory.manhaj => Icons.route_outlined,
    LectureCategory.tafsir => Icons.menu_book_outlined,
    LectureCategory.hadits => Icons.format_quote_rounded,
    LectureCategory.akhlak => Icons.favorite_border_rounded,
    LectureCategory.sirah => Icons.history_edu_outlined,
    LectureCategory.tazkiyah => Icons.spa_outlined,
  };
}

/// A consistent 16:9 YouTube thumbnail with graceful fallbacks.
///
/// YouTube does not expose a duration in oEmbed, so the card only shows one
/// when the catalogue has a verified value. If a thumbnail is missing the
/// widget falls back to an on-brand placeholder instead of a broken image.
class KajianThumbnail extends StatelessWidget {
  const KajianThumbnail({
    super.key,
    required this.lecture,
    this.radius = 12,
    this.highResolution = false,
    this.showPlayBadge = true,
    this.showDuration = true,
  });

  final Lecture lecture;
  final double radius;
  final bool highResolution;
  final bool showPlayBadge;
  final bool showDuration;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final primary = highResolution
        ? lecture.highResolutionThumbnailUrl
        : lecture.thumbnailUrl;

    final fallback = Image.network(
      lecture.thumbnailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );

    return Semantics(
      image: true,
      label: 'Sampul kajian ${lecture.title}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // The tinted base keeps the 16:9 frame filled while the image is
              // still downloading, so the card never flashes white or shifts.
              ColoredBox(
                color: palette.primarySoft.withValues(
                  alpha: context.isDarkMode ? 0.5 : 1,
                ),
              ),
              Image.network(
                primary,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
              // A quiet scrim keeps the play badge and duration legible without
              // tinting the whole photograph.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.34),
                      ],
                    ),
                  ),
                ),
              ),
              if (showPlayBadge)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.46),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              if (showDuration && lecture.durationSeconds != null)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatVideoDuration(lecture.durationSeconds!),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: Colors.white.withValues(alpha: 0.94),
                      ),
                    ),
                  ),
                ),
              if (lecture.featured)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: palette.primaryDeep.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: palette.gold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'PILIHAN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        // Fixed light gold: this badge always sits on the dark
                        // image scrim, where the brand gold is too dim.
                        color: AppColors.goldLight,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final palette = context.palette;
    return Container(
      color: palette.primarySoft.withValues(
        alpha: context.isDarkMode ? 0.5 : 1,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          IslamicPattern(
            color: palette.pattern,
            opacity: context.isDarkMode ? 0.05 : 0.08,
            spacing: 30,
          ),
          Center(
            child: Icon(
              Icons.play_circle_outline_rounded,
              size: 38,
              color: palette.primary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class KajianCategoryTag extends StatelessWidget {
  const KajianCategoryTag({
    super.key,
    required this.category,
    this.color,
  });

  final LectureCategory category;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // `goldInk` rather than `gold`: this label is 10px and must stay readable
    // on the light card surface.
    final tone = color ?? palette.goldInk;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            category.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: tone,
            ),
          ),
        ),
      ],
    );
  }
}

class KajianUstadzAvatar extends StatelessWidget {
  const KajianUstadzAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = 52,
    this.radius = 16,
  });

  final String initials;
  final String? imageUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final fallback = Container(
      width: size,
      height: size,
      color: palette.primarySoft.withValues(
        alpha: context.isDarkMode ? 0.55 : 1,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.serif(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w600,
          color: palette.primary,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.14),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? fallback
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
    );
  }
}
