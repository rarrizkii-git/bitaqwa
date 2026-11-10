import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import 'widgets/kajian_page_body.dart';
import 'widgets/kajian_ustadz_card.dart';

class KajianUstadzDirectoryPage extends ConsumerWidget {
  const KajianUstadzDirectoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(kajianCatalogProvider);

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Direktori ustadz',
            title: 'Para pembawa kajian.',
            description:
                'Nama, gelar, dan kanal di bawah ini mengikuti apa yang tercantum pada video '
                'sumber. Bitaqwa tidak menambahkan biografi atau penilaian yang tidak '
                'bisa diperiksa.',
            action: AppButton(
              label: 'Semua kajian',
              icon: Icons.play_circle_outline_rounded,
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
                  label: '${catalog.allUstadz.length} ustadz',
                  icon: Icons.person_outline_rounded,
                ),
                SoftBadge(
                  label: '${catalog.allLectures.length} kajian',
                  icon: Icons.play_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.secondary,
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
                      onPressed: () => context.go('/kajian'),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Kembali ke Kajian'),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        'Pilih ustadz untuk melihat kajiannya',
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                KajianUstadzGrid(ustadzList: catalog.allUstadz),
                const SizedBox(height: 34),
                const SourceNote(
                  text:
                      'Profil hanya merangkum informasi yang tampak pada kanal sumber: '
                      'nama, gelar bila tercantum pada judul video, dan nama kanal. '
                      'Untuk keterangan yang lebih lengkap, buka kanal sumbernya.',
                  icon: Icons.fact_check_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
