import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/lecture.dart';
import '../../../../core/models/ustadz.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/reveal.dart';
import 'kajian_visuals.dart';

class KajianFeaturedPanel extends StatelessWidget {
  const KajianFeaturedPanel({
    super.key,
    required this.lectures,
  });

  final List<Lecture> lectures;

  @override
  Widget build(BuildContext context) {
    if (lectures.isEmpty) return const SizedBox.shrink();

    final primary = lectures.first;
    final companions = lectures.skip(1).take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Reveal(child: _FeaturedPrimary(lecture: primary)),
        if (companions.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          Reveal(
            delay: const Duration(milliseconds: 120),
            child: _CompanionList(lectures: companions),
          ),
        ],
      ],
    );
  }
}

class _FeaturedPrimary extends ConsumerStatefulWidget {
  const _FeaturedPrimary({required this.lecture});

  final Lecture lecture;

  @override
  ConsumerState<_FeaturedPrimary> createState() => _FeaturedPrimaryState();
}

class _FeaturedPrimaryState extends ConsumerState<_FeaturedPrimary> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final lecture = widget.lecture;
    final catalog = ref.watch(kajianCatalogProvider);
    final ustadz = catalog.ustadzOf(lecture);
    final bookmarked = ref.watch(kajianBookmarksProvider).contains(lecture.id);

    void open() => context.go('/kajian/${lecture.id}');

    final content = _FeaturedContent(
      lecture: lecture,
      ustadz: ustadz,
      bookmarked: bookmarked,
      onOpen: open,
      onToggleBookmark: () =>
          ref.read(kajianBookmarksProvider.notifier).toggle(lecture.id),
    );

    final media = KajianThumbnail(
      lecture: lecture,
      radius: 16,
      highResolution: true,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hovered
                ? palette.primary.withValues(alpha: 0.34)
                : palette.border,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                  .withValues(alpha: context.isDarkMode ? 0.24 : 0.05),
              blurRadius: _hovered ? 30 : 18,
              offset: Offset(0, _hovered ? 16 : 9),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: open,
            borderRadius: BorderRadius.circular(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 860) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      media,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                        child: content,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(flex: 7, child: media),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 22, 26, 22),
                        child: content,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedContent extends StatelessWidget {
  const _FeaturedContent({
    required this.lecture,
    required this.ustadz,
    required this.bookmarked,
    required this.onOpen,
    required this.onToggleBookmark,
  });

  final Lecture lecture;
  final Ustadz? ustadz;
  final bool bookmarked;
  final VoidCallback onOpen;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final channel = ustadz?.channelName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        KajianCategoryTag(category: lecture.category),
        const SizedBox(height: 12),
        Text(
          lecture.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 30,
                height: 1.18,
                letterSpacing: -0.7,
                color: palette.text,
              ),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            KajianUstadzAvatar(
              initials: ustadz?.monogram ?? '?',
              imageUrl: ustadz?.imageUrl,
              size: 34,
              radius: 10,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ustadz?.displayName ?? 'Ustadz',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: palette.text,
                    ),
                  ),
                  if (channel != null)
                    Text(
                      channel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.muted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          lecture.hasDescription
              ? lecture.description!
              : 'Kajian ${lecture.category.label} dari kanal $channel. '
                  'Putar langsung dari sumber aslinya di YouTube.',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.muted,
                height: 1.65,
              ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            AppButton(
              label: 'Tonton kajian',
              icon: Icons.play_arrow_rounded,
              size: AppButtonSize.compact,
              onPressed: onOpen,
            ),
            AppButton(
              label: bookmarked ? 'Tersimpan' : 'Simpan',
              icon: bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              size: AppButtonSize.compact,
              variant: AppButtonVariant.secondary,
              onPressed: onToggleBookmark,
            ),
          ],
        ),
      ],
    );
  }
}

class _CompanionList extends StatelessWidget {
  const _CompanionList({required this.lectures});

  final List<Lecture> lectures;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 780) {
            return Column(
              children: <Widget>[
                for (int i = 0; i < lectures.length; i++) ...<Widget>[
                  _CompanionTile(lecture: lectures[i]),
                  if (i < lectures.length - 1)
                    Divider(height: 1, color: palette.border),
                ],
              ],
            );
          }

          return SizedBox(
            height: 104,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < lectures.length; i++) ...<Widget>[
                  Expanded(child: _CompanionTile(lecture: lectures[i])),
                  if (i < lectures.length - 1)
                    VerticalDivider(width: 1, color: palette.border),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompanionTile extends ConsumerWidget {
  const _CompanionTile({required this.lecture});

  final Lecture lecture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final ustadz = ref.watch(kajianCatalogProvider).ustadzOf(lecture);

    return InkWell(
      onTap: () => context.go('/kajian/${lecture.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 112,
              child: KajianThumbnail(
                lecture: lecture,
                radius: 10,
                showPlayBadge: false,
                showDuration: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  KajianCategoryTag(category: lecture.category),
                  const SizedBox(height: 5),
                  Text(
                    lecture.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.serif(
                      fontSize: 14.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ustadz?.name ?? 'Ustadz',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
