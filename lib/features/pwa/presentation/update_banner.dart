import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/providers/pwa_providers.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/app_button.dart';

/// Floating notice shown when a new service worker is waiting.
///
/// The banner is mounted inside the shell's [Stack], so it never takes part in
/// layout and cannot shift the page or the navigation. It only reports the
/// pending update: activation and reload stay in the Step 1 bridge
/// ([PwaStateNotifier.applyUpdate] → `skipWaiting` → `controllerchange`).
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateReady = ref.watch(
      pwaStateProvider.select((state) => state.updateReady),
    );
    final dismissed = ref.watch(updateBannerDismissedProvider);
    final reduceMotion =
        ref.watch(reduceMotionProvider) ||
        MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260);

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.22),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: updateReady && !dismissed
          ? MediaQuery.withClampedTextScaling(
              // Compact chrome: keep the notice legible without letting a very
              // large text scale overflow the fixed-height action.
              maxScaleFactor: 1.3,
              child: const _UpdateCard(key: ValueKey<String>('update-banner')),
            )
          : const SizedBox.shrink(
              key: ValueKey<String>('update-banner-hidden'),
            ),
    );
  }
}

class _UpdateCard extends ConsumerStatefulWidget {
  const _UpdateCard({super.key});

  @override
  ConsumerState<_UpdateCard> createState() => _UpdateCardState();
}

class _UpdateCardState extends ConsumerState<_UpdateCard> {
  /// Guards against opening a second confirmation dialog on a double tap.
  bool _confirming = false;

  Future<void> _requestUpdate() async {
    if (_confirming) return;
    setState(() => _confirming = true);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const _UpdateConfirmDialog(),
    );

    if (!mounted) return;
    setState(() => _confirming = false);
    if (confirmed != true) return;

    // The bridge posts SKIP_WAITING and reloads on controllerchange. Nothing
    // here reloads the page manually.
    final applied = await ref.read(pwaStateProvider.notifier).applyUpdate();
    if (!mounted || applied) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Pembaruan belum siap. Coba lagi sebentar lagi.'),
        ),
      );
  }

  void _dismiss() => ref.read(updateBannerDismissedProvider.notifier).dismiss();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDarkMode;
    final stacked =
        context.isMobile || MediaQuery.textScalerOf(context).scale(1) > 1.25;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(
        left: context.isMobile ? 14 : 24,
        right: context.isMobile ? 14 : 24,
        bottom: context.isMobile ? 14 : 22,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            liveRegion: true,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: palette.primary.withValues(
                    alpha: isDark ? 0.34 : 0.16,
                  ),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: (isDark ? Colors.black : palette.primaryDeep)
                        .withValues(alpha: isDark ? 0.4 : 0.13),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: stacked
                      ? _buildStacked(context)
                      : _buildInline(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInline(BuildContext context) {
    return Row(
      children: <Widget>[
        const _UpdateBadge(),
        const SizedBox(width: 14),
        const Expanded(child: _UpdateCopy()),
        const SizedBox(width: 16),
        AppButton(
          label: 'Perbarui sekarang',
          icon: Icons.refresh_rounded,
          size: AppButtonSize.compact,
          onPressed: _requestUpdate,
        ),
        const SizedBox(width: 2),
        _dismissButton(context),
      ],
    );
  }

  Widget _buildStacked(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _UpdateBadge(),
            const SizedBox(width: 12),
            const Expanded(child: _UpdateCopy()),
            _dismissButton(context),
          ],
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Perbarui sekarang',
          icon: Icons.refresh_rounded,
          size: AppButtonSize.compact,
          expand: true,
          onPressed: _requestUpdate,
        ),
      ],
    );
  }

  Widget _dismissButton(BuildContext context) {
    final palette = context.palette;
    return IconButton(
      tooltip: 'Tutup untuk sesi ini',
      onPressed: _dismiss,
      icon: const Icon(Icons.close_rounded, size: 18),
      style: IconButton.styleFrom(
        foregroundColor: palette.muted,
        hoverColor: palette.primary.withValues(alpha: 0.08),
      ),
    );
  }
}

class _UpdateBadge extends StatelessWidget {
  const _UpdateBadge();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: palette.primarySoft.withValues(
          alpha: context.isDarkMode ? 0.55 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.refresh_rounded, size: 20, color: palette.primary),
    );
  }
}

class _UpdateCopy extends StatelessWidget {
  const _UpdateCopy();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Versi baru Bitaqwa tersedia',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
            height: 1.3,
            color: palette.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Muat ulang untuk memakai pembaruan terbaru.',
          style: TextStyle(fontSize: 11.5, height: 1.45, color: palette.muted),
        ),
      ],
    );
  }
}

class _UpdateConfirmDialog extends StatelessWidget {
  const _UpdateConfirmDialog();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color:
                      (context.isDarkMode ? Colors.black : palette.primaryDeep)
                          .withValues(alpha: context.isDarkMode ? 0.45 : 0.16),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Perbarui Bitaqwa sekarang?',
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 21,
                      height: 1.2,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bitaqwa akan dimuat ulang untuk memakai versi terbaru.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13.5,
                      height: 1.6,
                      color: palette.muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt.withValues(
                        alpha: context.isDarkMode ? 0.55 : 0.6,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: palette.goldInk,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Perubahan yang belum disimpan akan hilang jika Bitaqwa '
                            'dimuat ulang.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.55,
                              color: palette.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      AppButton(
                        label: 'Nanti',
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.compact,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      AppButton(
                        label: 'Perbarui sekarang',
                        icon: Icons.refresh_rounded,
                        size: AppButtonSize.compact,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
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
