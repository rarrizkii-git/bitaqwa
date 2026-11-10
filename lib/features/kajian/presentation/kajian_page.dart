import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/kajian_catalog.dart';
import '../../../core/models/lecture.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import 'widgets/kajian_category_index.dart';
import 'widgets/kajian_empty_state.dart';
import 'widgets/kajian_featured.dart';
import 'widgets/kajian_filter_bar.dart';
import 'widgets/kajian_lecture_card.dart';
import 'widgets/kajian_page_body.dart';
import 'widgets/kajian_ustadz_card.dart';

/// The Kajian Online library homepage.
///
/// Everything on this screen is driven by [KajianCatalog]; there are no
/// hand-written cards or invented recommendations. The only editorial voice
/// is the copy around the catalogue.
class KajianPage extends ConsumerStatefulWidget {
  const KajianPage({super.key});

  @override
  ConsumerState<KajianPage> createState() => _KajianPageState();
}

class _KajianPageState extends ConsumerState<KajianPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  LectureCategory? _category;
  String? _ustadzId;
  bool _showAll = false;

  bool get _hasFilters =>
      _query.trim().isNotEmpty || _category != null || _ustadzId != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
      _ustadzId = null;
      _showAll = false;
    });
  }

  /// Describes the active filter, so the result count never appears without
  /// saying what it is counting.
  String _resultLabel(KajianCatalog catalog) {
    if (_query.trim().isNotEmpty) return 'Hasil pencarian';
    final ustadz = catalog.ustadzById(_ustadzId);
    final category = _category;
    if (ustadz != null && category != null) {
      return '${category.label} \u00b7 ${ustadz.name}';
    }
    if (ustadz != null) return 'Kajian ${ustadz.name}';
    if (category != null) return category.label;
    return 'Semua kajian';
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(kajianCatalogProvider);
    final results = catalog.search(
      _query,
      category: _category,
      ustadzId: _ustadzId,
    );
    final visible = _showAll || _hasFilters
        ? results
        : results.take(6).toList(growable: false);
    final hasMore = !_showAll && !_hasFilters && results.length > visible.length;

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Kajian Online',
            title: 'Ilmu yang terarah, dari sumber yang jelas.',
            description:
                'Pustaka kajian pilihan yang ditautkan langsung ke kanal aslinya di YouTube. '
                'Tidak ada unggahan ulang, tidak ada rekomendasi otomatis\u2014hanya kajian yang '
                'bisa kamu telusuri dan periksa sumbernya.',
            action: AppButton(
              label: 'Kajian tersimpan',
              icon: Icons.bookmark_border_rounded,
              trailingIcon: Icons.arrow_forward_rounded,
              size: AppButtonSize.compact,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.go('/kajian/tersimpan'),
            ),
            meta: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SoftBadge(
                  label: '${catalog.allLectures.length} kajian terkurasi',
                  icon: Icons.play_circle_outline_rounded,
                ),
                SoftBadge(
                  label: '${LectureCategory.values.length} tema',
                  icon: Icons.grid_view_rounded,
                  color: context.palette.goldInk,
                ),
                SoftBadge(
                  label: '${catalog.allUstadz.length} ustadz',
                  icon: Icons.person_outline_rounded,
                ),
              ],
            ),
          ),
          KajianPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SectionHeading(
                  eyebrow: 'Pilihan editor',
                  title: 'Kajian yang layak kamu mulai.',
                  subtitle:
                      'Dipilih manual oleh editor Bitaqwa, bukan hasil algoritma. '
                      'Setiap judul dan kanal sudah diperiksa pada sumber aslinya.',
                  trailing: SoftBadge(
                    label: '${catalog.featuredLectures.length} pilihan',
                    icon: Icons.auto_awesome_rounded,
                    color: context.palette.goldInk,
                  ),
                ),
                const SizedBox(height: 28),
                KajianFeaturedPanel(lectures: catalog.featuredLectures),
                const SizedBox(height: 64),
                SectionHeading(
                  eyebrow: 'Telusuri pustaka',
                  title: 'Temukan kajian sesuai kebutuhanmu.',
                  subtitle:
                      'Cari berdasarkan judul, nama ustadz, atau tema. Hasil disusun dari yang '
                      'paling baru, dan setiap kartu membuka halaman kajian beserta sumbernya.',
                ),
                const SizedBox(height: 24),
                KajianFilterBar(
                  controller: _searchController,
                  query: _query,
                  selectedCategory: _category,
                  selectedUstadzId: _ustadzId,
                  onChanged: (value) => setState(() => _query = value),
                  onClearSearch: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  onSelectCategory: (category) =>
                      setState(() => _category = category),
                  onSelectUstadz: (ustadzId) =>
                      setState(() => _ustadzId = ustadzId),
                  onReset: _resetFilters,
                ),
                const SizedBox(height: 24),
                _ResultHeader(
                  label: _resultLabel(catalog),
                  count: results.length,
                  hasFilters: _hasFilters,
                  onReset: _resetFilters,
                ),
                const SizedBox(height: 18),
                if (visible.isEmpty)
                  KajianEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Kajian tidak ditemukan',
                    description:
                        'Coba kata kunci lain, atau longgarkan filter tema dan ustadz. '
                        'Pustaka ini hanya memuat kajian yang sumbernya sudah diperiksa.',
                    actionLabel: 'Tampilkan semua kajian',
                    onAction: _resetFilters,
                  )
                else
                  KajianLectureGrid(lectures: visible),
                if (hasMore) ...<Widget>[
                  const SizedBox(height: 26),
                  Center(
                    child: AppButton(
                      label: 'Tampilkan ${results.length - visible.length} kajian lainnya',
                      icon: Icons.expand_more_rounded,
                      size: AppButtonSize.compact,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => setState(() => _showAll = true),
                    ),
                  ),
                ],
                const SizedBox(height: 64),
                SectionHeading(
                  eyebrow: 'Tema kajian',
                  title: 'Telusuri pustaka menurut tema.',
                  subtitle:
                      'Setiap tema membuka daftar kajian yang membahas pokok bahasan tersebut. '
                      'Pilih tema yang paling dekat dengan pertanyaanmu hari ini.',
                  trailing: AppTextLink(
                    label: 'Lihat direktori ustadz',
                    onTap: () => context.go('/kajian/ustadz'),
                  ),
                ),
                const SizedBox(height: 22),
                const KajianCategoryIndex(),
                const SizedBox(height: 64),
                SectionHeading(
                  eyebrow: 'Pengajar',
                  title: 'Kenali pembawa kajian.',
                  subtitle:
                      'Profil ini hanya memuat nama, gelar, dan kanal yang tercantum pada video '
                      'sumber. Tidak ada biografi yang disusun tanpa rujukan.',
                  trailing: AppTextLink(
                    label: 'Semua ustadz',
                    onTap: () => context.go('/kajian/ustadz'),
                  ),
                ),
                const SizedBox(height: 24),
                KajianUstadzGrid(
                  ustadzList: catalog.allUstadz
                      .take(6)
                      .toList(growable: false),
                ),
                const SizedBox(height: 40),
                const SourceNote(
                  text:
                      'Bitaqwa tidak mengunggah ulang video. Pemutar di halaman kajian '
                      'menggunakan YouTube, dan setiap entri menautkan kanal aslinya. '
                      'Judul, kanal, durasi, serta tanggal terbit diperiksa langsung '
                      'pada sumbernya.',
                  icon: Icons.fact_check_outlined,
                ),
                const SizedBox(height: 14),
                const SourceNote(
                  text:
                      'Catatan kurasi: pustaka ini disusun menurut kriteria editorial '
                      'Bitaqwa\u2014kejelasan sumber dan kelayakan tautan. Tampilnya '
                      'sebuah kajian bukan berarti seluruh pandangan penceramah '
                      'disetujui, dan tidak menggantikan fatwa ulama. Untuk pertanyaan '
                      'agama, rujuklah ulama yang berkompeten di bidangnya.',
                  icon: Icons.info_outline_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.label,
    required this.count,
    required this.hasFilters,
    required this.onReset,
  });

  final String label;
  final int count;
  final bool hasFilters;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: palette.primarySoft.withValues(
              alpha: context.isDarkMode ? 0.55 : 1,
            ),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: palette.primary,
            ),
          ),
        ),
        const Spacer(),
        if (hasFilters)
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
            label: const Text('Reset filter'),
          ),
      ],
    );
  }
}
