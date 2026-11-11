import 'dart:async';
import 'dart:js_interop';

import 'connectivity.dart';

@JS('window')
external _Window get _window;

@JS('navigator')
external _Navigator get _navigator;

extension type _Window._(JSObject _) implements JSObject {
  external void addEventListener(String type, JSFunction listener);
  external void removeEventListener(String type, JSFunction listener);
}

extension type _Navigator._(JSObject _) implements JSObject {
  external bool get onLine;
}

/// Reads `navigator.onLine` and follows the window's `online`/`offline` events.
///
/// Every browser call is best-effort: if the API is missing or throws, the
/// source degrades to "online" instead of failing into the widget tree.
class WebConnectivity implements Connectivity {
  WebConnectivity() {
    try {
      final online = _handleOnline.toJS;
      _window.addEventListener('online', online);
      _onlineListener = online;

      final offline = _handleOffline.toJS;
      _window.addEventListener('offline', offline);
      _offlineListener = offline;

      _online = _navigator.onLine;
    } catch (_) {
      final online = _onlineListener;
      final offline = _offlineListener;

      try {
        if (online != null) {
          _window.removeEventListener('online', online);
        }
        if (offline != null) {
          _window.removeEventListener('offline', offline);
        }
      } catch (_) {
        // Cleanup is best-effort.
      }

      _onlineListener = null;
      _offlineListener = null;
      _online = true;
    }
  }

  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  JSFunction? _onlineListener;
  JSFunction? _offlineListener;
  bool _online = true;
  bool _disposed = false;

  @override
  bool get isOnline => _online;

  @override
  Stream<bool> get changes => _changes.stream;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    final online = _onlineListener;
    final offline = _offlineListener;
    if (online != null && offline != null) {
      try {
        _window.removeEventListener('online', online);
        _window.removeEventListener('offline', offline);
      } catch (_) {
        // Detaching is best-effort; the page is going away anyway.
      }
    }

    _onlineListener = null;
    _offlineListener = null;
    if (!_changes.isClosed) unawaited(_changes.close());
  }

  void _handleOnline(JSAny? _) => _update(true);

  void _handleOffline(JSAny? _) => _update(false);

  void _update(bool online) {
    if (_disposed || online == _online) return;
    _online = online;
    if (!_changes.isClosed) _changes.add(online);
  }
}

Connectivity createConnectivity() => WebConnectivity();
