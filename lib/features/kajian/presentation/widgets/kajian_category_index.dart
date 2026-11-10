import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/lecture.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/bitaqwa_palette.dart';

class KajianCategoryIndex extends ConsumerWidget {
  const KajianCategoryIndex({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(kajianCatalogProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 820;
        if (!twoColumns) {
          return Column(
            children: <Widget>[
              for (final category in LectureCategory.values)
                _CategoryRow(
                  category: category,
                  count: catalog.countForCategory(category),
                ),
            ],
          );
        }

        const gap = 40.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: 0,
          children: <Widget>[
            for (final category in LectureCategory.values)
              SizedBox(
                width: width,
                child: _CategoryRow(
                  category: category,
                  count: catalog.countForCategory(category),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryRow extends StatefulWidget {
  const _CategoryRow({required this.category, required this.count});

  final LectureCategory category;
  final int count;

  @override
  State<_CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final category = widget.category;

    return Semantics(
      button: true,
      label: 'Buka tema ${category.label}, ${widget.count} kajian',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.border)),
          ),
          child: Material(
            color: _hovered
                ? palette.surfaceAlt.withValues(
                    alpha: context.isDarkMode ? 0.45 : 0.55,
                  )
                : Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/kajian/kategori/${category.slug}'),
              child: SizedBox(
                height: 112,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 82,
                        child: Text(
                          category.arabicLabel,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.arabic(
                            fontSize: 17,
                            height: 1.6,
                            color: palette.goldInk,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              category.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 15.5,
                                    color: _hovered
                                        ? palette.primary
                                        : palette.text,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              category.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: palette.muted, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${widget.count}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: palette.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSlide(
                        offset: _hovered ? const Offset(0.2, 0) : Offset.zero,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: _hovered ? palette.primary : palette.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
