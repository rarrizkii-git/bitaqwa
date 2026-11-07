import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/reminders.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/islamic_art.dart';

class ReminderSection extends ConsumerStatefulWidget {
  const ReminderSection({super.key});

  @override
  ConsumerState<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends ConsumerState<ReminderSection> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ref.read(reduceMotionProvider)) _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 9), (_) {
      if (mounted) _next();
    });
  }

  void _next() {
    setState(() => _index = (_index + 1) % Reminders.all.length);
  }

  void _previous() {
    setState(
      () => _index = (_index - 1 + Reminders.all.length) % Reminders.all.length,
    );
  }

  void _select(int index) {
    setState(() => _index = index);
    if (!ref.read(reduceMotionProvider)) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reminder = Reminders.all[_index];
    final reduceMotion = ref.watch(reduceMotionProvider);

    return Container(
      color: palette.background,
      padding: EdgeInsets.symmetric(
        horizontal: context.pageGutter,
        vertical: context.isMobile ? 46 : 70,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF062E23), Color(0xFF0A5540)],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFD6B77C).withValues(alpha: 0.28),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: context.isDarkMode ? 0.4 : 0.16,
                  ),
                  blurRadius: 44,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: IslamicPattern(
                      color: Colors.white,
                      opacity: 0.045,
                      spacing: 62,
                    ),
                  ),
                ),
                Positioned(
                  right: -40,
                  top: -60,
                  child: Opacity(
                    opacity: 0.14,
                    child: RotatingStar(
                      size: 210,
                      color: const Color(0xFFD6B77C),
                      opacity: 1,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsive(
                      mobile: 24.0,
                      tablet: 48.0,
                      desktop: 64.0,
                    ),
                    vertical: context.responsive(
                      mobile: 34.0,
                      tablet: 46.0,
                      desktop: 54.0,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 26,
                            height: 1,
                            color: const Color(0xFFD6B77C)
                                .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'RENUNGAN DARI AL-QUR\u2019AN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.4,
                              color: const Color(0xFFE8D4A8)
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 26,
                            height: 1,
                            color: const Color(0xFFD6B77C)
                                .withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                      SizedBox(height: context.isMobile ? 26 : 34),
                      AnimatedSwitcher(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 550),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.045),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          key: ValueKey<String>(reminder.id),
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 860),
                              child: Text(
                                reminder.arabic,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: AppTypography.arabic(
                                  fontSize: context.responsive(
                                    mobile: 25.0,
                                    tablet: 32.0,
                                    desktop: 38.0,
                                  ),
                                  color: const Color(0xFFF7F2E7),
                                  height: 1.9,
                                ),
                              ),
                            ),
                            SizedBox(height: context.isMobile ? 20 : 24),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 680),
                              child: Text(
                                '\u201c${reminder.translation}\u201d',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      height: 1.65,
                                      fontWeight: FontWeight.w500,
                                      fontSize: context.responsive(
                                        mobile: 14.5,
                                        desktop: 16.5,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              reminder.reference,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: const Color(0xFFE8D4A8)
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.isMobile ? 28 : 34),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _ArrowButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Renungan sebelumnya',
                            onTap: _previous,
                          ),
                          const SizedBox(width: 18),
                          for (int i = 0; i < Reminders.all.length; i++)
                            GestureDetector(
                              onTap: () => _select(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _index ? 22 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == _index
                                      ? const Color(0xFFE8D4A8)
                                      : Colors.white.withValues(alpha: 0.26),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          const SizedBox(width: 18),
                          _ArrowButton(
                            icon: Icons.arrow_forward_rounded,
                            tooltip: 'Renungan berikutnya',
                            onTap: _next,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      AppButton(
                        label: 'Baca Al-Qur\u2019an',
                        trailingIcon: Icons.arrow_forward_rounded,
                        size: AppButtonSize.compact,
                        variant: AppButtonVariant.inverted,
                        onPressed: () => context.go('/quran'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, size: 17, color: Colors.white),
        ),
      ),
    );
  }
}
