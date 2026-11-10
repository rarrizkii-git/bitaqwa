import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/ustadz.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/external_url.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import 'widgets/kajian_empty_state.dart';
import 'widgets/kajian_lecture_card.dart';
import 'widgets/kajian_not_found.dart';
import 'widgets/kajian_page_body.dart';
import 'widgets/kajian_visuals.dart';

class KajianUstadzPage extends ConsumerWidget {
  const KajianUstadzPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(kajianCatalogProvider);
    final ustadz = catalog.ustadzById(id);
    if (ustadz == null) {
      return const KajianNotFoundPage(
        eyebrow: 'Ustadz tidak ditemukan',
        title: 'Profil ini belum tersedia.',
        description:
            'Nama yang kamu buka tidak ada di direktori Kajian Online. '
            'Kembali ke daftar ustadz untuk memilih profil lain.',
      );
    }

    final palette = context.palette;
    final lectures = catalog.byUstadz(ustadz.id);

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Profil pengajar',
            title: ustadz.displayName,
            description: ustadz.bio,
            action: context.isDesktop
                ? _UstadzSeal(ustadz: ustadz, count: lectures.length)
                : null,
            meta: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SoftBadge(
                  label: ustadz.channelName,
                  icon: Icons.ondemand_video_outlined,
                ),
                SoftBadge(
                  label: '${lectures.length} kajian',
                  icon: Icons.play_circle_outline_rounded,
                  color: palette.goldInk,
                ),
                const SoftBadge(
                  label: 'Sumber video',
                  icon: Icons.ondemand_video_outlined,
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
                      onPressed: () => context.go('/kajian/ustadz'),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Direktori ustadz'),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        'Diurutkan dari yang terbaru',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: palette.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (lectures.isEmpty)
                  KajianEmptyState(
                    icon: Icons.play_circle_outline_rounded,
                    title: 'Belum ada kajian tersedia',
                    description:
                        'Ustadz ini belum memiliki kajian di pustaka Bitaqwa. '
                        'Kembali ke daftar kajian untuk memilih materi lain.',
                    actionLabel: 'Kembali ke Kajian',
                    onAction: () => context.go('/kajian'),
                  )
                else
                  KajianLectureGrid(lectures: lectures),
                const SizedBox(height: 36),
                _ChannelCard(ustadz: ustadz),
                const SizedBox(height: 28),
                const SourceNote(
                  text:
                      'Kajian di halaman ini ditautkan langsung ke kanal sumber. '
                      'Bitaqwa tidak mengunggah ulang video dan tidak menambahkan '
                      'materi yang tidak ada pada kanal tersebut.',
                  icon: Icons.link_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UstadzSeal extends StatelessWidget {
  const _UstadzSeal({required this.ustadz, required this.count});

  final Ustadz ustadz;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 118,
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
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          KajianUstadzAvatar(
            initials: ustadz.monogram,
            imageUrl: ustadz.imageUrl,
            size: 66,
            radius: 20,
          ),
          const SizedBox(height: 10),
          Text(
            '$count kajian',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.ustadz});

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Kanal sumber',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: palette.goldInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ustadz.channelName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.text,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Setiap video pada halaman ini berasal dari kanal tersebut.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.muted,
                    ),
              ),
            ],
          );

          final action = AppButton(
            label: 'Buka kanal YouTube',
            icon: Icons.open_in_new_rounded,
            size: AppButtonSize.compact,
            variant: AppButtonVariant.secondary,
            onPressed: () => openExternalUrl(ustadz.channelUrl),
          );

          if (constraints.maxWidth < 640) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                copy,
                const SizedBox(height: 16),
                action,
              ],
            );
          }
          return Row(
            children: <Widget>[
              Expanded(child: copy),
              const SizedBox(width: 24),
              action,
            ],
          );
        },
      ),
    );
  }
}
