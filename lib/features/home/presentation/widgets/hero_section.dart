import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/prayer_times.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/prayer_calculator.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/brand.dart';
import '../../../../shared/widgets/islamic_art.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({
    super.key,
    required this.scrollController,
    required this.onExplore,
  });

  final ScrollController scrollController;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final reduceMotion = ref.watch(reduceMotionProvider);

    Widget entrance(Widget child, int delay) {
      if (reduceMotion) return child;
      return child
          .animate()
          .fadeIn(
            duration: const Duration(milliseconds: 700),
            delay: Duration(milliseconds: delay),
            curve: Curves.easeOutCubic,
          )
          .slideY(
            begin: 0.12,
            end: 0,
            duration: const Duration(milliseconds: 700),
            delay: Duration(milliseconds: delay),
            curve: Curves.easeOutCubic,
          );
    }

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  palette.surfaceAlt.withValues(alpha: context.isDarkMode ? 0.55 : 0.65),
                  palette.background,
                ],
                stops: const <double>[0, 0.86],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IslamicPattern(
            color: palette.pattern,
            opacity: context.isDarkMode ? 0.035 : 0.04,
            spacing: 72,
          ),
        ),
        AnimatedBuilder(
          animation: scrollController,
          builder: (context, child) {
            final offset = scrollController.hasClients ? scrollController.offset : 0.0;
            return Transform.translate(
              offset: Offset(0, offset * 0.12),
              child: child,
            );
          },
          child: Stack(
            children: <Widget>[
              Positioned(
                left: -110,
                top: 60,
                child: GlowOrb(
                  size: 360,
                  color: palette.primary,
                  opacity: context.isDarkMode ? 0.11 : 0.08,
                ),
              ),
              Positioned(
                right: -100,
                top: 120,
                child: GlowOrb(
                  size: 420,
                  color: palette.gold,
                  opacity: context.isDarkMode ? 0.06 : 0.08,
                ),
              ),
            ],
          ),
        ),
        ContentWidth(
          child: Padding(
            padding: EdgeInsets.only(
              top: context.responsive(mobile: 42.0, tablet: 56.0, desktop: 76.0),
              bottom: context.responsive(mobile: 56.0, tablet: 72.0, desktop: 92.0),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 980;
                final copy = _HeroCopy(
                  entrance: entrance,
                  onExplore: onExplore,
                );
                final art = HeroArtwork();

                if (!desktop) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      copy,
                      const SizedBox(height: 42),
                      entrance(art, 420),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(flex: 11, child: copy),
                    const SizedBox(width: 48),
                    Expanded(flex: 10, child: entrance(art, 380)),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.entrance, required this.onExplore});

  final Widget Function(Widget, int) entrance;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = context.responsive(
      mobile: width < 380 ? 38.0 : 43.0,
      tablet: 55.0,
      desktop: 64.0,
    );

    final baseStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: fontSize,
          height: 1.04,
          letterSpacing: fontSize > 50 ? -2.2 : -1.3,
          color: palette.text,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        entrance(
          Row(
            children: <Widget>[
              const GoldRule(width: 28),
              const SizedBox(width: 12),
              Eyebrow(
                'Assalamu\u2019alaikum',
                icon: Icons.auto_awesome,
              ),
            ],
          ),
          80,
        ),
        const SizedBox(height: 22),
        entrance(
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: 'Lebih Dekat\ndengan Allah,\n', style: baseStyle),
                TextSpan(
                  text: 'Setiap Hari.',
                  style: baseStyle?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: palette.primary,
                  ),
                ),
              ],
            ),
          ),
          150,
        ),
        const SizedBox(height: 24),
        entrance(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              'Temani perjalanan ibadahmu dengan jadwal shalat, Al-Qur\u2019an, doa harian, dan zikir dalam satu tempat.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.muted,
                    fontSize: 16.5,
                    height: 1.75,
                  ),
            ),
          ),
          250,
        ),
        const SizedBox(height: 30),
        entrance(
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              AppButton(
                label: 'Mulai Sekarang',
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => context.go('/jadwal-shalat'),
              ),
              AppButton(
                label: 'Jelajahi Fitur',
                icon: Icons.arrow_downward_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: onExplore,
              ),
            ],
          ),
          340,
        ),
        const SizedBox(height: 30),
        entrance(
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: const <Widget>[
              _HeroPoint(icon: Icons.person_off_outlined, label: 'Tanpa akun'),
              _HeroPoint(icon: Icons.lock_outline_rounded, label: 'Data di perangkat'),
              _HeroPoint(icon: Icons.menu_book_outlined, label: 'Sumber tertera'),
            ],
          ),
          430,
        ),
      ],
    );
  }
}

