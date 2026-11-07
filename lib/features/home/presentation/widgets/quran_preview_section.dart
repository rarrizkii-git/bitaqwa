import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/surahs.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/page_scaffold.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/brand.dart';
import '../../../../shared/widgets/hover_card.dart';
import '../../../../shared/widgets/islamic_art.dart';
import '../../../../shared/widgets/reveal.dart';

class QuranPreviewSection extends ConsumerWidget {
  const QuranPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final bookmarks = ref.watch(surahBookmarksProvider);
    final lastRead = ref.watch(lastReadSurahProvider);
    final popular = Surahs.popular.map(Surahs.byNumber).toList(growable: false);

    return Container(
      color: palette.background,
      padding: context.sectionPadding,
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeading(
              eyebrow: "Al-Qur'an",
              title: 'Baca dengan tenang, pahami dengan jelas.',
              subtitle:
                  'Teks Arab, transliterasi, dan terjemahan Indonesia ditampilkan berdampingan. Atur ukuran huruf dan simpan surah favoritmu.',
              trailing: Reveal(
                child: AppTextLink(
                  label: 'Lihat 114 surah',
                  onTap: () => context.go('/quran'),
                ),
              ),
            ),
            if (lastRead != null) ...<Widget>[
              const SizedBox(height: 30),
              Reveal(child: _LastReadBanner(surah: Surahs.byNumber(lastRead))),
            ],
            const SizedBox(height: 38),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 18.0;
                final width = constraints.maxWidth;
                final columns = width >= 1000
                    ? 3
                    : width >= 660
                        ? 2
                        : 1;
                final cardWidth =
                    (width - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: <Widget>[
                    for (int i = 0; i < popular.length; i++)
                      SizedBox(
                        width: cardWidth,
                        child: StaggeredReveal(
                          index: i,
                          child: _SurahPreviewCard(
                            surah: popular[i],
                            bookmarked: bookmarks.contains(popular[i].number),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            const SourceNote(
              text:
                  'Teks Al-Qur\u2019an dan terjemahan Indonesia dimuat dari Al Quran Cloud. Bitaqwa tidak menyalin atau mengubah teks secara manual.',
              icon: Icons.cloud_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _LastReadBanner extends StatelessWidget {
  const _LastReadBanner({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF083F2F), Color(0xFF0E7054)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -12,
            top: -38,
            child: Opacity(
              opacity: 0.16,
              child: RotatingStar(size: 130, color: Colors.white, opacity: 1),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'LANJUTKAN BACAAN',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.7,
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Surah ${surah.name}',
                      style: const TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${surah.translation} \u00b7 ${surah.ayahCount} ayat \u00b7 ${surah.revelation.label}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Lanjutkan',
                trailingIcon: Icons.arrow_forward_rounded,
                size: AppButtonSize.compact,
                variant: AppButtonVariant.inverted,
                onPressed: () => context.go('/quran/${surah.number}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurahPreviewCard extends ConsumerWidget {
  const _SurahPreviewCard({required this.surah, required this.bookmarked});

  final Surah surah;
  final bool bookmarked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return HoverCard(
      padding: const EdgeInsets.all(20),
      onTap: () => context.go('/quran/${surah.number}'),
      semanticLabel: 'Baca surah ${surah.name}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.14),
                  ),
                ),
                child: Center(
                  child: Text(
                    surah.numberLabel,
                    style: const TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF126B4F),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => ref
                    .read(surahBookmarksProvider.notifier)
                    .toggle(surah.number),
                tooltip: bookmarked
                    ? 'Hapus ${surah.name} dari bookmark'
                    : 'Simpan ${surah.name} ke bookmark',
                iconSize: 19,
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
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  surah.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 21,
                        color: palette.text,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                surah.arabicName,
                textDirection: TextDirection.rtl,
                style: AppTypography.arabic(
                  fontSize: 20,
                  color: palette.primary,
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            surah.translation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _Meta(label: '${surah.ayahCount} ayat'),
              const SizedBox(width: 8),
              _Meta(label: surah.revelation.label),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: palette.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: palette.muted,
        ),
      ),
    );
  }
}
