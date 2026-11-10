import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/lecture.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/brand.dart';
import 'widgets/kajian_lecture_card.dart';
import 'widgets/kajian_empty_state.dart';
import 'widgets/kajian_not_found.dart';
import 'widgets/kajian_page_body.dart';

class KajianCategoryPage extends ConsumerWidget {
  const KajianCategoryPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = LectureCategory.fromSlug(slug);
    if (category == null) {
      return const KajianNotFoundPage(
        eyebrow: 'Tema tidak ditemukan',
        title: 'Tema ini belum tersedia.',
        description:
            'Alamat tema yang kamu buka tidak ada di pustaka Kajian Online. '
            'Kembali ke daftar kajian untuk memilih tema lain.',
      );
    }

    final palette = context.palette;
    final catalog = ref.watch(kajianCatalogProvider);
    final lectures = catalog.byCategory(category);
    final others = LectureCategory.values
        .where((item) => item != category)
        .toList(growable: false);

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Tema kajian',
            title: category.label,
            description: category.description,
            action: context.isDesktop
                ? _CategorySeal(category: category, count: lectures.length)
                : null,
            meta: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SoftBadge(
                  label: '${lectures.length} kajian',
                  icon: Icons.play_circle_outline_rounded,
                ),
                SoftBadge(
                  label: category.arabicLabel,
                  icon: Icons.translate_rounded,
                  color: palette.goldInk,
                ),
                const SoftBadge(
                  label: 'Sumber YouTube asli',
                  icon: Icons.verified_outlined,
                ),
              ],
            ),
          ),
          KajianPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: () => context.go('/kajian'),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Semua kajian'),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        'Diurutkan dari yang terbaru',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (lectures.isEmpty)
                  KajianEmptyState(
                    icon: Icons.play_circle_outline_rounded,
                    title: 'Tema ini sedang kosong',
                    description:
                        'Belum ada kajian pada tema ini. '
                        'Silakan kembali lagi nanti atau jelajahi tema lain.',
                    actionLabel: 'Kembali ke semua kajian',
                    onAction: () => context.go('/kajian'),
                  )
                else
                  KajianLectureGrid(lectures: lectures),
                const SizedBox(height: 52),
                Divider(color: palette.border, height: 1),
                const SizedBox(height: 30),
                Text(
                  'Tema lain',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final item in others)
                      _CategoryChip(category: item),
                  ],
                ),
                const SizedBox(height: 34),
                const SourceNote(
                  text:
                      'Setiap kajian pada tema ini menautkan video aslinya di YouTube. '
                      'Judul, kanal, durasi, dan tanggal terbit sudah diperiksa sebelum '
                      'dimasukkan ke pustaka.',
                  icon: Icons.verified_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySeal extends StatelessWidget {
  const _CategorySeal({required this.category, required this.count});

  final LectureCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                .withValues(alpha: context.isDarkMode ? 0.24 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            category.arabicLabel,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.arabic(
              fontSize: 23,
              color: palette.goldInk,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count kajian',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final LectureCategory category;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/kajian/kategori/${category.slug}'),
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.goldInk,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                category.label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: palette.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
