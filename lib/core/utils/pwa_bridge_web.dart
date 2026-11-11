import 'dart:async';
import 'dart:js_interop';

import 'pwa_bridge.dart';

/// `window.bitaqwaPwa`, installed by `web/flutter_bootstrap.js`.
///
/// The getter is nullable on purpose: if the bootstrap bridge failed (or an
/// older cached bootstrap is still running), the app must keep working.
@JS('bitaqwaPwa')
external _BitaqwaPwa? get _bitaqwaPwa;

/// Plain object emitted by the bridge on every state change.
extension type _PwaSnapshot(JSObject _) implements JSObject {
  external bool get updateReady;
  external String get install;
  external bool get standalone;
  external bool get offline;
}

/// The bridge surface exposed by `web/flutter_bootstrap.js`.
extension type _BitaqwaPwa(JSObject _) implements JSObject {
  external _PwaSnapshot get state;
  external void subscribe(JSFunction listener);
  external void unsubscribe(JSFunction listener);
  external bool promptInstall();
  external bool applyUpdate();
  external bool checkForUpdate();
}

class WebPwaBridge implements PwaBridge {
  WebPwaBridge() {
    final api = _bitaqwaPwa;
    if (api == null) return;

    _api = api;
    _state = _read(api);
    _supported = true;

    try {
      final listener = _handleSnapshot.toJS;
      _listener = listener;
      api.subscribe(listener);
    } catch (_) {
      // A broken bridge must degrade to "unsupported", never throw.
      _listener = null;
      _supported = false;
    }
  }

  final StreamController<PwaState> _changes =
      StreamController<PwaState>.broadcast();

  _BitaqwaPwa? _api;
  JSFunction? _listener;
  PwaState _state = PwaState.unsupported;
  bool _supported = false;
  bool _disposed = false;

  @override
  bool get isSupported => _supported;

  @override
  PwaState get state => _state;

  @override
  Stream<PwaState> get states async* {
    yield _state;
    yield* _changes.stream;
  }

  @override
  Future<bool> promptInstall() async {
    final api = _api;
    if (api == null || _disposed) return false;
    try {
      return api.promptInstall();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> applyUpdate() async {
    final api = _api;
    if (api == null || _disposed) return false;
    try {
      return api.applyUpdate();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> checkForUpdate() async {
    final api = _api;
    if (api == null || _disposed) return false;
    try {
      return api.checkForUpdate();
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    final api = _api;
    final listener = _listener;
    if (api != null && listener != null) {
      try {
        api.unsubscribe(listener);
      } catch (_) {
        // Detaching is best-effort; the page is going away anyway.
      }
    }

    _api = null;
    _listener = null;
    if (!_changes.isClosed) unawaited(_changes.close());
  }

  /// Called by the bridge with a fresh snapshot object.
  void _handleSnapshot(JSObject snapshot) {
    if (_disposed) return;
    final next = _decode(snapshot);
    if (next == null || next == _state) return;
    _state = next;
    if (!_changes.isClosed) _changes.add(next);
  }

  PwaState _read(_BitaqwaPwa api) {
    try {
      return _decode(api.state) ?? PwaState.unsupported;
    } catch (_) {
      return PwaState.unsupported;
    }
  }

  PwaState? _decode(JSObject raw) {
    try {
      final snapshot = _PwaSnapshot(raw);
      return PwaState(
        updateReady: snapshot.updateReady,
        install: _installState(snapshot.install),
        standalone: snapshot.standalone,
        offline: snapshot.offline,
      );
    } catch (_) {
      // An unexpected shape must not crash the app; keep the last state.
      return null;
    }
  }

  static PwaInstallState _installState(String value) {
    return switch (value) {
      'available' => PwaInstallState.available,
      'installed' => PwaInstallState.installed,
      _ => PwaInstallState.unavailable,
    };
  }
}

PwaBridge createPwaBridge() => WebPwaBridge();
