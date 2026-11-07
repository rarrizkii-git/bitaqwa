import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/data/surahs.dart';
import '../../../core/models/quran_text.dart';
import '../../../core/models/surah.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/clipboard.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/islamic_art.dart';

class SurahDetailPage extends ConsumerStatefulWidget {
  const SurahDetailPage({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  ConsumerState<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends ConsumerState<SurahDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(lastReadSurahProvider.notifier).setSurah(widget.surahNumber);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SurahDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surahNumber != widget.surahNumber) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(lastReadSurahProvider.notifier).setSurah(widget.surahNumber);
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final valid = widget.surahNumber >= 1 && widget.surahNumber <= 114;
    final surah = valid ? Surahs.byNumber(widget.surahNumber) : null;
    final bookmarked =
        ref.watch(surahBookmarksProvider).contains(widget.surahNumber);
    final textAsync = valid ? ref.watch(surahTextProvider(widget.surahNumber)) : null;

    return PageScaffold(
      controller: _scrollController,
      child: Column(
        children: <Widget>[
          _ReaderHeader(
            surah: surah,
            bookmarked: bookmarked,
            onToggleBookmark: surah == null
                ? null
                : () => ref
                    .read(surahBookmarksProvider.notifier)
                    .toggle(surah.number),
          ),
          if (!valid || surah == null)
            const _InvalidSurah()
          else
            Container(
              color: palette.background,
              padding: EdgeInsets.only(
                left: context.pageGutter,
                right: context.pageGutter,
                top: context.isMobile ? 26 : 34,
                bottom: context.isMobile ? 52 : 80,
              ),
              child: ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _ReadingControls(surah: surah),
                    const SizedBox(height: 22),
                    textAsync!.when(
                      data: (text) => _AyahList(surah: surah, text: text),
                      loading: () => const _ReaderLoading(),
                      error: (error, _) => _ReaderError(
                        message: error.toString(),
                        onRetry: () =>
                            ref.invalidate(surahTextProvider(widget.surahNumber)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SourceNote(
                      text:
                          'Teks Al-Qur\u2019an (Uthmani) dan terjemahan bahasa Indonesia dimuat dari Al Quran Cloud. '
                          'Transliterasi Latin berasal dari edisi transliterasi yang disediakan sumber. '
                          'Jika terjemahan terasa kurang tepat, rujuk mushaf dan tafsir terpercaya.',
                      icon: Icons.cloud_outlined,
                    ),
                    const SizedBox(height: 26),
                    _SurahNavigation(number: widget.surahNumber),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReaderHeader extends StatelessWidget {
  const _ReaderHeader({
    required this.surah,
    required this.bookmarked,
    required this.onToggleBookmark,
  });

  final Surah? surah;
  final bool bookmarked;
  final VoidCallback? onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            palette.surfaceAlt.withValues(alpha: 0.8),
            palette.background,
          ],
        ),
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IslamicPattern(
              color: palette.pattern,
              opacity: context.isDarkMode ? 0.04 : 0.035,
              spacing: 54,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: context.isMobile ? 26 : 34,
              bottom: context.isMobile ? 28 : 36,
            ),
            child: ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () => context.go('/quran'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 15,
                            color: palette.primary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Kembali ke daftar surah',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: palette.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (surah == null)
                    Text(
                      'Surah tidak ditemukan',
                      style: Theme.of(context).textTheme.displaySmall,
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 820;
                        final copy = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.primarySoft,
                                    borderRadius: BorderRadius.circular(99),
                                    border: Border.all(
                                      color: palette.primary
                                          .withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Text(
                                    'SURAH ${surah!.number}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.3,
                                      color: palette.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SoftBadge(
                                  label: surah!.revelation.label,
                                  color: palette.gold,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              surah!.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontSize: context.responsive(
                                      mobile: 34.0,
                                      tablet: 42.0,
                                      desktop: 48.0,
                                    ),
                                    letterSpacing: -1.2,
                                    color: palette.text,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${surah!.translation} \u00b7 ${surah!.ayahCount} ayat',
                              style: TextStyle(
                                fontSize: 13,
                                color: palette.muted,
                              ),
                            ),
                          ],
                        );

                        final actions = Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            AppButton(
                              label: bookmarked ? 'Tersimpan' : 'Simpan',
                              icon: bookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              variant: AppButtonVariant.secondary,
                              size: AppButtonSize.compact,
                              onPressed: onToggleBookmark,
                            ),
                            AppButton(
                              label: 'Atur tampilan',
                              icon: Icons.text_fields_rounded,
                              variant: AppButtonVariant.ghost,
                              size: AppButtonSize.compact,
                              onPressed: () => showDialog<void>(
                                context: context,
                                builder: (context) =>
                                    const _ReadingPreferencesDialog(),
                              ),
                            ),
                          ],
                        );

                        if (!wide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              copy,
                              const SizedBox(height: 22),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      surah!.arabicName,
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                      style: AppTypography.arabic(
                                        fontSize: 40,
                                        color: palette.primary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              actions,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(flex: 7, child: copy),
                            const SizedBox(width: 30),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    surah!.arabicName,
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    style: AppTypography.arabic(
                                      fontSize: 46,
                                      color: palette.primary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  actions,
                                ],
                              ),
                            ),
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

class _ReadingControls extends ConsumerWidget {
  const _ReadingControls({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final showTranslation = ref.watch(showTranslationProvider);
    final showLatin = ref.watch(showLatinProvider);
    final scale = ref.watch(arabicScaleProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.translate_rounded, size: 15, color: palette.primary),
              const SizedBox(width: 7),
              Text(
                'Tampilan',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: palette.text,
                ),
              ),
            ],
          ),
          _Toggle(
            label: 'Terjemahan',
            value: showTranslation,
            onChanged: (value) => ref
                .read(showTranslationProvider.notifier)
                .setValue(value),
          ),
          _Toggle(
            label: 'Latin',
            value: showLatin,
            onChanged: (value) =>
                ref.read(showLatinProvider.notifier).setValue(value),
          ),
          Container(
            height: 18,
            width: 1,
            color: palette.border,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: scale <= 0.81
                    ? null
                    : () => ref
                        .read(arabicScaleProvider.notifier)
                        .setValue(scale - 0.1),
                icon: const Icon(Icons.text_decrease_rounded, size: 18),
                tooltip: 'Perkecil huruf Arab',
                visualDensity: VisualDensity.compact,
              ),
              Text(
                '${(scale * 100).round()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: palette.muted,
                ),
              ),
              IconButton(
                onPressed: scale >= 1.49
                    ? null
                    : () => ref
                        .read(arabicScaleProvider.notifier)
                        .setValue(scale + 0.1),
                icon: const Icon(Icons.text_increase_rounded, size: 18),
                tooltip: 'Perbesar huruf Arab',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
        decoration: BoxDecoration(
          color: value ? palette.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: value
                ? palette.primary.withValues(alpha: 0.26)
                : palette.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: value ? palette.primary : palette.muted,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 26,
              height: 16,
              decoration: BoxDecoration(
                color: value ? palette.primary : palette.border,
                borderRadius: BorderRadius.circular(99),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: value ? Colors.white : palette.surface,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahList extends ConsumerWidget {
  const _AyahList({required this.surah, required this.text});

  final Surah surah;
  final SurahText text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTranslation = ref.watch(showTranslationProvider);
    final showLatin = ref.watch(showLatinProvider);
    final scale = ref.watch(arabicScaleProvider);
    final arabicSize = context.responsive(mobile: 26.0, tablet: 29.0, desktop: 31.0) * scale;

    return Column(
      children: <Widget>[
        for (int i = 0; i < text.ayahs.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _AyahCard(
              surah: surah,
              ayah: text.ayahs[i],
              arabicSize: arabicSize,
              showTranslation: showTranslation,
              showLatin: showLatin,
            ),
          ),
      ],
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.surah,
    required this.ayah,
    required this.arabicSize,
    required this.showTranslation,
    required this.showLatin,
  });

  final Surah surah;
  final Ayah ayah;
  final double arabicSize;
  final bool showTranslation;
  final bool showLatin;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.16),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${ayah.number}',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'QS. ${surah.name}: ${ayah.number}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: palette.muted,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => copyWithFeedback(
                  context,
                  '${ayah.arabic}\n\n'
                  '${showLatin && ayah.latin.isNotEmpty ? '${ayah.latin}\n\n' : ''}'
                  '${ayah.translation}\n\n'
                  'QS. ${surah.name}: ${ayah.number} \u00b7 Sumber: ${AppConstants.quranSource}',
                  message: 'Ayat ${ayah.number} disalin.',
                ),
                tooltip: 'Salin ayat ${ayah.number}',
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.copy_rounded,
                  color: palette.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  ayah.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: AppTypography.arabic(
                    fontSize: arabicSize,
                    color: palette.text,
                    height: 1.95,
                  ),
                ),
                if (showLatin && ayah.latin.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    ayah.latin,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      height: 1.7,
                      color: palette.muted,
                    ),
                  ),
                ],
                if (showTranslation && ayah.translation.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  Divider(color: palette.border.withValues(alpha: 0.7)),
                  const SizedBox(height: 10),
                  Text(
                    ayah.translation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.text,
                          height: 1.75,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderLoading extends StatelessWidget {
  const _ReaderLoading();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: palette.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Memuat teks surah\u2026',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Teks diambil langsung dari sumber Al-Qur\u2019an. Butuh koneksi internet.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: palette.muted),
          ),
        ],
      ),
    );
  }
}

class _ReaderError extends StatelessWidget {
  const _ReaderError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.cloud_off_rounded,
            size: 38,
            color: palette.gold,
          ),
          const SizedBox(height: 14),
          Text(
            'Teks surah belum bisa dimuat',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.muted, height: 1.6),
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Coba lagi',
            icon: Icons.refresh_rounded,
            size: AppButtonSize.compact,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _SurahNavigation extends StatelessWidget {
  const _SurahNavigation({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final previous = number > 1 ? Surahs.byNumber(number - 1) : null;
    final next = number < 114 ? Surahs.byNumber(number + 1) : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 620;
        final prev = _NavCard(
          label: 'SEBELUMNYA',
          surah: previous,
          alignEnd: false,
          onTap: previous == null
              ? null
              : () => context.go('/quran/${previous.number}'),
        );
        final nextCard = _NavCard(
          label: 'BERIKUTNYA',
          surah: next,
          alignEnd: true,
          onTap: next == null ? null : () => context.go('/quran/${next.number}'),
        );
        if (!wide) {
          return Column(
            children: <Widget>[
              prev,
              const SizedBox(height: 12),
              nextCard,
            ],
          );
        }
        return Row(
          children: <Widget>[
            Expanded(child: prev),
            const SizedBox(width: 14),
            Expanded(child: nextCard),
          ],
        );
      },
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.label,
    required this.surah,
    required this.alignEnd,
    required this.onTap,
  });

  final String label;
  final Surah? surah;
  final bool alignEnd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: enabled
              ? palette.surface
              : palette.surfaceAlt.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          crossAxisAlignment:
              alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment:
                  alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: <Widget>[
                if (!alignEnd) ...<Widget>[
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 13,
                    color: enabled ? palette.primary : palette.muted,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: enabled ? palette.gold : palette.muted,
                  ),
                ),
                if (alignEnd) ...<Widget>[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: enabled ? palette.primary : palette.muted,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              surah?.name ?? 'Tidak ada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: enabled ? palette.text : palette.muted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (surah != null)
              Text(
                surah!.translation,
                style: TextStyle(fontSize: 10.5, color: palette.muted),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReadingPreferencesDialog extends ConsumerWidget {
  const _ReadingPreferencesDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final scale = ref.watch(arabicScaleProvider);
    final showTranslation = ref.watch(showTranslationProvider);
    final showLatin = ref.watch(showLatinProvider);

    return AlertDialog(
      title: const Text('Tampilan bacaan'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Ukuran huruf Arab',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.muted,
              ),
            ),
            Slider(
              value: scale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              onChanged: (value) =>
                  ref.read(arabicScaleProvider.notifier).setValue(value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Terjemahan'),
              value: showTranslation,
              onChanged: (value) =>
                  ref.read(showTranslationProvider.notifier).setValue(value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Transliterasi Latin'),
              value: showLatin,
              onChanged: (value) =>
                  ref.read(showLatinProvider.notifier).setValue(value),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Selesai'),
        ),
      ],
    );
  }
}

class _InvalidSurah extends StatelessWidget {
  const _InvalidSurah();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.palette.background,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              'Surah tidak ditemukan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Nomor surah yang diminta tidak valid. Al-Qur\u2019an terdiri dari 114 surah.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.palette.muted),
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'Kembali ke daftar surah',
              icon: Icons.menu_book_outlined,
              size: AppButtonSize.compact,
              onPressed: () => context.go('/quran'),
            ),
          ],
        ),
      ),
    );
  }
}
