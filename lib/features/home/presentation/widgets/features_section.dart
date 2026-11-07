import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/page_scaffold.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/hover_card.dart';
import '../../../../shared/widgets/islamic_art.dart';
import '../../../../shared/widgets/reveal.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.palette.background,
      padding: context.sectionPadding,
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeading(
              eyebrow: 'Fitur',
              title: 'Semua yang menemani ibadahmu.',
              subtitle:
                  'Dirancang untuk dipakai setiap hari: tenang, cepat, dan tanpa gangguan. Setiap fitur bekerja sungguhan, bukan sekadar tampilan.',
              trailing: Reveal(
                child: AppTextLink(
                  label: 'Mulai dari jadwal shalat',
                  onTap: () => context.go('/jadwal-shalat'),
                ),
              ),
            ),
            const SizedBox(height: 44),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                const gap = 20.0;

                if (maxWidth >= 1000) {
                  final half = (maxWidth - gap) / 2;
                  final third = (maxWidth - gap * 2) / 3;

                  return Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: half,
                            child: StaggeredReveal(
                              index: 0,
                              child: _FeatureCard(
                                feature: _features[0],
                                index: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: gap),
                          SizedBox(
                            width: half,
                            child: StaggeredReveal(
                              index: 1,
                              child: _FeatureCard(
                                feature: _features[1],
                                index: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: gap),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          for (int i = 2; i < 5; i++) ...<Widget>[
                            SizedBox(
                              width: third,
                              child: StaggeredReveal(
                                index: i,
                                child: _FeatureCard(
                                  feature: _features[i],
                                  index: i + 1,
                                ),
                              ),
                            ),
                            if (i < 4) const SizedBox(width: gap),
                          ],
                        ],
                      ),
                    ],
                  );
                }

                final columns = maxWidth >= 640 ? 2 : 1;
                final cardWidth =
                    columns == 2 ? (maxWidth - gap) / 2 : maxWidth;

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: <Widget>[
                    for (int i = 0; i < _features.length; i++)
                      SizedBox(
                        width: i == _features.length - 1 && columns == 2
                            ? maxWidth
                            : cardWidth,
                        child: StaggeredReveal(
                          index: i,
                          child: _FeatureCard(
                            feature: _features[i],
                            index: i + 1,
                          ),
                        ),
                      ),
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

class _FeatureData {
  const _FeatureData({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.tag,
  });

  final String title;
  final String description;
  final IconData icon;
  final String route;
  final String tag;
}

const _features = <_FeatureData>[
  _FeatureData(
    title: 'Jadwal Shalat',
    description:
        'Waktu shalat lima waktu yang dihitung untuk kotamu, lengkap dengan penanda shalat berikutnya dan hitung mundur.',
    icon: Icons.access_time_rounded,
    route: '/jadwal-shalat',
    tag: 'Harian',
  ),
  _FeatureData(
    title: "Al-Qur'an",
    description:
        'Baca 114 surah dengan teks Arab, transliterasi, dan terjemahan Indonesia. Simpan surah favoritmu.',
    icon: Icons.menu_book_rounded,
    route: '/quran',
    tag: 'Baca',
  ),
  _FeatureData(
    title: 'Doa Harian',
    description:
        'Doa pilihan dari Al-Qur\u2019an dan hadis untuk momen sehari-hari, lengkap dengan sumber dan terjemahan.',
    icon: Icons.volunteer_activism_rounded,
    route: '/doa',
    tag: 'Doa',
  ),
  _FeatureData(
    title: 'Zikir',
    description:
        'Penghitung zikir yang tenang dengan target dan riwayat tersimpan otomatis di perangkatmu.',
    icon: Icons.spa_rounded,
    route: '/zikir',
    tag: 'Zikir',
  ),
  _FeatureData(
    title: 'Kompas Kiblat',
    description:
        'Temukan arah kiblat dari kotamu dengan bearing yang dihitung terhadap Ka\u2019bah, plus jarak ke Makkah.',
    icon: Icons.explore_rounded,
    route: '/kiblat',
    tag: 'Arah',
  ),
];

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.index});

  final _FeatureData feature;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return HoverCard(
      padding: const EdgeInsets.all(26),
      semanticLabel: 'Buka ${feature.title}',
      onTap: () => context.go(feature.route),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -26,
            top: -30,
            child: ClipRect(
              child: SizedBox(
                width: 110,
                height: 110,
                child: IslamicPattern(
                  color: palette.pattern,
                  opacity: 0.055,
                  spacing: 34,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _FeatureIcon(icon: feature.icon),
                  const Spacer(),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.border),
                    ),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Text(
                    '${index.toString().padLeft(2, '0')}  \u00b7  ${feature.tag}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: palette.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      color: palette.text,
                    ),
              ),
              const SizedBox(height: 9),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.muted,
                      height: 1.65,
                    ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Text(
                    'Buka fitur',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: palette.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: palette.primarySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: palette.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Icon(icon, size: 25, color: palette.primary),
        ],
      ),
    );
  }
}
