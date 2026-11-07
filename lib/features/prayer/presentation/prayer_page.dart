import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/prayer_times.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/prayer_calculator.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/city_picker.dart';
import '../../../shared/widgets/prayer_visuals.dart';
import '../../../shared/widgets/reveal.dart';

class PrayerPage extends ConsumerStatefulWidget {
  const PrayerPage({super.key});

  @override
  ConsumerState<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends ConsumerState<PrayerPage> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isToday {
    final today = DateTime(_now.year, _now.month, _now.day);
    return _selectedDate == today;
  }

  void _shiftDay(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime(_now.year, _now.month, _now.day);
    });
  }

  Future<void> _pickDate() async {
    final today = DateTime(_now.year, _now.month, _now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
      helpText: 'Pilih tanggal jadwal',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    final method = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(asrMadhabProvider);
    final schedule = ref.watch(prayerTimesProvider(_selectedDate));

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Jadwal Shalat',
            title: 'Waktu untuk kembali pada-Nya.',
            description:
                'Jadwal lima waktu untuk ${city.name}, dihitung secara astronomis di perangkatmu. Pilih tanggal, kota, dan metode perhitungan sesuai kebutuhan.',
            action: const CityPickerButton(),
            meta: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SoftBadge(
                  label: city.timezoneLabel,
                  icon: Icons.public_rounded,
                  color: context.palette.gold,
                ),
                SoftBadge(
                  label: method.label,
                  icon: Icons.tune_rounded,
                ),
                SoftBadge(
                  label: 'Ashar ${madhab.label}',
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
          ),
          Container(
            color: context.palette.background,
            padding: context.sectionPadding,
            child: ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _DateNavigator(
                    date: _selectedDate,
                    isToday: _isToday,
                    onPrevious: () => _shiftDay(-1),
                    onNext: () => _shiftDay(1),
                    onToday: _goToToday,
                    onPick: _pickDate,
                  ),
                  const SizedBox(height: 26),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 1000;
                      final left = _PrayerSchedulePanel(
                        schedule: schedule,
                        now: _now,
                        isToday: _isToday,
                      );
                      final right = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _CalculationCard(
                            method: method,
                            madhab: madhab,
                            cityLabel: city.label,
                          ),
                          const SizedBox(height: 20),
                          _WeekAhead(
                            start: _selectedDate,
                            selected: _selectedDate,
                            onSelect: (date) {
                              setState(() => _selectedDate = date);
                            },
                          ),
                          const SizedBox(height: 20),
                          const _NotesCard(),
                        ],
                      );

                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Reveal(child: left),
                            const SizedBox(height: 20),
                            Reveal(
                              delay: const Duration(milliseconds: 100),
                              child: right,
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(flex: 11, child: Reveal(child: left)),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 9,
                            child: Reveal(
                              delay: const Duration(milliseconds: 100),
                              child: right,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.date,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onPick,
  });

  final DateTime date;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Hari sebelumnya',
                visualDensity: VisualDensity.compact,
              ),
              Container(
                width: 1,
                height: 22,
                color: palette.border,
              ),
              InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: palette.primary,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        isToday
                            ? 'Hari ini \u00b7 ${formatDateShort(date)}'
                            : formatDateShort(date),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.text,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: palette.muted,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 22,
                color: palette.border,
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Hari berikutnya',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        if (!isToday)
          TextButton.icon(
            onPressed: onToday,
            icon: const Icon(Icons.today_rounded, size: 16),
            label: const Text('Kembali ke hari ini'),
          ),
        if (!isToday)
          SoftBadge(
            label: relativeDayLabel(date, DateTime.now()),
            icon: Icons.info_outline_rounded,
            color: palette.gold,
          ),
      ],
    );
  }
}

class _PrayerSchedulePanel extends ConsumerWidget {
  const _PrayerSchedulePanel({
    required this.schedule,
    required this.now,
    required this.isToday,
  });

  final PrayerTimes schedule;
  final DateTime now;
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final city = ref.watch(selectedCityProvider);

    PrayerScheduleEntry? next;
    var tomorrow = false;
    if (isToday) {
      next = schedule.nextPrayerAfter(now);
      if (next == null) {
        final method = ref.watch(calculationMethodProvider);
        final madhab = ref.watch(asrMadhabProvider);
        final nextDay = PrayerCalculator.calculate(
          city: city,
          method: method,
          madhab: madhab,
          date: schedule.date.add(const Duration(days: 1)),
        );
        next = PrayerScheduleEntry(
          name: PrayerName.fajr,
          time: nextDay.fajr,
        );
        tomorrow = true;
      }
    } else {
      next = schedule.prayers.first;
    }

