import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/cities.dart';
import '../../../../core/data/dhikr_presets.dart';
import '../../../../core/data/duas.dart';
import '../../../../core/data/surahs.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/brand.dart';
import '../../../../shared/widgets/islamic_art.dart';
import '../../../../shared/widgets/reveal.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final stats = <_StatData>[
      _StatData(
        value: Surahs.all.length,
        label: 'Surah',
        caption: 'Teks Arab & terjemahan',
        icon: Icons.menu_book_outlined,
      ),
      _StatData(
        value: Duas.all.length,
        label: 'Doa pilihan',
        caption: 'Dengan sumber yang jelas',
        icon: Icons.volunteer_activism_outlined,
      ),
      _StatData(
        value: DhikrPresets.all.length,
        label: 'Zikir',
        caption: 'Target & riwayat tersimpan',
        icon: Icons.spa_outlined,
      ),
      _StatData(
        value: Cities.all.length,
        label: 'Kota',
        caption: 'Jadwal & arah kiblat',
        icon: Icons.location_city_outlined,
      ),
    ];

    return Container(
      color: palette.background,
      padding: EdgeInsets.symmetric(
        horizontal: context.pageGutter,
        vertical: context.isMobile ? 22 : 30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive(mobile: 10.0, desktop: 18.0),
              vertical: context.responsive(mobile: 24.0, desktop: 30.0),
            ),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: palette.border),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                if (!wide) {
                  return Wrap(
                    runSpacing: 24,
                    children: <Widget>[
                      for (int i = 0; i < stats.length; i++)
                        SizedBox(
                          width: constraints.maxWidth / 2,
                          child: StaggeredReveal(
                            index: i,
                            child: _StatTile(data: stats[i]),
                          ),
                        ),
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    for (int i = 0; i < stats.length; i++) ...<Widget>[
                      Expanded(
                        child: StaggeredReveal(
                          index: i,
                          child: _StatTile(data: stats[i]),
                        ),
                      ),
                      if (i < stats.length - 1)
                        Container(
                          width: 1,
                          height: 58,
                          color: palette.border,
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.value,
    required this.label,
    required this.caption,
    required this.icon,
  });

  final int value;
  final String label;
  final String caption;
  final IconData icon;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              CountUp(
                value: data.value,
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 38,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  color: palette.primary,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: palette.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Icon(data.icon, size: 13, color: palette.gold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.caption,
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.muted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      color: palette.background,
      padding: EdgeInsets.only(
        left: context.pageGutter,
        right: context.pageGutter,
        top: context.isMobile ? 26 : 40,
        bottom: context.isMobile ? 62 : 88,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Reveal(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF064E3B), Color(0xFF0F7557)],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: IslamicPattern(
                      color: Colors.white,
                      opacity: 0.045,
                      spacing: 58,
                    ),
                  ),
                  Positioned(
                    right: -20,
                    bottom: -60,
                    child: SizedBox(
                      width: 520,
                      height: 260,
                      child: MosqueSilhouette(
                        height: 260,
                        color: Colors.white.withValues(alpha: 0.06),
                        detailColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsive(
                        mobile: 26.0,
                        tablet: 48.0,
                        desktop: 64.0,
                      ),
                      vertical: context.responsive(
                        mobile: 38.0,
                        tablet: 52.0,
                        desktop: 58.0,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 860;
                        final copy = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const GoldRule(
                                  width: 26,
                                  color: Color(0xFFD6B77C),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'MULAI HARI INI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.2,
                                    color: const Color(0xFFE8D4A8)
                                        .withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Satu langkah kecil,\nsetiap hari.',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontSize: context.responsive(
                                      mobile: 34.0,
                                      tablet: 44.0,
                                      desktop: 50.0,
                                    ),
                                    height: 1.08,
                                    letterSpacing: -1.2,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: Text(
                                'Tidak perlu akun, tidak perlu instalasi. Pilih kotamu, lihat jadwal shalat, dan mulai membaca. Preferensimu tersimpan di perangkat.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.75),
                                      height: 1.7,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: <Widget>[
                                AppButton(
                                  label: 'Lihat Jadwal Shalat',
                                  trailingIcon: Icons.arrow_forward_rounded,
                                  variant: AppButtonVariant.inverted,
                                  onPressed: () => context.go('/jadwal-shalat'),
                                ),
                                AppButton(
                                  label: 'Baca Al-Qur\u2019an',
                                  icon: Icons.menu_book_outlined,
                                  variant: AppButtonVariant.inverted,
                                  onPressed: () => context.go('/quran'),
                                ),
                              ],
                            ),
                          ],
                        );

                        if (!wide) return copy;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(flex: 11, child: copy),
                            const SizedBox(width: 40),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.16,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const CrescentMark(
                                          size: 30,
                                          color: Color(0xFFE8D4A8),
                                          cutoutColor: Color(0xFF0B6349),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Tenang, privat,\ndan tanpa gangguan.',
                                          style: TextStyle(
                                            fontFamily: 'Fraunces',
                                            fontSize: 20,
                                            height: 1.25,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Tanpa iklan. Tanpa pelacakan. Data tetap di perangkatmu.',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            height: 1.65,
                                            color: Colors.white.withValues(
                                              alpha: 0.68,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
