import 'package:flutter/material.dart';

import '../../core/models/prayer_times.dart';
import '../../core/theme/bitaqwa_palette.dart';
import '../../core/utils/formatters.dart';

IconData prayerIcon(PrayerName name) => switch (name) {
      PrayerName.fajr => Icons.nightlight_round,
      PrayerName.sunrise => Icons.wb_twilight_rounded,
      PrayerName.dhuhr => Icons.light_mode_rounded,
      PrayerName.asr => Icons.wb_sunny_outlined,
      PrayerName.maghrib => Icons.brightness_4_outlined,
      PrayerName.isha => Icons.dark_mode_outlined,
    };

class PrayerIconBadge extends StatelessWidget {
  const PrayerIconBadge({
    super.key,
    required this.name,
    this.size = 38,
    this.active = false,
    this.onDark = false,
  });

  final PrayerName name;
  final double size;
  final bool active;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final background = onDark
        ? Colors.white.withValues(alpha: active ? 0.2 : 0.10)
        : active
            ? palette.primarySoft
            : palette.surfaceAlt;
    final foreground = onDark
        ? (active ? Colors.white : const Color(0xCCFFFFFF))
        : (active ? palette.primary : palette.muted);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.16)
              : (active ? palette.primary.withValues(alpha: 0.25) : palette.border),
        ),
      ),
      child: Icon(prayerIcon(name), size: size * 0.44, color: foreground),
    );
  }
}

class PrayerTimeRow extends StatelessWidget {
  const PrayerTimeRow({
    super.key,
    required this.entry,
    this.isNext = false,
    this.isActive = false,
    this.dense = false,
    this.onDark = false,
  });

  final PrayerScheduleEntry entry;
  final bool isNext;
  final bool isActive;
  final bool dense;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final highlighted = isNext || isActive;

    final foreground = onDark
        ? Colors.white
        : (highlighted ? palette.primaryDeep : palette.text);
    final muted = onDark
        ? Colors.white.withValues(alpha: 0.7)
        : palette.muted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 12 : 14,
        vertical: dense ? 9 : 11,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? (onDark
                ? Colors.white.withValues(alpha: 0.10)
                : palette.primarySoft.withValues(alpha: context.isDarkMode ? 0.55 : 0.8))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? (onDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : palette.primary.withValues(alpha: 0.2))
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: <Widget>[
          PrayerIconBadge(
            name: entry.name,
            size: dense ? 32 : 38,
            active: highlighted,
            onDark: onDark,
          ),
          SizedBox(width: dense ? 10 : 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      entry.name.label,
                      style: TextStyle(
                        fontSize: dense ? 13 : 14,
                        fontWeight:
                            highlighted ? FontWeight.w700 : FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                    if (isNext) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: palette.gold.withValues(alpha: onDark ? 0.25 : 0.16),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'BERIKUTNYA',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: onDark ? Colors.white : palette.gold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.name.arabic,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: dense ? 13 : 14,
                    height: 1.3,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatClock(entry.time),
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: dense ? 17 : 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
