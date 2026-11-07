import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/duas.dart';
import '../../../core/models/dua.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/clipboard.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/reveal.dart';

class DuaPage extends ConsumerStatefulWidget {
  const DuaPage({super.key});

  @override
  ConsumerState<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends ConsumerState<DuaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  DuaCategory? _category;
  bool _bookmarksOnly = false;

  /// Tracks the last `?kategori=` value we applied so that a category chosen
  /// from a chip is never overwritten by an unrelated dependency change.
  String? _appliedCategoryParam;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final param = GoRouterState.of(context).uri.queryParameters['kategori'];
    if (param != _appliedCategoryParam) {
      _appliedCategoryParam = param;
      _category = _categoryFromParam(param);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DuaCategory? _categoryFromParam(String? value) {
    if (value == null) return null;
    for (final category in DuaCategory.values) {
      if (category.name == value) return category;
    }
    return null;
  }

  List<Dua> _results(Set<String> bookmarks) {
    var list = Duas.search(_query, category: _category);
    if (_bookmarksOnly) {
      list = list.where((dua) => bookmarks.contains(dua.id)).toList(
            growable: false,
          );
    }
    return list;
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
      _bookmarksOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bookmarks = ref.watch(duaBookmarksProvider);
    final results = _results(bookmarks);

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Doa & Zikir',
            title: 'Doa yang menyertai setiap langkah.',
            description:
                'Dari bangun tidur hingga kembali beristirahat. Setiap doa dilengkapi teks Arab, '
                'transliterasi, terjemahan, dan sumber agar mudah dipahami serta diamalkan.',
            action: AppButton(
              label: 'Penghitung zikir',
              icon: Icons.spa_outlined,
              trailingIcon: Icons.arrow_forward_rounded,
              size: AppButtonSize.compact,
              onPressed: () => context.go('/zikir'),
            ),
            meta: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SoftBadge(
                  label: '${Duas.all.length} doa pilihan',
                  icon: Icons.volunteer_activism_outlined,
                ),
                SoftBadge(
                  label: '${DuaCategory.values.length} kategori',
                  icon: Icons.grid_view_rounded,
                  color: palette.gold,
                ),
                const SoftBadge(
                  label: 'Sumber Al-Qur\u2019an & hadis',
                  icon: Icons.menu_book_outlined,
                ),
              ],
            ),
          ),
          Container(
            color: palette.background,
            padding: EdgeInsets.only(
              left: context.pageGutter,
              right: context.pageGutter,
              top: context.isMobile ? 32 : 44,
              bottom: context.isMobile ? 56 : 84,
            ),
            child: ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Reveal(child: _Toolbar(
                    controller: _searchController,
                    query: _query,
                    bookmarksOnly: _bookmarksOnly,
                    selectedCategory: _category,
                    onChanged: (value) => setState(() => _query = value),
                    onClearSearch: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    onToggleBookmarks: () => setState(
                      () => _bookmarksOnly = !_bookmarksOnly,
                    ),
                    onSelectCategory: (category) {
                      setState(() {
                        _bookmarksOnly = false;
                        _category = category == null
                            ? null
                            : (_category == category ? null : category);
                      });
                    },
                  )),
                  const SizedBox(height: 26),
                  Row(
                    children: <Widget>[
                      Text(
                        _bookmarksOnly
                            ? 'Doa tersimpan'
                            : (_category?.label ?? 'Semua doa'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: palette.primarySoft.withValues(
                            alpha: context.isDarkMode ? 0.55 : 1,
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${results.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: palette.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_query.isNotEmpty ||
                          _category != null ||
                          _bookmarksOnly)
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                          label: const Text('Reset filter'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (results.isEmpty)
                    Reveal(
                      child: _EmptyState(
                        bookmarksOnly: _bookmarksOnly,
                        hasQuery: _query.isNotEmpty,
                        onReset: _clearFilters,
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 900 ? 2 : 1;
                        final gap = columns == 2 ? 18.0 : 14.0;
                        final cardWidth =
                            (constraints.maxWidth - gap * (columns - 1)) /
                                columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: <Widget>[
                            for (int i = 0; i < results.length; i++)
                              SizedBox(
                                width: cardWidth,
                                child: StaggeredReveal(
                                  index: i > 10 ? 10 : i,
                                  child: _DuaCard(dua: results[i]),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                  const SourceNote(
                    text:
                        'Setiap doa mencantumkan sumbernya, baik ayat Al-Qur\u2019an maupun riwayat hadis. '
                        'Terjemahan disusun untuk memudahkan pemahaman; untuk pendalaman, rujuk mushaf, '
                        'kitab hadis, dan bimbingan ulama terpercaya.',
                    icon: Icons.fact_check_outlined,
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

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.query,
    required this.bookmarksOnly,
    required this.selectedCategory,
    required this.onChanged,
    required this.onClearSearch,
    required this.onToggleBookmarks,
    required this.onSelectCategory,
  });

  final TextEditingController controller;
  final String query;
  final bool bookmarksOnly;
  final DuaCategory? selectedCategory;
  final ValueChanged<String> onChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onToggleBookmarks;
  final ValueChanged<DuaCategory?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final search = TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari doa, arti, atau kategori',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClearSearch,
                          tooltip: 'Hapus pencarian',
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                ),
              );
              final saved = _ToolbarToggle(
                label: 'Tersimpan',
                icon: Icons.bookmark_rounded,
                selected: bookmarksOnly,
                onTap: onToggleBookmarks,
              );
              if (constraints.maxWidth < 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    search,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: saved),
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Expanded(child: search),
                  const SizedBox(width: 12),
                  saved,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _CategoryChip(
                label: 'Semua',
                selected: selectedCategory == null && !bookmarksOnly,
                onTap: () => onSelectCategory(null),
              ),
              for (final category in DuaCategory.values)
                _CategoryChip(
                  label: category.label,
                  selected: selectedCategory == category && !bookmarksOnly,
                  onTap: () => onSelectCategory(category),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolbarToggle extends StatelessWidget {
  const _ToolbarToggle({
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
    return Material(
      color: selected ? palette.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? palette.primary.withValues(alpha: 0.35)
                  : palette.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: selected ? palette.primary : palette.muted,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? palette.primary : palette.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? palette.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? palette.primary : palette.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? (context.isDarkMode ? const Color(0xFF042018) : Colors.white)
                  : palette.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _DuaCard extends ConsumerStatefulWidget {
  const _DuaCard({required this.dua});

  final Dua dua;

  @override
  ConsumerState<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends ConsumerState<_DuaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dua = widget.dua;
    final bookmarked = ref.watch(duaBookmarksProvider).contains(dua.id);
    final arabicScale = ref.watch(arabicScaleProvider);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hovered
                ? palette.primary.withValues(alpha: 0.35)
                : palette.border,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                  .withValues(alpha: context.isDarkMode ? 0.26 : 0.045),
              blurRadius: _hovered ? 26 : 14,
              offset: Offset(0, _hovered ? 14 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SoftBadge(
                  label: dua.category.label,
                  icon: Icons.local_offer_outlined,
                  color: palette.primary,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      ref.read(duaBookmarksProvider.notifier).toggle(dua.id),
                  tooltip: bookmarked
                      ? 'Hapus doa dari bookmark'
                      : 'Simpan doa ke bookmark',
                  visualDensity: VisualDensity.compact,
                  iconSize: 19,
                  icon: Icon(
                    bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: bookmarked ? palette.gold : palette.muted,
                  ),
                ),
                IconButton(
                  onPressed: () => copyWithFeedback(
                    context,
                    '${dua.title}\n\n${dua.arabic}\n\n${dua.latin}\n\n'
                    '${dua.translation}\n\nSumber: ${dua.source}',
                    message: '${dua.title} disalin.',
                  ),
                  tooltip: 'Salin doa',
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  icon: Icon(
                    Icons.copy_rounded,
                    color: palette.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dua.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    color: palette.text,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              decoration: BoxDecoration(
                color: palette.primarySoft.withValues(
                  alpha: context.isDarkMode ? 0.4 : 0.55,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.11),
                ),
              ),
              child: Text(
                dua.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: AppTypography.arabic(
                  fontSize: 25 * arabicScale,
                  color: context.isDarkMode
                      ? const Color(0xFFCDEFE1)
                      : palette.primaryDeep,
                  height: 1.85,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              dua.latin,
              style: TextStyle(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                height: 1.6,
                color: palette.muted,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              dua.translation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.text,
                    height: 1.7,
                  ),
            ),
            if (dua.note != null) ...<Widget>[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt.withValues(
                    alpha: context.isDarkMode ? 0.6 : 0.7,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SourceNote(text: dua.note!, icon: Icons.lightbulb_outline_rounded),
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: palette.border, height: 1),
            const SizedBox(height: 12),
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
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: palette.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.bookmarksOnly,
    required this.hasQuery,
    required this.onReset,
  });

  final bool bookmarksOnly;
  final bool hasQuery;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: palette.primarySoft.withValues(
                alpha: context.isDarkMode ? 0.5 : 1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              bookmarksOnly
                  ? Icons.bookmark_border_rounded
                  : Icons.search_off_rounded,
              size: 28,
              color: palette.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            bookmarksOnly ? 'Belum ada doa tersimpan' : 'Doa tidak ditemukan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            bookmarksOnly
                ? 'Ketuk ikon bookmark pada doa untuk menyimpannya di perangkat ini.'
                : 'Coba kata kunci lain atau pilih kategori yang berbeda.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: palette.muted),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Tampilkan semua doa',
            size: AppButtonSize.compact,
            variant: AppButtonVariant.secondary,
            icon: Icons.restart_alt_rounded,
            onPressed: onReset,
          ),
          if (hasQuery) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              'Pencarian mencakup judul, terjemahan, transliterasi, dan kategori.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.muted),
            ),
          ],
        ],
      ),
    );
  }
}
