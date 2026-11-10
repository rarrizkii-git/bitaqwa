import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/kajian_catalog.dart';
import '../../../core/models/lecture.dart';
import '../../../core/models/ustadz.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/clipboard.dart';
import '../../../core/utils/external_url.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import 'widgets/kajian_not_found.dart';
import 'widgets/kajian_page_body.dart';
import 'widgets/kajian_visuals.dart';
import 'widgets/youtube_embed.dart';

/// A single lecture, with the original YouTube player and full provenance.
class KajianDetailPage extends ConsumerWidget {
  const KajianDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(kajianCatalogProvider);
    final lecture = catalog.byId(id);
    if (lecture == null) {
      return const KajianNotFoundPage(
        eyebrow: 'Kajian tidak ditemukan',
        title: 'Kajian ini tidak ada.',
        description:
            'Alamat kajian yang kamu buka tidak ada di pustaka. '
            'Kembali ke daftar kajian untuk memilih materi lain.',
      );
    }

    final ustadz = catalog.ustadzOf(lecture);
    final related = catalog.related(lecture);

    return PageScaffold(
      child: KajianPageBody(
        top: context.isMobile ? 20 : 30,
        bottom: context.isMobile ? 56 : 84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Breadcrumb(lecture: lecture),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1000;
                final main = _DetailMain(lecture: lecture, ustadz: ustadz);
                final sidebar = _DetailSidebar(
                  lecture: lecture,
                  ustadz: ustadz,
                  related: related,
                );
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      main,
                      const SizedBox(height: 32),
                      sidebar,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 8, child: main),
                    const SizedBox(width: 32),
                    Expanded(flex: 4, child: sidebar),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.lecture});

  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: <Widget>[
        TextButton.icon(
          onPressed: () => context.go('/kajian'),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Kajian'),
        ),
        Icon(Icons.chevron_right_rounded, size: 16, color: palette.muted),
        const SizedBox(width: 2),
        TextButton(
          onPressed: () =>
              context.go('/kajian/kategori/${lecture.category.slug}'),
          child: Text(lecture.category.label),
        ),
        Icon(Icons.chevron_right_rounded, size: 16, color: palette.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            lecture.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              color: palette.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailMain extends ConsumerWidget {
  const _DetailMain({required this.lecture, required this.ustadz});

  final Lecture lecture;
  final Ustadz? ustadz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final bookmarked = ref.watch(kajianBookmarksProvider).contains(lecture.id);

    void toggleBookmark() {
      final wasSaved = ref.read(kajianBookmarksProvider).contains(lecture.id);
      ref.read(kajianBookmarksProvider.notifier).toggle(lecture.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              wasSaved
                  ? 'Kajian dihapus dari daftar tersimpan.'
                  : 'Kajian disimpan di perangkat ini.',
            ),
          ),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.border),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                    .withValues(alpha: context.isDarkMode ? 0.3 : 0.06),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubeEmbed(
              videoId: lecture.videoId,
              title: lecture.title,
              fallbackUrl: lecture.youtubeUrl,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            KajianCategoryTag(category: lecture.category),
            if (lecture.featured)
              SoftBadge(
                label: 'Pilihan editor',
                icon: Icons.auto_awesome_rounded,
                color: palette.goldInk,
              ),
            if (lecture.verified)
              const SoftBadge(
                label: 'Metadata diperiksa',
                icon: Icons.fact_check_outlined,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          lecture.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: context.responsive(
                  mobile: 30.0,
                  tablet: 38.0,
                  desktop: 42.0,
                ),
                height: 1.1,
                letterSpacing: -1,
                color: palette.text,
              ),
        ),
        const SizedBox(height: 20),
        _Byline(ustadz: ustadz),
        const SizedBox(height: 18),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: <Widget>[
            if (lecture.durationSeconds != null)
              _MetaItem(
                icon: Icons.schedule_rounded,
                label: formatVideoDuration(lecture.durationSeconds!),
              ),
            if (lecture.publishedDate != null)
              _MetaItem(
                icon: Icons.calendar_today_outlined,
                label: formatDateLong(lecture.publishedDate!),
              ),
            _MetaItem(
              icon: Icons.ondemand_video_outlined,
              label: ustadz?.channelName ?? 'YouTube',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            AppButton(
              label: bookmarked ? 'Tersimpan' : 'Simpan kajian',
              icon: bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              size: AppButtonSize.compact,
              onPressed: toggleBookmark,
            ),
            AppButton(
              label: 'Buka di YouTube',
              icon: Icons.open_in_new_rounded,
              size: AppButtonSize.compact,
              variant: AppButtonVariant.secondary,
              onPressed: () => openExternalUrl(lecture.youtubeUrl),
            ),
            AppButton(
              label: 'Salin tautan',
              icon: Icons.copy_rounded,
              size: AppButtonSize.compact,
              variant: AppButtonVariant.ghost,
              onPressed: () => copyWithFeedback(
                context,
                lecture.youtubeUrl,
                message: 'Tautan sumber disalin.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Divider(color: palette.border, height: 1),
        const SizedBox(height: 26),
        Text(
          'Tentang kajian',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: palette.goldInk,
          ),
        ),
        const SizedBox(height: 10),
        if (lecture.hasDescription)
          Text(
            lecture.description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.text,
                  height: 1.75,
                ),
          )
        else
          Text(
            'Sumber video ini tidak mencantumkan deskripsi yang dapat dikutip. '
            'Simak kajian melalui pemutar di atas, atau buka video aslinya di '
            'YouTube untuk keterangan langsung dari kanal penerbit.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.muted,
                  height: 1.75,
                ),
          ),
        const SizedBox(height: 28),
        _ProvenanceCard(lecture: lecture, ustadz: ustadz),
      ],
    );
  }
}