class _HeroPoint extends StatelessWidget {
  const _HeroPoint({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 15, color: palette.gold),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: palette.muted,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class HeroArtwork extends ConsumerWidget {
  const HeroArtwork({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final city = ref.watch(selectedCityProvider);
    final bearing = ref.watch(qiblaBearingProvider);
    final mobile = context.isMobile;
    final height = mobile ? 440.0 : 566.0;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final sideInset = width * 0.04;
          final archInset = width * 0.14;

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                left: sideInset,
                right: sideInset,
                child: Container(
                  decoration: BoxDecoration(
                    color: palette.heroPanel,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: palette.border.withValues(alpha: 0.9),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                            .withValues(alpha: context.isDarkMode ? 0.28 : 0.10),
                        blurRadius: 46,
                        offset: const Offset(0, 26),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                left: sideInset,
                right: sideInset,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: IslamicPattern(
                    color: palette.pattern,
                    opacity: context.isDarkMode ? 0.055 : 0.05,
                    spacing: 54,
                  ),
                ),
              ),
              // Mihrab arch.
              Positioned(
                left: archInset,
                right: archInset,
                top: mobile ? 52 : 60,
                bottom: 0,
                child: ClipPath(
                  clipper: const MihrabClipper(topInset: 0.01),
                  child: Container(
                    decoration: BoxDecoration(
                      color: palette.heroArch,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          palette.heroArch,
                          palette.heroArch,
                          palette.primarySoft.withValues(
                            alpha: context.isDarkMode ? 0.4 : 0.55,
                          ),
                        ],
                        stops: const <double>[0, 0.55, 1],
                      ),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: IslamicPattern(
                            color: palette.pattern,
                            opacity: 0.035,
                            spacing: 44,
                          ),
                        ),
                        Positioned(
                          top: mobile ? 26 : 34,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: <Widget>[
                              Text(
                                'بِسْمِ اللَّهِ',
                                textDirection: TextDirection.rtl,
                                style: AppTypography.arabic(
                                  fontSize: mobile ? 22 : 27,
                                  color: palette.primary,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'DENGAN NAMA ALLAH',
                                style: TextStyle(
                                  fontSize: 8,
                                  letterSpacing: 1.8,
                                  fontWeight: FontWeight.w700,
                                  color: palette.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: mobile ? 22 : 30,
                          right: mobile ? 18 : 30,
                          child: CrescentMark(
                            size: mobile ? 20 : 25,
                            color: palette.gold,
                            cutoutColor: palette.heroArch,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: MosqueSilhouette(
                            height: mobile ? 185 : 250,
                            color: context.isDarkMode
                                ? palette.primary
                                : palette.primaryDeep,
                            detailColor: palette.heroArch,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: mobile ? 0 : 2,
                top: mobile ? 0 : 10,
                child: RotatingStar(
                  size: mobile ? 78 : 104,
                  opacity: context.isDarkMode ? 0.35 : 0.24,
                  color: palette.primary,
                ),
              ),
              Positioned(
                left: mobile ? 2 : 0,
                top: mobile ? 62 : 78,
                child: Floating(
                  offset: mobile ? 6 : 9,
                  child: _NextPrayerCard(
                    compact: mobile,
                    cityName: city.name,
                  ),
                ),
              ),
              Positioned(
                right: mobile ? 0 : -4,
                bottom: mobile ? 20 : 34,
                child: Floating(
                  offset: 8,
                  duration: const Duration(milliseconds: 5000),
                  child: _QiblaCard(
                    compact: mobile,
                    bearing: bearing,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NextPrayerCard extends ConsumerStatefulWidget {
  const _NextPrayerCard({required this.compact, required this.cityName});

  final bool compact;
  final String cityName;

  @override
  ConsumerState<_NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends ConsumerState<_NextPrayerCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
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
    var tomorrow = false;
    if (next == null) {
      final nextDay = PrayerCalculator.calculate(
        city: city,
        method: method,
        madhab: madhab,
        date: _now.add(const Duration(days: 1)),
      );
      next = PrayerScheduleEntry(
        name: PrayerName.fajr,
        time: nextDay.fajr,
      );
      tomorrow = true;
    }

    final width = widget.compact ? 166.0 : 208.0;

    return Container(
      width: width,
      padding: EdgeInsets.all(widget.compact ? 13 : 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(widget.compact ? 16 : 18),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                .withValues(alpha: context.isDarkMode ? 0.34 : 0.09),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF39B98A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'SHALAT BERIKUTNYA',
                style: TextStyle(
                  fontSize: widget.compact ? 7 : 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: palette.muted,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.compact ? 8 : 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      next.name.label,
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: widget.compact ? 23 : 28,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: palette.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tomorrow ? 'besok \u00b7 ${widget.cityName}' : widget.cityName,
                      style: TextStyle(
                        fontSize: widget.compact ? 9.5 : 10.5,
                        color: palette.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatClock(next.time),
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: widget.compact ? 23 : 28,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: palette.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QiblaCard extends StatelessWidget {
  const _QiblaCard({
    required this.compact,
    required this.bearing,
  });

  final bool compact;
  final double bearing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final width = compact ? 150.0 : 182.0;

    return Container(
      width: width,
      padding: EdgeInsets.all(compact ? 12 : 15),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                .withValues(alpha: context.isDarkMode ? 0.34 : 0.09),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: compact ? 34 : 40,
            height: compact ? 34 : 40,
            decoration: BoxDecoration(
              color: palette.primarySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Transform.rotate(
              angle: bearing * (3.1415926535 / 180),
              child: Icon(
                Icons.navigation_rounded,
                size: compact ? 17 : 19,
                color: palette.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'ARAH KIBLAT',
                  style: TextStyle(
                    fontSize: compact ? 7 : 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: palette.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatBearing(bearing),
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: compact ? 19 : 22,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: palette.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'dari utara',
                  style: TextStyle(
                    fontSize: compact ? 8.5 : 9.5,
                    color: palette.muted,
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
