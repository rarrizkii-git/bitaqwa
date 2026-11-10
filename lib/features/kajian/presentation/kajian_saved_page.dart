import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import 'widgets/kajian_empty_state.dart';
import 'widgets/kajian_lecture_card.dart';
import 'widgets/kajian_page_body.dart';

class KajianSavedPage extends ConsumerWidget {
  const KajianSavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final catalog = ref.watch(kajianCatalogProvider);
    final bookmarks = ref.watch(kajianBookmarksProvider);
    final lectures = catalog.latestLectures
        .where((lecture) => bookmarks.contains(lecture.id))
        .toList(growable: false);

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Kajian tersimpan',
            title: 'Kajian yang ingin kamu dalami lagi.',
            description:
                'Daftar ini disimpan di perangkatmu dan tetap ada setelah halaman dimuat ulang. '
                'Tidak perlu akun, dan tidak ada data yang dikirim ke server.',
            action: AppButton(
              label: 'Jelajahi kajian',
              icon: Icons.explore_outlined,
              trailingIcon: Icons.arrow_forward_rounded,
              size: AppButtonSize.compact,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.go('/kajian'),
            ),
            meta: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SoftBadge(
                  label: '${lectures.length} kajian tersimpan',
                  icon: Icons.bookmark_rounded,
                ),
                SoftBadge(
                  label: 'Tersimpan di perangkat',
                  icon: Icons.lock_outline_rounded,
                  color: palette.goldInk,
                ),
              ],
            ),
          ),
          KajianPageBody(
            child: lectures.isEmpty
                ? KajianEmptyState(
                    icon: Icons.bookmark_border_rounded,
                    title: 'Belum ada kajian tersimpan',
                    description:
                        'Ketuk ikon bookmark pada kartu kajian atau halaman detail untuk '
                        'menyimpannya di sini. Daftar akan tetap tersedia saat kamu kembali.',
                    actionLabel: 'Mulai menjelajah kajian',
                    onAction: () => context.go('/kajian'),
                    note:
                        'Bookmark hanya tersimpan di peramban ini. Menghapus data situs '
                        'juga akan menghapus daftar tersimpan.',
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final heading = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  'Semua kajian tersimpan',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
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
                                  '${lectures.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: palette.primary,
                                  ),
                                ),
                              ),
                            ],
                          );

                          final addButton = TextButton.icon(
                            onPressed: () => context.go('/kajian'),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Tambah kajian'),
                          );

                          if (constraints.maxWidth < 520) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                heading,
                                const SizedBox(height: 4),
                                addButton,
                              ],
                            );
                          }

                          return Row(
                            children: <Widget>[
                              Expanded(child: heading),
                              const SizedBox(width: 10),
                              addButton,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      KajianLectureGrid(lectures: lectures),
                      const SizedBox(height: 32),
                      const SourceNote(
                        text:
                            'Kajian tersimpan tetap menautkan ke video sumber di YouTube. '
                            'Bitaqwa tidak menyimpan salinan video atau mengunggah ulang '
                            'materi kajian.',
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
