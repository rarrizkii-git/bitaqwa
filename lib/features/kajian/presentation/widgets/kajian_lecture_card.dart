import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/lecture.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../shared/widgets/reveal.dart';
import 'kajian_visuals.dart';

class KajianLectureCard extends ConsumerStatefulWidget {
  const KajianLectureCard({super.key, required this.lecture});

  final Lecture lecture;

  @override
  ConsumerState<KajianLectureCard> createState() => _KajianLectureCardState();
}

class _KajianLectureCardState extends ConsumerState<KajianLectureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final lecture = widget.lecture;
    final catalog = ref.watch(kajianCatalogProvider);
    final ustadz = catalog.ustadzOf(lecture);
    final bookmarked = ref.watch(kajianBookmarksProvider).contains(lecture.id);

    void open() => context.go('/kajian/${lecture.id}');

    return Semantics(
      button: true,
      label: 'Buka kajian ${lecture.title}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovered
                  ? palette.primary.withValues(alpha: 0.36)
                  : palette.border,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                    .withValues(alpha: context.isDarkMode ? 0.2 : 0.035),
                blurRadius: _hovered ? 22 : 12,
                offset: Offset(0, _hovered ? 12 : 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: open,
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: <Widget>[
                        KajianThumbnail(lecture: lecture),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Tooltip(
                            message: bookmarked
                                ? 'Hapus dari kajian tersimpan'
                                : 'Simpan kajian',
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: Semantics(
                                button: true,
                                label: bookmarked
                                    ? 'Hapus ${lecture.title} dari kajian tersimpan'
                                    : 'Simpan ${lecture.title} ke kajian tersimpan',
                                child: InkWell(
                                  onTap: () => ref
                                      .read(kajianBookmarksProvider.notifier)
                                      .toggle(lecture.id),
                                  customBorder: const CircleBorder(),
                                  // 48x48 keeps the tap target inside the
                                  // accessibility minimum; the visible disc
                                  // stays at 34 so the thumbnail is not
                                  // crowded.
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.42,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          bookmarked
                                              ? Icons.bookmark_rounded
                                              : Icons.bookmark_border_rounded,
                                          size: 18,
                                          color: bookmarked
                                              ? palette.gold
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: KajianCategoryTag(
                                  category: lecture.category,
                                ),
                              ),
                              if (lecture.featured)
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 12,
                                  color: palette.goldInk.withValues(alpha: 0.9),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lecture.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontSize: 20,
                                  height: 1.24,
                                  letterSpacing: -0.3,
                                  color: palette.text,
                                ),
                          ),
                          const Spacer(),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  ustadz?.displayName ?? 'Ustadz',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: palette.muted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: _hovered
                                    ? palette.primary
                                    : palette.muted,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KajianLectureGrid extends StatelessWidget {
  const KajianLectureGrid({
    super.key,
    required this.lectures,
    this.stagger = true,
  });

  final List<Lecture> lectures;
  final bool stagger;

  @override
  Widget build(BuildContext context) {
    if (lectures.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1040 ? 3 : (width >= 660 ? 2 : 1);
        final gap = width >= 660 ? 20.0 : 16.0;
        final cardWidth = (width - gap * (columns - 1)) / columns;
        final thumbnailHeight = (cardWidth - 16) * 9 / 16;
        final cardHeight = thumbnailHeight + 158;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (int i = 0; i < lectures.length; i++)
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: stagger
                    ? StaggeredReveal(
                        index: i > 8 ? 8 : i,
                        child: KajianLectureCard(lecture: lectures[i]),
                      )
                    : KajianLectureCard(lecture: lectures[i]),
              ),
          ],
        );
      },
    );
  }
}
