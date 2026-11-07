import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/data/surahs.dart';
import '../../../core/models/surah.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/hover_card.dart';
import '../../../shared/widgets/islamic_art.dart';
import '../../../shared/widgets/reveal.dart';

enum _SurahFilter { all, popular, bookmarks }

class QuranPage extends ConsumerStatefulWidget {
  const QuranPage({super.key});

  @override
  ConsumerState<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends ConsumerState<QuranPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _SurahFilter _filter = _SurahFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Surah> _results(Set<int> bookmarks) {
    var list = Surahs.search(_query);
    if (_filter == _SurahFilter.popular) {
      list = list
          .where((surah) => Surahs.popular.contains(surah.number))
          .toList(growable: false);
    } else if (_filter == _SurahFilter.bookmarks) {
      list = list
          .where((surah) => bookmarks.contains(surah.number))
          .toList(growable: false);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bookmarks = ref.watch(surahBookmarksProvider);
    final lastRead = ref.watch(lastReadSurahProvider);
    final results = _results(bookmarks);
    final totalAyahs =
        Surahs.all.fold<int>(0, (sum, surah) => sum + surah.ayahCount);

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: "Al-Qur'an",
            title: 'Setiap ayat, ruang untuk merenung.',
            description:
                'Baca 114 surah dengan teks Arab Uthmani, transliterasi Latin, dan terjemahan bahasa Indonesia. Atur tampilan sesuai kenyamananmu.',
            action: lastRead == null
                ? null
                : AppButton(
                    label: 'Lanjutkan ${Surahs.byNumber(lastRead).name}',
                    trailingIcon: Icons.arrow_forward_rounded,
                    size: AppButtonSize.compact,
                    onPressed: () => context.go('/quran/$lastRead'),
                  ),
            meta: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                const SoftBadge(
                  label: '114 surah',
                  icon: Icons.menu_book_outlined,
                ),
                SoftBadge(
                  label: '${totalAyahs.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ayat',
                  icon: Icons.format_list_numbered_rounded,
                  color: palette.gold,
                ),
                const SoftBadge(
                  label: AppConstants.quranTranslation,
                  icon: Icons.translate_rounded,
                ),
              ],
            ),
          ),
          Container(
            color: palette.background,
            padding: EdgeInsets.only(
              left: context.pageGutter,
              right: context.pageGutter,
              top: context.isMobile ? 34 : 44,
              bottom: context.isMobile ? 56 : 84,
            ),
            child: ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (lastRead != null) ...<Widget>[
                    Reveal(
                      child: _ContinueReadingBanner(
                        surah: Surahs.byNumber(lastRead),
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                  _Toolbar(
                    controller: _searchController,
                    query: _query,
                    filter: _filter,
                    resultCount: results.length,
                    onChanged: (value) => setState(() => _query = value),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    onFilter: (filter) => setState(() => _filter = filter),
                  ),
                  const SizedBox(height: 26),
                  if (results.isEmpty)
                    _EmptyState(
                      bookmarksEmpty: _filter == _SurahFilter.bookmarks,
                      query: _query,
                      onReset: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                          _filter = _SurahFilter.all;
                        });
                      },
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const gap = 16.0;
                        final width = constraints.maxWidth;
                        final columns = width >= 1080
                            ? 3
                            : width >= 680
                                ? 2
                                : 1;
                        final cardWidth =
                            (width - gap * (columns - 1)) / columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: <Widget>[
                            for (int i = 0; i < results.length; i++)
                              SizedBox(
                                width: cardWidth,
                                child: StaggeredReveal(
                                  index: i > 12 ? 12 : i,
                                  child: _SurahTile(
                                    surah: results[i],
                                    bookmarked:
                                        bookmarks.contains(results[i].number),
                                    isLastRead:
                                        results[i].number == lastRead,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                  const SourceNote(
                    text:
                        'Teks Arab dan terjemahan dimuat langsung dari Al Quran Cloud (api.alquran.cloud). '
                        'Bitaqwa tidak menyalin teks secara manual. Terjemahan dapat berbeda antar penerbit; '
                        'rujuk mushaf dan ulama untuk pemahaman yang lebih dalam.',
                    icon: Icons.cloud_outlined,
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

class _ContinueReadingBanner extends StatelessWidget {
  const _ContinueReadingBanner({required this.surah});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color(0xFF083F2F), Color(0xFF0E6C50)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              size: 19,
              color: Color(0xFFE8D4A8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'TERAKHIR DIBACA',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: Colors.white.withValues(alpha: 0.58),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${surah.name} \u00b7 ${surah.translation}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => context.go('/quran/${surah.number}'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE8D4A8),
            ),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.query,
    required this.filter,
    required this.resultCount,
    required this.onChanged,
    required this.onClear,
    required this.onFilter,
  });

  final TextEditingController controller;
  final String query;
  final _SurahFilter filter;
  final int resultCount;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<_SurahFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final filters = <(_SurahFilter, String, IconData)>[
      (_SurahFilter.all, 'Semua surah', Icons.grid_view_rounded),
      (_SurahFilter.popular, 'Populer', Icons.star_outline_rounded),
      (_SurahFilter.bookmarks, 'Bookmark', Icons.bookmark_border_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final search = TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari surah, arti, atau nomor\u2026',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClear,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          tooltip: 'Hapus pencarian',
                        ),
                ),
              );
              final chips = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final item in filters)
                    _FilterChip(
                      label: item.$2,
                      icon: item.$3,
                      selected: filter == item.$1,
                      onTap: () => onFilter(item.$1),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Center(
                      child: Text(
                        '$resultCount surah',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: palette.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              );
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    search,
                    const SizedBox(height: 12),
                    chips,
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Expanded(flex: 5, child: search),
                  const SizedBox(width: 16),
                  Expanded(flex: 6, child: chips),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? palette.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? palette.primary.withValues(alpha: 0.3)
                : palette.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 13,
              color: selected ? palette.primary : palette.muted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? palette.primary : palette.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahTile extends ConsumerWidget {
  const _SurahTile({
    required this.surah,
    required this.bookmarked,
    required this.isLastRead,
  });

  final Surah surah;
  final bool bookmarked;
  final bool isLastRead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return HoverCard(
      padding: const EdgeInsets.all(18),
      onTap: () => context.go('/quran/${surah.number}'),
      semanticLabel: 'Baca surah ${surah.name}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _NumberBadge(number: surah.numberLabel),
              if (isLastRead) ...<Widget>[
                const SizedBox(width: 8),
                SoftBadge(
                  label: 'TERAKHIR',
                  color: palette.gold,
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: () => ref
                    .read(surahBookmarksProvider.notifier)
                    .toggle(surah.number),
                tooltip: bookmarked ? 'Hapus bookmark' : 'Simpan bookmark',
                iconSize: 18,
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
          const SizedBox(height: 14),
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 3),
          Text(
            surah.translation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _MetaIcon(
                icon: Icons.format_list_numbered_rounded,
                label: '${surah.ayahCount} ayat',
              ),
              const SizedBox(width: 12),
              _MetaIcon(
                icon: Icons.place_outlined,
                label: surah.revelation.label,
              ),
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

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: palette.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.primary.withValues(alpha: 0.14)),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.primary,
          ),
        ),
      ),
    );
  }
}

class _MetaIcon extends StatelessWidget {
  const _MetaIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 12, color: palette.muted),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: palette.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.bookmarksEmpty,
    required this.query,
    required this.onReset,
  });

  final bool bookmarksEmpty;
  final String query;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: <Widget>[
          ClipOval(
            child: SizedBox(
              width: 96,
              height: 96,
              child: IslamicPattern(
                color: palette.pattern,
                opacity: 0.1,
                spacing: 26,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            bookmarksEmpty
                ? 'Belum ada surah yang disimpan.'
                : 'Surah tidak ditemukan.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                  color: palette.text,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            bookmarksEmpty
                ? 'Ketuk ikon bookmark pada surah mana pun untuk menyimpannya di perangkat ini.'
                : 'Tidak ada hasil untuk \u201c$query\u201d. Coba kata kunci lain atau nomor surah.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: palette.muted),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: bookmarksEmpty ? 'Jelajahi semua surah' : 'Reset pencarian',
            icon: Icons.refresh_rounded,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.compact,
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}
