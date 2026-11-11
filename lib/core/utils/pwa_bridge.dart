import 'dart:async';

import 'package:flutter/foundation.dart';

import 'pwa_bridge_stub.dart'
    if (dart.library.js_interop) 'pwa_bridge_web.dart'
    as implementation;

/// How the browser currently exposes Bitaqwa's install affordance.
enum PwaInstallState {
  /// A `beforeinstallprompt` event was captured, so [PwaBridge.promptInstall]
  /// can still be used once in this page session.
  available,

  /// Bitaqwa is running as an installed app (standalone display mode, or the
  /// browser reported `appinstalled`).
  installed,

  /// The browser offers no programmatic install prompt (Safari, Firefox, or
  /// the prompt has already been consumed and dismissed).
  unavailable,
}

/// Snapshot of the browser-level PWA lifecycle.
///
/// This is intentionally a value object: the UI reads it, never mutates it,
/// and every change arrives through [PwaBridge.states].
@immutable
class PwaState {
  const PwaState({
    this.updateReady = false,
    this.install = PwaInstallState.unavailable,
    this.standalone = false,
    this.offline = false,
  });

  /// A new service worker finished installing and is waiting for an explicit
  /// user approval. Nothing activates on its own.
  final bool updateReady;

  /// Whether the browser can show an install prompt right now.
  final PwaInstallState install;

  /// The app is running in standalone (installed) display mode.
  final bool standalone;

  /// `navigator.onLine` reported no network. Advisory only: it does not prove
  /// that the internet is reachable, only that no interface is connected.
  final bool offline;

  /// State used outside the web and whenever the bridge is unavailable.
  static const PwaState unsupported = PwaState();

  PwaState copyWith({
    bool? updateReady,
    PwaInstallState? install,
    bool? standalone,
    bool? offline,
  }) {
    return PwaState(
      updateReady: updateReady ?? this.updateReady,
      install: install ?? this.install,
      standalone: standalone ?? this.standalone,
      offline: offline ?? this.offline,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PwaState &&
            other.updateReady == updateReady &&
            other.install == install &&
            other.standalone == standalone &&
            other.offline == offline;
  }

  @override
  int get hashCode => Object.hash(updateReady, install, standalone, offline);

  @override
  String toString() {
    return 'PwaState(updateReady: $updateReady, install: ${install.name}, '
        'standalone: $standalone, offline: $offline)';
  }
}

/// Thin, testable facade over the browser PWA lifecycle.
///
/// The web implementation talks to `window.bitaqwaPwa`, which
/// `web/flutter_bootstrap.js` installs before Flutter starts. Every operation
/// is best-effort and returns `false` instead of throwing, so callers never
/// need to guard against a missing or broken bridge.
abstract interface class PwaBridge {
  /// Whether a real browser bridge is attached. `false` on non-web targets and
  /// whenever the bootstrap could not expose `window.bitaqwaPwa`.
  bool get isSupported;

  /// Latest known state.
  PwaState get state;

  /// State changes. Emits the current state immediately on listen, then once
  /// per change.
  Stream<PwaState> get states;

  /// Shows the browser's install prompt. Returns `false` when the prompt is
  /// unavailable or was already consumed.
  Future<bool> promptInstall();

  /// Activates a waiting service worker after an explicit user action.
  ///
  /// This is the only path that calls `skipWaiting()`. It must never be
  /// invoked automatically.
  Future<bool> applyUpdate();

  /// Asks the browser to re-fetch `sw.js` and look for a newer version.
  Future<bool> checkForUpdate();

  /// Detaches from the browser. Safe to call more than once.
  void dispose();
}

/// Creates the bridge for the current platform.
PwaBridge createPwaBridge() => implementation.createPwaBridge();
