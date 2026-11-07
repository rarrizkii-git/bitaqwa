import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/duas.dart';
import '../../../../core/models/dua.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/clipboard.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/page_scaffold.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/brand.dart';
import '../../../../shared/widgets/islamic_art.dart';
import '../../../../shared/widgets/reveal.dart';

class DuaPreviewSection extends ConsumerWidget {
  const DuaPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final dua = Duas.duaOfTheDay(DateTime.now());

    return Container(
      color: palette.surfaceAlt,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IslamicPattern(
              color: palette.pattern,
              opacity: context.isDarkMode ? 0.028 : 0.032,
              spacing: 82,
            ),
          ),
          Padding(
            padding: context.sectionPadding,
            child: ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SectionHeading(
                    eyebrow: 'Doa & Zikir',
                    title: 'Doa untuk setiap momen kecil.',
                    subtitle:
                        'Dari bangun tidur hingga sebelum perjalanan. Setiap doa disertai sumber, transliterasi, dan terjemahan agar mudah diamalkan.',
                    trailing: Reveal(
                      child: AppTextLink(
                        label: 'Jelajahi semua doa',
                        onTap: () => context.go('/doa'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 960;
                      final card = Reveal(
                        offset: 0.1,
                        child: _DuaOfDayCard(dua: dua),
                      );
                      final side = Reveal(
                        delay: const Duration(milliseconds: 120),
                        child: const _CategoryPanel(),
                      );
                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            card,
                            const SizedBox(height: 20),
                            side,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(flex: 11, child: card),
                          const SizedBox(width: 22),
                          Expanded(flex: 7, child: side),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaOfDayCard extends ConsumerWidget {
  const _DuaOfDayCard({required this.dua});

  final Dua dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final bookmarked = ref.watch(duaBookmarksProvider).contains(dua.id);

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                .withValues(alpha: context.isDarkMode ? 0.28 : 0.06),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SoftBadge(
                label: 'DOA HARI INI',
                icon: Icons.wb_sunny_outlined,
                color: palette.gold,
              ),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    ref.read(duaBookmarksProvider.notifier).toggle(dua.id),
                tooltip: bookmarked
                    ? 'Hapus doa dari bookmark'
                    : 'Simpan doa ke bookmark',
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: bookmarked ? palette.gold : palette.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            dua.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 25,
                  color: palette.text,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            dua.category.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: palette.primary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            decoration: BoxDecoration(
              color: palette.primarySoft.withValues(
                alpha: context.isDarkMode ? 0.42 : 0.55,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              dua.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: AppTypography.arabic(
                fontSize: context.responsive(mobile: 24.0, desktop: 28.0),
                color: palette.primaryDeep,
                height: 1.9,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            dua.latin,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.65,
              color: palette.muted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dua.translation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.text,
                  height: 1.7,
                ),
          ),
          if (dua.note != null) ...<Widget>[
            const SizedBox(height: 12),
            SourceNote(text: dua.note!),
          ],
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Icon(
                Icons.menu_book_outlined,
                size: 14,
                color: palette.gold,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  dua.source,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: palette.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              AppButton(
                label: 'Salin doa',
                icon: Icons.copy_rounded,
                size: AppButtonSize.compact,
                variant: AppButtonVariant.secondary,
                onPressed: () => copyWithFeedback(
                  context,
                  '${dua.title}\n\n${dua.arabic}\n\n${dua.latin}\n\n'
                  '${dua.translation}\n\nSumber: ${dua.source}',
                  message: '${dua.title} disalin.',
                ),
              ),
              AppButton(
                label: 'Semua doa',
                trailingIcon: Icons.arrow_forward_rounded,
                size: AppButtonSize.compact,
                onPressed: () => context.go('/doa'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  const _CategoryPanel();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Jelajahi doa',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih suasana hati atau kebutuhanmu.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                ),
          ),
          const SizedBox(height: 20),
          for (final category in DuaCategory.values)
            _CategoryRow(
              category: category,
              count: Duas.all
                  .where((dua) => dua.category == category)
                  .length,
            ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  palette.primaryDeep,
                  palette.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CrescentMark(size: 22, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  'Zikir yang menenangkan',
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Penghitung zikir dengan target dan riwayat tersimpan.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.55,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Buka zikir',
                  trailingIcon: Icons.arrow_forward_rounded,
                  size: AppButtonSize.compact,
                  variant: AppButtonVariant.inverted,
                  onPressed: () => context.go('/zikir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.count});

  final DuaCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.go('/doa?kategori=${category.name}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: <Widget>[
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: palette.text,
                  ),
                ),
                const Spacer(),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: palette.muted,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: palette.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
