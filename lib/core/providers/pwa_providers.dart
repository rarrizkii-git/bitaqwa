import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/pwa_bridge.dart';

/// Creates the platform bridge.
///
/// Tests override this with a fake so the production wiring in
/// [pwaBridgeProvider] — including disposal — is still exercised.
final pwaBridgeFactoryProvider = Provider<PwaBridge Function()>(
  (ref) => createPwaBridge,
);

/// The browser PWA bridge.
///
/// Created lazily on first read and detached with its provider.
final pwaBridgeProvider = Provider<PwaBridge>((ref) {
  final bridge = ref.watch(pwaBridgeFactoryProvider)();
  ref.onDispose(bridge.dispose);
  return bridge;
});

/// Browser PWA lifecycle state: pending update, install availability,
/// standalone mode, and the coarse online/offline flag.
///
/// Step 1 exposes state and operations only. Install, update, and offline UI
/// consume this provider in later steps.
class PwaStateNotifier extends Notifier<PwaState> {
  @override
  PwaState build() {
    final bridge = ref.watch(pwaBridgeProvider);
    final subscription = bridge.states.listen((next) {
      if (state != next) state = next;
    });
    ref.onDispose(subscription.cancel);
    return bridge.state;
  }

  /// Shows the browser install prompt. Returns `false` when unavailable.
  Future<bool> promptInstall() => ref.read(pwaBridgeProvider).promptInstall();

  /// Activates a waiting update. Only ever called from an explicit user action.
  Future<bool> applyUpdate() => ref.read(pwaBridgeProvider).applyUpdate();

  /// Asks the browser to check `sw.js` for a newer version.
  Future<bool> checkForUpdate() => ref.read(pwaBridgeProvider).checkForUpdate();
}

final pwaStateProvider = NotifierProvider<PwaStateNotifier, PwaState>(
  PwaStateNotifier.new,
);

/// Session-only dismissal of the update banner.
///
/// Deliberately in memory: closing the banner hides it until the page is
/// reloaded, and never disables future update notifications. When another
/// update becomes ready after an earlier dismissal, the banner opens again.
class UpdateBannerDismissedNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen<bool>(pwaStateProvider.select((state) => state.updateReady), (
      previous,
      next,
    ) {
      if (next && previous != true && state) state = false;
    });
    return false;
  }

  void dismiss() => state = true;
}

final updateBannerDismissedProvider =
    NotifierProvider<UpdateBannerDismissedNotifier, bool>(
      UpdateBannerDismissedNotifier.new,
    );

/// Session-only suppression of the install affordance.
///
/// A `beforeinstallprompt` event is single-use: once the browser prompt is
/// dismissed the bridge reports [PwaInstallState.unavailable] and the event
/// cannot be replayed. This flag makes the card stop offering it for the rest
/// of the page session, so the user is never asked twice in a row. It is
/// deliberately in memory; a reload starts fresh and the browser decides
/// whether a new prompt is allowed.
class InstallPromptDismissedNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen<PwaInstallState>(
      pwaStateProvider.select((state) => state.install),
      (previous, next) {
        // `available -> unavailable` only happens after `userChoice` reported
        // a dismissal (see `promptInstall` in web/flutter_bootstrap.js).
        if (previous == PwaInstallState.available &&
            next == PwaInstallState.unavailable) {
          state = true;
        }
      },
    );
    return false;
  }

  void dismiss() => state = true;
}

final installPromptDismissedProvider =
    NotifierProvider<InstallPromptDismissedNotifier, bool>(
      InstallPromptDismissedNotifier.new,
    );
