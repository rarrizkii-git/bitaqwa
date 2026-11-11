import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/pwa_providers.dart';
import '../../../core/theme/bitaqwa_palette.dart';
import '../../../core/utils/pwa_bridge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/settings_card.dart';

/// Install entry point for the Settings page.
///
/// Reads the existing bridge instead of listening to the browser again:
///
/// * [PwaInstallState.available] — `beforeinstallprompt` was captured, so one
///   native prompt can still be shown.
/// * [PwaInstallState.unavailable] — no programmatic prompt (Safari, Firefox,
///   or a prompt that was already consumed). A short, platform-specific guide
///   replaces the button; the card never pretends installation is one tap
///   away.
/// * [PwaInstallState.installed] or standalone display mode — nothing.
///
/// A dismissal is remembered for the page session by
/// [installPromptDismissedProvider], so the native prompt is never offered
/// twice in a row.
class InstallCard extends ConsumerWidget {
  const InstallCard({super.key, this.bottomGap = 18});

  /// Gap kept below the card. Owned by the card so a hidden card leaves no
  /// empty space in the parent column.
  final double bottomGap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No browser bridge (non-web build, or the bootstrap could not attach):
    // there is nothing to install, so stay out of the way entirely.
    if (!ref.watch(pwaBridgeProvider).isSupported) {
      return const SizedBox.shrink();
    }

    final state = ref.watch(pwaStateProvider);
    final dismissed = ref.watch(installPromptDismissedProvider);
    final installed =
        state.standalone || state.install == PwaInstallState.installed;
    if (installed || dismissed) return const SizedBox.shrink();

    final available = state.install == PwaInstallState.available;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: SettingsCard(
        icon: Icons.add_to_home_screen_rounded,
        title: 'Pasang Bitaqwa',
        description: available
            ? 'Buka dari layar utama seperti aplikasi, tanpa bilah alamat.'
            : 'Browser ini tidak menampilkan tombol pasang otomatis.',
        children: <Widget>[
          if (available) const _InstallAction() else const _InstallGuide(),
        ],
      ),
    );
  }
}

/// Native prompt path: one button, then the browser owns the dialog.
class _InstallAction extends ConsumerStatefulWidget {
  const _InstallAction();

  @override
  ConsumerState<_InstallAction> createState() => _InstallActionState();
}

class _InstallActionState extends ConsumerState<_InstallAction> {
  /// Guards a double tap while the bridge hands over to the browser.
  bool _requesting = false;

  Future<void> _requestInstall() async {
    if (_requesting) return;
    setState(() => _requesting = true);

    final shown = await ref.read(pwaStateProvider.notifier).promptInstall();
    if (!mounted) return;
    setState(() => _requesting = false);
    if (shown) return;

    // The browser refused to show the prompt (for example, the event was
    // consumed by another tab). Stop offering a button that cannot work for
    // the rest of this session.
    ref.read(installPromptDismissedProvider.notifier).dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MediaQuery.withClampedTextScaling(
          // Compact action: the label is a single line inside a fixed button,
          // so a very large text scale would overflow it.
          maxScaleFactor: 1.3,
          child: AppButton(
            label: 'Pasang aplikasi',
            icon: Icons.download_rounded,
            size: AppButtonSize.compact,
            expand: true,
            onPressed: _requesting ? null : _requestInstall,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 13,
                color: palette.goldInk,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Dipasang dari browser ini, tanpa akun dan tanpa unduhan '
                'tambahan.',
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.5,
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

/// Fallback path: the browser has no programmatic prompt, so show the real
/// menu path for the detected platform instead of a dead install button.
class _InstallGuide extends StatelessWidget {
  const _InstallGuide();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final step = _guideFor(defaultTargetPlatform);

    return Container(
      padding: const EdgeInsets.all(14),
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
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(step.icon, size: 15, color: palette.goldInk),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.body,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.6,
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

class _InstallGuideStep {
  const _InstallGuideStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

/// Installation path for the platform the browser reports.
///
/// Flutter Web maps the user agent to a [TargetPlatform], which is enough to
/// pick the right menu without shipping a user-agent parser.
_InstallGuideStep _guideFor(TargetPlatform platform) {
  switch (platform) {
    case TargetPlatform.iOS:
      return const _InstallGuideStep(
        icon: Icons.ios_share_rounded,
        title: 'Safari di iPhone atau iPad',
        body:
            'Ketuk ikon Bagikan, lalu pilih \u201cTambahkan ke Layar Utama\u201d.',
      );
    case TargetPlatform.android:
      return const _InstallGuideStep(
        icon: Icons.more_vert_rounded,
        title: 'Chrome di Android',
        body:
            'Buka menu \u22ee, lalu pilih \u201cInstal aplikasi\u201d atau '
            '\u201cTambahkan ke layar utama\u201d.',
      );
    case TargetPlatform.macOS:
      return const _InstallGuideStep(
        icon: Icons.laptop_mac_rounded,
        title: 'Safari atau Chrome di Mac',
        body:
            'Safari: Berkas \u2192 Tambahkan ke Dock. Chrome: klik ikon instal '
            'di bilah alamat.',
      );
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return const _InstallGuideStep(
        icon: Icons.install_desktop_rounded,
        title: 'Chrome atau Edge di komputer',
        body:
            'Klik ikon instal di bilah alamat, atau buka menu browser lalu '
            'pilih \u201cInstal Bitaqwa\u201d.',
      );
  }
}
