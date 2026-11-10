import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/data/surahs.dart';
import '../../../core/models/prayer_times.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/city_picker.dart';
import '../../../shared/widgets/reveal.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final city = ref.watch(selectedCityProvider);
    final method = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(asrMadhabProvider);

    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: 'Pengaturan',
            title: 'Sesuaikan Bitaqwa dengan ritme ibadahmu.',
            description:
                'Atur tampilan, lokasi, metode perhitungan, dan pengalaman membaca. '
                'Semua preferensi disimpan di perangkat ini tanpa akun.',
            action: const ThemeToggleButton(),
            meta: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                SoftBadge(
                  label: city.label,
                  icon: Icons.location_on_outlined,
                ),
                SoftBadge(
                  label: method.label,
                  icon: Icons.tune_rounded,
                  color: palette.gold,
                ),
                SoftBadge(
                  label: 'Ashar ${madhab.label}',
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
          ),
          Container(
            color: palette.background,
            padding: EdgeInsets.only(
              left: context.pageGutter,
              right: context.pageGutter,
              top: context.isMobile ? 32 : 44,
              bottom: context.isMobile ? 56 : 84,
            ),
            child: ContentWidth(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 940;
                  final appearance = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Reveal(child: const _AppearanceCard()),
                      const SizedBox(height: 18),
                      Reveal(
                        delay: const Duration(milliseconds: 70),
                        child: const _ReaderCard(),
                      ),
                      const SizedBox(height: 18),
                      Reveal(
                        delay: const Duration(milliseconds: 120),
                        child: _DataCard(
                          onClearBookmarks: () => _clearBookmarks(context, ref),
                          onClearDhikr: () => _clearDhikr(context, ref),
                          onResetPreferences: () =>
                              _resetPreferences(context, ref),
                        ),
                      ),
                    ],
                  );
                  final prayer = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Reveal(
                        delay: const Duration(milliseconds: 50),
                        child: const _LocationCard(),
                      ),
                      const SizedBox(height: 18),
                      Reveal(
                        delay: const Duration(milliseconds: 100),
                        child: const _AboutCard(),
                      ),
                    ],
                  );
                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        appearance,
                        const SizedBox(height: 18),
                        prayer,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 11, child: appearance),
                      const SizedBox(width: 20),
                      Expanded(flex: 9, child: prayer),
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

  Future<void> _clearBookmarks(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Hapus semua bookmark?',
      message:
          'Bookmark surah, bookmark doa, kajian tersimpan, dan penanda terakhir '
          'dibaca akan dihapus dari perangkat ini.',
      confirmLabel: 'Hapus bookmark',
    );
    if (!confirmed) return;
    await ref.read(preferencesProvider).clearBookmarks();
    ref.read(surahBookmarksProvider.notifier).clear();
    ref.read(duaBookmarksProvider.notifier).clear();
    ref.read(kajianBookmarksProvider.notifier).clear();
    ref.read(lastReadSurahProvider.notifier).clear();
    if (!context.mounted) return;
    _notify(context, 'Semua bookmark telah dihapus.');
  }

  Future<void> _clearDhikr(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Hapus hitungan zikir?',
      message:
          'Seluruh hitungan zikir dan target tersimpan akan dihapus. Pilihan zikir kembali ke pengaturan awal.',
      confirmLabel: 'Hapus hitungan',
    );
    if (!confirmed) return;
    await ref.read(preferencesProvider).clearDhikr();
    ref.invalidate(dhikrProvider);
    if (!context.mounted) return;
    _notify(context, 'Hitungan zikir telah dihapus.');
  }

  Future<void> _resetPreferences(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Kembalikan pengaturan awal?',
      message:
          'Tema, pengurangan gerak, ukuran teks Arab, lokasi, metode perhitungan, dan pilihan '
          'terjemahan akan kembali ke bawaan. Bookmark dan hitungan zikir tidak terhapus.',
      confirmLabel: 'Kembalikan',
    );
    if (!confirmed) return;
    await ref.read(preferencesProvider).resetPreferences();
    ref.invalidate(themeModeProvider);
    ref.invalidate(reduceMotionProvider);
    ref.invalidate(arabicScaleProvider);
    ref.invalidate(showTranslationProvider);
    ref.invalidate(showLatinProvider);
    ref.invalidate(selectedCityProvider);
    ref.invalidate(calculationMethodProvider);
    ref.invalidate(asrMadhabProvider);
    if (!context.mounted) return;
    _notify(context, 'Pengaturan telah dikembalikan ke bawaan.');
  }
}

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final themeMode = ref.watch(themeModeProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final arabicScale = ref.watch(arabicScaleProvider);

    return _SettingsCard(
      icon: Icons.palette_outlined,
      title: 'Tampilan',
      description: 'Bitaqwa mengikuti tema sistem, atau pilih sendiri.',
      children: <Widget>[
        _ThemeSelector(
          value: themeMode,
          onChanged: (mode) =>
              ref.read(themeModeProvider.notifier).setMode(mode),
        ),
        const SizedBox(height: 18),
        _SwitchRow(
          title: 'Kurangi gerakan',
          subtitle:
              'Matikan animasi masuk, parallax, dan gerakan berulang untuk kenyamanan.',
          value: reduceMotion,
          onChanged: (value) =>
              ref.read(reduceMotionProvider.notifier).setValue(value),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Ukuran teks Arab',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.text,
                ),
              ),
            ),
            Text(
              '${(arabicScale * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: palette.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: arabicScale,
          min: 0.8,
          max: 1.5,
          divisions: 14,
          semanticFormatterCallback: (value) =>
              'Ukuran teks Arab ${(value * 100).round()} persen',
          onChanged: (value) =>
              ref.read(arabicScaleProvider.notifier).setValue(value),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          decoration: BoxDecoration(
            color: palette.primarySoft.withValues(
              alpha: context.isDarkMode ? 0.4 : 0.55,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            children: <Widget>[
              Text(
                '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064e\u0647\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0670\u0646\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: AppTypography.arabic(
                  fontSize: 27 * arabicScale,
                  color: context.isDarkMode
                      ? const Color(0xFFCDEFE1)
                      : palette.primaryDeep,
                  height: 1.9,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pratinjau ukuran teks pada pembaca Al-Qur\u2019an dan doa.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, color: palette.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = <(ThemeMode, String, IconData)>[
      (ThemeMode.light, 'Terang', Icons.light_mode_outlined),
      (ThemeMode.dark, 'Gelap', Icons.dark_mode_outlined),
      (ThemeMode.system, 'Sistem', Icons.brightness_auto_outlined),
    ];
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(
          alpha: context.isDarkMode ? 0.55 : 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: <Widget>[
          for (final option in options)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onChanged(option.$1),
                  borderRadius: BorderRadius.circular(11),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 190),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: value == option.$1
                          ? palette.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: value == option.$1
                            ? palette.primary.withValues(alpha: 0.22)
                            : Colors.transparent,
                      ),
                      boxShadow: value == option.$1
                          ? <BoxShadow>[
                              BoxShadow(
                                color: (context.isDarkMode
                                        ? Colors.black
                                        : palette.primaryDeep)
                                    .withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          option.$3,
                          size: 15,
                          color: value == option.$1
                              ? palette.primary
                              : palette.muted,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            option.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: value == option.$1
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: value == option.$1
                                  ? palette.primary
                                  : palette.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReaderCard extends ConsumerWidget {
  const _ReaderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final showTranslation = ref.watch(showTranslationProvider);
    final showLatin = ref.watch(showLatinProvider);
    final lastRead = ref.watch(lastReadSurahProvider);

    return _SettingsCard(
      icon: Icons.menu_book_outlined,
      title: 'Pengalaman membaca',
      description: 'Preferensi ini dipakai di pembaca Al-Qur\u2019an.',
      children: <Widget>[
        _SwitchRow(
          title: 'Tampilkan terjemahan',
          subtitle: 'Terjemahan bahasa Indonesia dari sumber Al Quran Cloud.',
          value: showTranslation,
          onChanged: (value) =>
              ref.read(showTranslationProvider.notifier).setValue(value),
        ),
        const SizedBox(height: 12),
        _SwitchRow(
          title: 'Tampilkan transliterasi',
          subtitle: 'Bacaan Latin untuk membantu pelafalan.',
          value: showLatin,
          onChanged: (value) =>
              ref.read(showLatinProvider.notifier).setValue(value),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.surfaceAlt.withValues(
              alpha: context.isDarkMode ? 0.55 : 0.6,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.bookmark_border_rounded,
                size: 17,
                color: palette.gold,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      lastRead == null
                          ? 'Belum ada bacaan terakhir'
                          : 'Terakhir dibaca',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: palette.muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lastRead == null
                          ? 'Mulai dari surah mana pun.'
                          : Surahs.byNumber(lastRead).name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.text,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.go(
                  lastRead == null ? '/quran' : '/quran/$lastRead',
                ),
                child: Text(lastRead == null ? 'Buka' : 'Lanjutkan'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends ConsumerWidget {
  const _LocationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final city = ref.watch(selectedCityProvider);
    final method = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(asrMadhabProvider);

    return _SettingsCard(
      icon: Icons.my_location_rounded,
      title: 'Lokasi & perhitungan',
      description:
          'Jadwal shalat dan arah kiblat menyesuaikan kota serta metode yang dipilih.',
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showCityPicker(context),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Kota',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: palette.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${city.label} \u00b7 ${city.timezoneLabel}',
                          style: TextStyle(
                            fontSize: 11,
                            color: palette.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_location_alt_outlined,
                    size: 18,
                    color: palette.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Metode perhitungan',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: palette.text,
          ),
        ),
        const SizedBox(height: 8),
        for (final option in CalculationMethod.values)
          _RadioRow(
            title: option.label,
            subtitle: option.description,
            selected: option == method,
            onTap: () =>
                ref.read(calculationMethodProvider.notifier).select(option),
          ),
        const SizedBox(height: 12),
        Text(
          'Madzhab Ashar',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: palette.text,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: palette.surfaceAlt.withValues(
              alpha: context.isDarkMode ? 0.55 : 0.65,
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: <Widget>[
              for (final option in AsrMadhab.values)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          ref.read(asrMadhabProvider.notifier).select(option),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: option == madhab
                              ? palette.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: option == madhab
                                ? palette.primary.withValues(alpha: 0.22)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: option == madhab
                                ? palette.primary
                                : palette.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SourceNote(
          text:
              'Jadwal shalat adalah perkiraan astronomis dari posisi matahari. '
              'Ikuti jadwal resmi masjid atau otoritas setempat untuk kepastian.',
          icon: Icons.info_outline_rounded,
        ),
      ],
    );
  }
}

class _DataCard extends ConsumerWidget {
  const _DataCard({
    required this.onClearBookmarks,
    required this.onClearDhikr,
    required this.onResetPreferences,
  });

  final VoidCallback onClearBookmarks;
  final VoidCallback onClearDhikr;
  final VoidCallback onResetPreferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final surahBookmarks = ref.watch(surahBookmarksProvider);
    final duaBookmarks = ref.watch(duaBookmarksProvider);
    final kajianBookmarks = ref.watch(kajianBookmarksProvider);
    final dhikr = ref.watch(dhikrProvider);

    return _SettingsCard(
      icon: Icons.lock_outline_rounded,
      title: 'Data & privasi',
      description:
          'Bitaqwa tidak memiliki akun dan tidak mengirim data pribadi ke server.',
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _CountPill(
              icon: Icons.menu_book_outlined,
              label: '${surahBookmarks.length} surah tersimpan',
            ),
            _CountPill(
              icon: Icons.volunteer_activism_outlined,
              label: '${duaBookmarks.length} doa tersimpan',
            ),
            _CountPill(
              icon: Icons.ondemand_video_outlined,
              label: '${kajianBookmarks.length} kajian tersimpan',
            ),
            _CountPill(
              icon: Icons.spa_outlined,
              label: '${dhikr.totalCount} hitungan zikir',
            ),
          ],
        ),
        const SizedBox(height: 18),
        _ActionRow(
          title: 'Hapus bookmark',
          subtitle: 'Surah, doa, kajian, dan penanda terakhir dibaca.',
          onTap: onClearBookmarks,
        ),
        const SizedBox(height: 8),
        _ActionRow(
          title: 'Hapus hitungan zikir',
          subtitle: 'Mengembalikan semua hitungan dan target ke awal.',
          onTap: onClearDhikr,
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Kembalikan pengaturan awal',
          icon: Icons.restart_alt_rounded,
          size: AppButtonSize.compact,
          variant: AppButtonVariant.secondary,
          expand: true,
          onPressed: onResetPreferences,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.shield_outlined,
              size: 14,
              color: palette.muted,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Preferensi, bookmark, dan hitungan disimpan di penyimpanan lokal browser. '
                'Menghapus data peramban juga akan menghapus data ini.',
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.55,
                  color: palette.muted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _SettingsCard(
      icon: Icons.info_outline_rounded,
      title: 'Tentang Bitaqwa',
      description: AppConstants.description,
      children: <Widget>[
        _InfoRow(label: 'Versi', value: '1.0.0'),
        const SizedBox(height: 10),
        _InfoRow(label: 'Platform', value: 'Flutter Web'),
        const SizedBox(height: 10),
        _InfoRow(label: 'Teks Al-Qur\u2019an', value: AppConstants.quranSource),
        const SizedBox(height: 10),
        _InfoRow(
          label: 'Terjemahan',
          value: AppConstants.quranTranslation,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.surfaceAlt.withValues(
              alpha: context.isDarkMode ? 0.55 : 0.6,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.volunteer_activism_outlined,
                    size: 15,
                    color: palette.gold,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Niat dan batasan',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: palette.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                'Bitaqwa adalah alat bantu belajar dan pengingat ibadah, bukan pengganti '
                'bimbingan guru, mushaf, kitab hadis, atau keputusan otoritas keagamaan. '
                'Periksa kembali sumber setiap konten sebelum diamalkan.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.65,
                  color: palette.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            AppButton(
              label: 'Al-Qur\u2019an',
              icon: Icons.menu_book_outlined,
              size: AppButtonSize.compact,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.go('/quran'),
            ),
            AppButton(
              label: 'Jadwal shalat',
              icon: Icons.access_time_rounded,
              size: AppButtonSize.compact,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.go('/jadwal-shalat'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: palette.primarySoft.withValues(
                    alpha: context.isDarkMode ? 0.55 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: palette.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: palette.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: palette.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? palette.primarySoft.withValues(
                alpha: context.isDarkMode ? 0.55 : 1,
              )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 170),
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
                        ? const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? palette.primary : palette.text,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.4,
                          color: palette.muted,
                        ),
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: palette.text,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.4,
                        color: palette.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.delete_outline_rounded,
                size: 17,
                color: palette.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(
          alpha: context.isDarkMode ? 0.55 : 0.65,
        ),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: palette.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: palette.muted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: palette.text,
            ),
          ),
        ),
      ],
    );
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final palette = dialogContext.palette;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: palette.primary),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

void _notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
