import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/prayer_times.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/prayer_calculator.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/layout/page_scaffold.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/city_picker.dart';
import '../../../../shared/widgets/islamic_art.dart';
import '../../../../shared/widgets/prayer_visuals.dart';
import '../../../../shared/widgets/reveal.dart';

class PrayerPreviewSection extends StatelessWidget {
  const PrayerPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      color: palette.surfaceAlt,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IslamicPattern(
              color: palette.pattern,
              opacity: context.isDarkMode ? 0.03 : 0.035,
              spacing: 78,
            ),
          ),
          Padding(
            padding: context.sectionPadding,
            child: ContentWidth(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 980;
                  final copy = _PrayerCopy();
                  final card = const Reveal(
                    offset: 0.1,
                    duration: Duration(milliseconds: 800),
                    child: _TodayScheduleCard(),
                  );

                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        copy,
                        const SizedBox(height: 34),
                        card,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(flex: 9, child: copy),
                      const SizedBox(width: 56),
                      Expanded(flex: 10, child: card),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerCopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeading(
          eyebrow: 'Jadwal Shalat',
          title: 'Waktu ibadah, tanpa perlu mencari.',
          subtitle:
              'Jadwal lima waktu dihitung untuk kotamu, lengkap dengan penanda shalat berikutnya dan hitung mundur yang berjalan real-time.',
        ),
        const SizedBox(height: 30),
        const _Point(
          icon: Icons.location_city_outlined,
          title: '44+ kota, satu ketukan',
          description:
              'Pilih kotamu sekali. Jadwal dan arah kiblat langsung menyesuaikan, tersimpan di perangkat.',
        ),
        const SizedBox(height: 20),
        const _Point(
          icon: Icons.calculate_outlined,
          title: 'Metode yang transparan',
          description:
              'Pilih Kemenag, MWL, ISNA, atau Umm al-Qura. Sudut fajar dan isya ditampilkan terbuka.',
        ),
        const SizedBox(height: 20),
        const _Point(
          icon: Icons.verified_outlined,
          title: 'Perkiraan astronomis, bukan klaim mutlak',
          description:
              'Hasil dihitung dari posisi matahari. Selalu verifikasi dengan jadwal resmi masjid setempat.',
        ),
        const SizedBox(height: 30),
        Reveal(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              AppButton(
                label: 'Buka jadwal lengkap',
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => context.go('/jadwal-shalat'),
              ),
              AppButton(
                label: 'Arah kiblat',
                icon: Icons.explore_outlined,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go('/kiblat'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Zona waktu menggunakan offset tetap per kota. Perubahan daylight saving di luar Indonesia tidak diterapkan.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.muted,
                height: 1.6,
              ),
        ),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: palette.border),
          ),
          child: Icon(icon, size: 19, color: palette.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: palette.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.muted,
                      height: 1.6,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayScheduleCard extends ConsumerStatefulWidget {
  const _TodayScheduleCard();

  @override
  ConsumerState<_TodayScheduleCard> createState() => _TodayScheduleCardState();
}

class _TodayScheduleCardState extends ConsumerState<_TodayScheduleCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final city = ref.watch(selectedCityProvider);
    final method = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(asrMadhabProvider);
    final today = ref.watch(
      prayerTimesProvider(DateTime(_now.year, _now.month, _now.day)),
    );

    var next = today.nextPrayerAfter(_now);
    var isTomorrow = false;
    if (next == null) {
      final tomorrowSchedule = PrayerCalculator.calculate(
        city: city,
        method: method,
        madhab: madhab,
        date: _now.add(const Duration(days: 1)),
      );
      next = PrayerScheduleEntry(
        name: PrayerName.fajr,
        time: tomorrowSchedule.fajr,
      );
      isTomorrow = true;
    }

    final active = today.activePrayerAt(_now);
    final countdown = next.time.difference(_now);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                .withValues(alpha: context.isDarkMode ? 0.3 : 0.08),
            blurRadius: 42,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: palette.gold,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'HARI INI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                              color: palette.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formatDateLong(_now),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: palette.text,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CityPickerButton(compact: context.isMobile),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF0A5942), Color(0xFF0D7A58)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: -32,
                    top: -36,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isTomorrow
                            ? 'SHALAT BERIKUTNYA \u00b7 BESOK'
                            : 'SHALAT BERIKUTNYA',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  next.name.label,
                                  style: const TextStyle(
                                    fontFamily: 'Fraunces',
                                    fontSize: 30,
                                    height: 1,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.6,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${formatClock(next.time)} \u00b7 ${city.name}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.78),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                formatCountdown(countdown),
                                style: const TextStyle(
                                  fontFamily: 'Fraunces',
                                  fontSize: 24,
                                  height: 1,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: Color(0xFFF1D9A8),
                                  fontFeatures: <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                countdown.isNegative ? 'segera' : 'tersisa',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  letterSpacing: 1,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              children: <Widget>[
                for (final entry in today.entries)
                  PrayerTimeRow(
                    entry: entry,
                    dense: true,
                    isNext: !isTomorrow && entry.name == next.name,
                    isActive:
                        !isTomorrow && active?.name == entry.name && entry.name != next.name,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${method.label} \u00b7 Ashar ${madhab.label}',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: palette.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Perkiraan astronomis',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: palette.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