class _Byline extends StatelessWidget {
  const _Byline({required this.ustadz});

  final Ustadz? ustadz;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final teacher = ustadz;
    if (teacher == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () => context.go('/kajian/ustadz/${teacher.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            KajianUstadzAvatar(
              initials: teacher.monogram,
              imageUrl: teacher.imageUrl,
              size: 44,
              radius: 13,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    teacher.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    teacher.channelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: palette.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: palette.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: palette.muted),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11.5, color: palette.muted),
        ),
      ],
    );
  }
}

class _ProvenanceCard extends StatelessWidget {
  const _ProvenanceCard({required this.lecture, required this.ustadz});

  final Lecture lecture;
  final Ustadz? ustadz;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(
          alpha: context.isDarkMode ? 0.55 : 0.6,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.fact_check_outlined,
                size: 17,
                color: palette.goldInk,
              ),
              const SizedBox(width: 8),
              Text(
                'Sumber & pemeriksaan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Judul, kanal, durasi, dan tanggal terbit diperiksa pada video aslinya '
            'di YouTube. Bitaqwa tidak mengunggah ulang materi kajian. '
            'Pemeriksaan ini menyangkut metadata dan tautan sumber, bukan '
            'penilaian atas isi ceramah.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                  height: 1.65,
                ),
          ),
          const SizedBox(height: 14),
          _ProvenanceRow(label: 'ID video', value: lecture.videoId),
          _ProvenanceRow(
            label: 'Kanal',
            value: ustadz?.channelName ?? 'YouTube',
          ),
          _ProvenanceRow(
            label: 'Diperiksa',
            value: KajianCatalog.verifiedOn,
          ),
        ],
      ),
    );
  }
}

class _ProvenanceRow extends StatelessWidget {
  const _ProvenanceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: TextStyle(fontSize: 10.5, color: palette.muted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: palette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSidebar extends StatelessWidget {
  const _DetailSidebar({
    required this.lecture,
    required this.ustadz,
    required this.related,
  });

  final Lecture lecture;
  final Ustadz? ustadz;
  final List<Lecture> related;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (ustadz != null) ...<Widget>[
          _UstadzPanel(ustadz: ustadz!),
          const SizedBox(height: 18),
        ],
        _DetailsPanel(lecture: lecture),
        if (related.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          _RelatedPanel(lectures: related),
        ],
      ],
    );
  }
}

class _UstadzPanel extends StatelessWidget {
  const _UstadzPanel({required this.ustadz});

  final Ustadz ustadz;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              KajianUstadzAvatar(
                initials: ustadz.monogram,
                imageUrl: ustadz.imageUrl,
                size: 48,
                radius: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ustadz.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: palette.text,
                          ),
                    ),
                    if (ustadz.credentials != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        ustadz.credentials!,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: palette.goldInk,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ustadz.bio,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                  height: 1.65,
                ),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Profil lengkap',
            icon: Icons.person_outline_rounded,
            size: AppButtonSize.compact,
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: () => context.go('/kajian/ustadz/${ustadz.id}'),
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.lecture});

  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Rincian kajian',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            label: 'Tema',
            value: lecture.category.label,
            onTap: () =>
                context.go('/kajian/kategori/${lecture.category.slug}'),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: 'Durasi',
            value: lecture.durationSeconds == null
                ? 'Tidak tercatat'
                : formatVideoDuration(lecture.durationSeconds!),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: 'Terbit',
            value: lecture.publishedDate == null
                ? 'Tidak tercatat'
                : formatDateLong(lecture.publishedDate!),
          ),
          const SizedBox(height: 10),
          const _DetailRow(label: 'Sumber', value: 'YouTube'),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: TextStyle(fontSize: 10.5, color: palette.muted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: onTap == null ? palette.text : palette.primary,
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: content,
    );
  }
}

class _RelatedPanel extends StatelessWidget {
  const _RelatedPanel({required this.lectures});

  final List<Lecture> lectures;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Kajian terkait',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < lectures.length; i++) ...<Widget>[
            _RelatedTile(lecture: lectures[i]),
            if (i < lectures.length - 1)
              Divider(color: palette.border, height: 18),
          ],
        ],
      ),
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.lecture});

  final Lecture lecture;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: () => context.go('/kajian/${lecture.id}'),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 88,
              child: KajianThumbnail(
                lecture: lecture,
                radius: 8,
                showPlayBadge: false,
                showDuration: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  KajianCategoryTag(category: lecture.category),
                  const SizedBox(height: 4),
                  Text(
                    lecture.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.serif(
                      fontSize: 13.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (lecture.durationSeconds != null)
                    Text(
                      formatVideoDuration(lecture.durationSeconds!),
                      style: TextStyle(fontSize: 10, color: palette.muted),
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
