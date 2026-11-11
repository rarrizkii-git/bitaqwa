import 'dart:async';

import 'connectivity_stub.dart'
    if (dart.library.js_interop) 'connectivity_web.dart'
    as implementation;

/// Coarse online/offline source for the current platform.
///
/// The browser only reports whether a network interface is connected; it does
/// not prove that Bitaqwa's origin is reachable. That is enough for a status
/// indicator, and it costs nothing: the values come from `navigator.onLine`
/// plus the browser's `online`/`offline` events.
abstract interface class Connectivity {
  /// Whether the browser currently reports a connection.
  bool get isOnline;

  /// Emits `true` when the browser reconnects and `false` when it drops.
  ///
  /// This is a change feed only: it does not replay the current value on
  /// listen, so read [isOnline] first and then follow this stream.
  Stream<bool> get changes;

  /// Detaches from the browser. Safe to call more than once.
  void dispose();
}

/// Creates the connectivity source for the current platform.
Connectivity createConnectivity() => implementation.createConnectivity();