    final active = isToday ? schedule.activePrayerAt(now) : null;
    final countdown = next.time.difference(now);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                .withValues(alpha: context.isDarkMode ? 0.3 : 0.07),
            blurRadius: 38,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        formatDateLong(schedule.date),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 24,
                                  color: palette.text,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${city.label} \u00b7 ${city.timezoneLabel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.primarySoft,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: palette.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: palette.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: palette.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF064E3B), Color(0xFF0F7557)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isToday
                        ? (tomorrow
                            ? 'MENUJU SUBUH BESOK'
                            : 'SHALAT BERIKUTNYA')
                        : 'SHALAT PERTAMA HARI INI',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: Colors.white.withValues(alpha: 0.66),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                                fontSize: 34,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.6,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${formatClock(next.time)} \u00b7 ${next.name.arabic}',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isToday)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              formatCountdown(countdown),
                              style: const TextStyle(
                                fontFamily: 'Fraunces',
                                fontSize: 26,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Color(0xFFE8D4A8),
                                fontFeatures: <FontFeature>[
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              countdown.isNegative ? 'segera' : 'lagi',
                              style: TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 1,
                                color: Colors.white.withValues(alpha: 0.58),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            child: Column(
              children: <Widget>[
                for (final entry in schedule.entries)
                  PrayerTimeRow(
                    entry: entry,
                    isNext: isToday && !tomorrow && entry.name == next.name,
                    isActive: isToday &&
                        active?.name == entry.name &&
                        entry.name != next.name,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: palette.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ditambah ihtiyati 2 menit untuk Subuh, Dzuhur, Ashar, Maghrib, dan Isya. '
                    'Jadwal ini adalah perkiraan astronomis; ikuti jadwal resmi masjid atau otoritas setempat.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.muted,
                          height: 1.55,
                        ),
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

class _CalculationCard extends ConsumerWidget {
  const _CalculationCard({
    required this.method,
    required this.madhab,
    required this.cityLabel,
  });

  final CalculationMethod method;
  final AsrMadhab madhab;
  final String cityLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.tune_rounded, size: 17, color: palette.primary),
              const SizedBox(width: 8),
              Text(
                'Perhitungan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              AppTextLink(
                label: 'Atur',
                icon: Icons.settings_outlined,
                onTap: () => context.go('/pengaturan'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Lokasi',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: palette.muted,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            cityLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Metode',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: palette.muted,
            ),
          ),
          const SizedBox(height: 6),
          for (final option in CalculationMethod.values)
            _MethodOption(
              label: option.label,
              selected: option == method,
              onTap: () =>
                  ref.read(calculationMethodProvider.notifier).select(option),
            ),
          const SizedBox(height: 12),
          Text(
            'Ashar',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: palette.muted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (final option in AsrMadhab.values)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: option == AsrMadhab.shafi ? 8 : 0,
                    ),
                    child: _MadhabButton(
                      label: option.label,
                      selected: option == madhab,
                      onTap: () =>
                          ref.read(asrMadhabProvider.notifier).select(option),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SourceNote(
            text:
                'Sudut: Fajar ${method.fajrAngle.toStringAsFixed(1)}\u00b0, '
                '${method.ishaAngle != null ? 'Isya ${method.ishaAngle!.toStringAsFixed(1)}\u00b0' : 'Isya ${method.ishaIntervalMinutes} menit setelah Maghrib'}.',
            icon: Icons.functions_rounded,
          ),
        ],
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? palette.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? palette.primary : palette.border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? palette.primary : palette.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MadhabButton extends StatelessWidget {
  const _MadhabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? palette.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? palette.primary.withValues(alpha: 0.3) : palette.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? palette.primary : palette.muted,
          ),
        ),
      ),
    );
  }
}

class _WeekAhead extends ConsumerWidget {
  const _WeekAhead({
    required this.start,
    required this.selected,
    required this.onSelect,
  });

  final DateTime start;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final city = ref.watch(selectedCityProvider);
    final method = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(asrMadhabProvider);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.date_range_rounded, size: 17, color: palette.primary),
              const SizedBox(width: 8),
              Text(
                'Tujuh hari',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                'Ketuk untuk pindah',
                style: TextStyle(fontSize: 10.5, color: palette.muted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = DateTime(
                  start.year,
                  start.month,
                  start.day + index,
                );
                final schedule = PrayerCalculator.calculate(
                  city: city,
                  method: method,
                  madhab: madhab,
                  date: date,
                );
                final isSelected = date == selected;
                final isToday = date == normalizedToday;
                return _DayCard(
                  date: date,
                  fajr: schedule.fajr,
                  maghrib: schedule.maghrib,
                  selected: isSelected,
                  today: isToday,
                  onTap: () => onSelect(date),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.date,
    required this.fajr,
    required this.maghrib,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final DateTime date;
  final DateTime fajr;
  final DateTime maghrib;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const weekdayShort = <String>[
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min',
    ];
    final label = weekdayShort[(date.weekday - 1) % 7];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 78,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? palette.primarySoft
              : (today ? palette.surfaceAlt : Colors.transparent),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? palette.primary.withValues(alpha: 0.35)
                : palette.border,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: selected ? palette.primary : palette.muted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${date.day}',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: selected ? palette.primary : palette.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatClock(fajr),
              style: TextStyle(fontSize: 9.5, color: palette.muted),
            ),
            Text(
              formatClock(maghrib),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: selected ? palette.primary : palette.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'subuh \u00b7 maghrib',
              style: TextStyle(fontSize: 6.5, color: palette.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.child_care_rounded, size: 17, color: palette.gold),
              const SizedBox(width: 8),
              Text(
                'Catatan penting',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bitaqwa menghitung waktu shalat dari posisi matahari menggunakan lintang, bujur, dan zona waktu kotamu. '
            'Hasil dapat berbeda satu hingga tiga menit dari jadwal resmi karena perbedaan metode, ketinggian tempat, dan pembulatan.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                  height: 1.65,
                ),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Buka pengaturan',
            icon: Icons.settings_outlined,
            size: AppButtonSize.compact,
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: () => context.go('/pengaturan'),
          ),
        ],
      ),
    );
  }
}
