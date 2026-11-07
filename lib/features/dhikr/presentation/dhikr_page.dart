import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/dhikr_presets.dart';
import '../../../core/models/dhikr.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/layout/page_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/reveal.dart';

class DhikrPage extends ConsumerStatefulWidget {
  const DhikrPage({super.key});

  @override
  ConsumerState<DhikrPage> createState() => _DhikrPageState();
}

class _DhikrPageState extends ConsumerState<DhikrPage> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'dhikr-counter');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _increment() {
    final before = ref.read(dhikrProvider);
    ref.read(dhikrProvider.notifier).increment();
    unawaited(HapticFeedback.selectionClick());
    final after = ref.read(dhikrProvider);
    if (!before.isComplete && after.isComplete) {
      _showMessage(
        'Target ${after.target} \u00d7 ${after.preset.title} tercapai. Semoga menjadi amal yang diterima.',
      );
    }
  }

  void _decrement() {
    ref.read(dhikrProvider.notifier).decrement();
    unawaited(HapticFeedback.selectionClick());
  }

  void _showMessage(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter) {
      _increment();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      _decrement();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _editTarget() async {
    final current = ref.read(dhikrProvider).target;
    final next = await showDialog<int>(
      context: context,
      builder: (context) => _TargetDialog(initialTarget: current),
    );
    if (next != null) {
      ref.read(dhikrProvider.notifier).setTarget(next);
      _showMessage('Target diubah menjadi $next hitungan.');
    }
  }

  Future<void> _selectPreset(DhikrPreset preset) async {
    final current = ref.read(dhikrProvider).presetId;
    if (current == preset.id) {
      _focusNode.requestFocus();
      return;
    }
    ref.read(dhikrProvider.notifier).selectPreset(preset);
    _focusNode.requestFocus();
  }

  Future<void> _resetActive() async {
    ref.read(dhikrProvider.notifier).resetActive();
    _showMessage('Hitungan zikir aktif dikembalikan ke nol.');
  }

  Future<void> _resetAll() async {
    final confirmed = await _confirm(
      context,
      title: 'Hapus semua hitungan zikir?',
      message:
          'Seluruh hitungan untuk semua jenis zikir akan dihapus dari perangkat ini. '
          'Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus semua',
    );
    if (!confirmed) return;
    await ref.read(preferencesProvider).clearDhikr();
    ref.invalidate(dhikrProvider);
    _showMessage('Semua hitungan zikir telah dihapus.');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dhikr = ref.watch(dhikrProvider);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: PageScaffold(
        child: Column(
          children: <Widget>[
            PageHeader(
              eyebrow: 'Zikir',
              title: 'Tenangkan hati dengan mengingat-Nya.',
              description:
                  'Pilih zikir, tetapkan target, lalu ketuk lingkaran untuk menghitung. '
                  'Hitungan tersimpan otomatis di perangkatmu sehingga bisa dilanjutkan kapan saja.',
              action: AppButton(
                label: 'Koleksi doa',
                icon: Icons.volunteer_activism_outlined,
                trailingIcon: Icons.arrow_forward_rounded,
                size: AppButtonSize.compact,
                onPressed: () => context.go('/doa'),
              ),
              meta: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  SoftBadge(
                    label: '${DhikrPresets.all.length} pilihan zikir',
                    icon: Icons.spa_outlined,
                  ),
                  SoftBadge(
                    label: '${dhikr.totalCount} total hitungan',
                    icon: Icons.touch_app_outlined,
                    color: palette.gold,
                  ),
                  const SoftBadge(
                    label: 'Tersimpan otomatis',
                    icon: Icons.save_outlined,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 940;
                        final counter = Reveal(
                          child: _CounterCard(
                            state: dhikr,
                            onIncrement: () {
                              _focusNode.requestFocus();
                              _increment();
                            },
                            onDecrement: _decrement,
                            onReset: _resetActive,
                            onEditTarget: _editTarget,
                          ),
                        );
                        final side = Reveal(
                          delay: const Duration(milliseconds: 110),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _StatsCard(state: dhikr),
                              const SizedBox(height: 18),
                              _PresetList(
                                activeId: dhikr.presetId,
                                counts: dhikr.counts,
                                onSelect: _selectPreset,
                              ),
                              const SizedBox(height: 18),
                              _DataCard(onResetAll: _resetAll),
                            ],
                          ),
                        );
                        if (!wide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              counter,
                              const SizedBox(height: 20),
                              side,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(flex: 11, child: counter),
                            const SizedBox(width: 22),
                            Expanded(flex: 9, child: side),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const SourceNote(
                      text:
                          'Teks zikir dan keutamaannya dikutip dari Al-Qur\u2019an serta riwayat hadis yang '
                          'tercantum pada tiap pilihan. Hitungan zikir adalah catatan pribadi di perangkat, '
                          'bukan pengganti amalan yang diwajibkan.',
                      icon: Icons.fact_check_outlined,
                    ),
                    if (!context.isMobile) ...<Widget>[
                      const SizedBox(height: 10),
                      SourceNote(
                        text:
                            'Pintasan papan tombol: Spasi atau Enter untuk menambah, Backspace untuk mengurangi.',
                        icon: Icons.keyboard_outlined,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends ConsumerWidget {
  const _CounterCard({
    required this.state,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
    required this.onEditTarget,
  });

  final DhikrState state;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;
  final VoidCallback onEditTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final preset = state.preset;

    return Container(
      padding: EdgeInsets.all(context.isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (context.isDarkMode ? Colors.black : palette.primaryDeep)
                .withValues(alpha: context.isDarkMode ? 0.3 : 0.06),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              SoftBadge(
                label: state.isComplete ? 'TARGET TERCAPAI' : 'ZIKIR AKTIF',
                icon: state.isComplete
                    ? Icons.verified_rounded
                    : Icons.radio_button_checked_rounded,
                color: state.isComplete ? palette.gold : palette.primary,
              ),
              const Spacer(),
              IconButton(
                onPressed: onDecrement,
                tooltip: 'Kurangi satu hitungan',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              IconButton(
                onPressed: onReset,
                tooltip: 'Reset hitungan zikir aktif',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.restart_alt_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            preset.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  color: palette.text,
                ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF064E3B), Color(0xFF0F7557)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  preset.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: AppTypography.arabic(
                    fontSize: context.responsive(mobile: 28.0, desktop: 36.0),
                    color: Colors.white,
                    height: 1.85,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  preset.latin,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.76),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  preset.translation,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.55,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: _CounterDial(
              count: state.currentCount,
              target: state.target,
              complete: state.isComplete,
              onTap: onIncrement,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Text(
                'Target',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: palette.muted,
                ),
              ),
              for (final value in <int>[33, 34, 99, 100])
                _TargetChip(
                  label: '$value',
                  selected: state.target == value,
                  onTap: () =>
                      ref.read(dhikrProvider.notifier).setTarget(value),
                ),
              AppTextLink(
                label: 'Atur target',
                icon: Icons.tune_rounded,
                onTap: onEditTarget,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              state.isComplete
                  ? 'Target tercapai. Lanjutkan bila masih lapang, atau reset untuk sesi baru.'
                  : 'Ketuk lingkaran di atas untuk menambah satu hitungan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.5,
                color: palette.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? palette.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected
                  ? palette.primary.withValues(alpha: 0.35)
                  : palette.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: selected ? palette.primary : palette.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterDial extends StatelessWidget {
  const _CounterDial({
    required this.count,
    required this.target,
    required this.complete,
    required this.onTap,
  });

  final int count;
  final int target;
  final bool complete;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final progress = target <= 0 ? 0.0 : (count / target).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = math.min(constraints.maxWidth, 290.0);
        return SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: palette.border,
                      color: complete ? palette.gold : palette.primary,
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Semantics(
                    button: true,
                    label:
                        'Tambah hitungan zikir. Saat ini $count dari $target.',
                    child: Tooltip(
                      message: 'Ketuk untuk menambah hitungan',
                      child: Material(
                        color: Colors.transparent,
                        child: InkResponse(
                          onTap: onTap,
                          containedInkWell: true,
                          highlightShape: BoxShape.circle,
                          radius: diameter / 2,
                          child: Ink(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: palette.surfaceAlt.withValues(
                                alpha: context.isDarkMode ? 0.8 : 1,
                              ),
                              border: Border.all(
                                color: complete
                                    ? palette.gold.withValues(alpha: 0.5)
                                    : palette.border,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'HITUNGAN',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.8,
                                    color: palette.muted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.86,
                                      end: 1,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  ),
                                  child: Text(
                                    '$count',
                                    key: ValueKey<int>(count),
                                    style: TextStyle(
                                      fontFamily: 'Fraunces',
                                      fontSize: context.isMobile ? 52 : 64,
                                      height: 1,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -1,
                                      color: complete
                                          ? palette.gold
                                          : palette.primary,
                                      fontFeatures: const <FontFeature>[
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'dari $target',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: palette.muted,
                                  ),
                                ),
                                if (complete) ...<Widget>[
                                  const SizedBox(height: 8),
                                  SoftBadge(
                                    label: 'Selesai',
                                    icon: Icons.check_rounded,
                                    color: palette.gold,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.state});

  final DhikrState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final completed = DhikrPresets.all
        .where((preset) => (state.counts[preset.id] ?? 0) > 0)
        .length;
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
              Icon(Icons.insights_rounded, size: 18, color: palette.primary),
              const SizedBox(width: 8),
              Text(
                'Ringkasan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  label: 'Total',
                  value: '${state.totalCount}',
                  icon: Icons.functions_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Zikir',
                  value: '$completed/${DhikrPresets.all.length}',
                  icon: Icons.spa_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surfaceAlt.withValues(
                alpha: context.isDarkMode ? 0.6 : 0.7,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: palette.gold,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Sesi aktif: ${state.currentCount} dari ${state.target} hitungan '
                    '${state.preset.title}.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.5,
                      color: palette.muted,
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
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
          Icon(icon, size: 15, color: palette.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 23,
              height: 1,
              fontWeight: FontWeight.w600,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10.5, color: palette.muted),
          ),
        ],
      ),
    );
  }
}

class _PresetList extends StatelessWidget {
  const _PresetList({
    required this.activeId,
    required this.counts,
    required this.onSelect,
  });

  final String activeId;
  final Map<String, int> counts;
  final ValueChanged<DhikrPreset> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: <Widget>[
                Icon(Icons.list_alt_rounded, size: 17, color: palette.primary),
                const SizedBox(width: 8),
                Text(
                  'Pilih zikir',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${DhikrPresets.all.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final preset in DhikrPresets.all)
            _PresetRow(
              preset: preset,
              active: preset.id == activeId,
              count: counts[preset.id] ?? 0,
              onTap: () => onSelect(preset),
            ),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.preset,
    required this.active,
    required this.count,
    required this.onTap,
  });

  final DhikrPreset preset;
  final bool active;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active
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
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: active
                        ? palette.primary.withValues(alpha: 0.12)
                        : palette.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    active ? Icons.check_rounded : Icons.spa_outlined,
                    size: 14,
                    color: active ? palette.primary : palette.muted,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        preset.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? palette.primary : palette.text,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        preset.arabic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: AppTypography.arabic(
                          fontSize: 12,
                          color: palette.muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: count > 0 ? palette.primary : palette.muted,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 15,
                  color: palette.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({required this.onResetAll});

  final VoidCallback onResetAll;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(
          alpha: context.isDarkMode ? 0.5 : 0.6,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.lock_outline_rounded, size: 17, color: palette.gold),
              const SizedBox(width: 8),
              Text(
                'Data di perangkatmu',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'Hitungan disimpan di penyimpanan lokal browser. Tidak ada akun, '
            'tidak ada pengiriman data ke server.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.55,
              color: palette.muted,
            ),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Hapus semua hitungan',
            icon: Icons.delete_outline_rounded,
            size: AppButtonSize.compact,
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: onResetAll,
          ),
        ],
      ),
    );
  }
}

class _TargetDialog extends StatefulWidget {
  const _TargetDialog({required this.initialTarget});

  final int initialTarget;

  @override
  State<_TargetDialog> createState() => _TargetDialogState();
}

class _TargetDialogState extends State<_TargetDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialTarget}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value <= 0) {
      setState(() => _error = 'Masukkan angka lebih dari 0.');
      return;
    }
    if (value > 100000) {
      setState(() => _error = 'Target maksimal 100.000 hitungan.');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: palette.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Atur target zikir',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Tutup',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tentukan jumlah hitungan untuk sesi ini. Target tersimpan dan '
                'digunakan lagi pada kunjungan berikutnya.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: palette.muted),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final value in <int>[33, 34, 99, 100, 1000])
                    _TargetChip(
                      label: '$value',
                      selected: _controller.text == '$value',
                      onTap: () => setState(() => _controller.text = '$value'),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Target hitungan',
                  hintText: 'Contoh: 100',
                  errorText: _error,
                  suffixText: 'kali',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton(
                      label: 'Batal',
                      size: AppButtonSize.compact,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: 'Simpan target',
                      size: AppButtonSize.compact,
                      icon: Icons.check_rounded,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
