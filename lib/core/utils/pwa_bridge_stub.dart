import 'dart:async';

import 'pwa_bridge.dart';

/// Non-web fallback. Bitaqwa currently ships as a Flutter Web application, so
/// this exists to keep the facade importable under `flutter test` and any
/// future non-web target.
class StubPwaBridge implements PwaBridge {
  const StubPwaBridge();

  @override
  bool get isSupported => false;

  @override
  PwaState get state => PwaState.unsupported;

  @override
  Stream<PwaState> get states => Stream<PwaState>.value(PwaState.unsupported);

  @override
  Future<bool> promptInstall() async => false;

  @override
  Future<bool> applyUpdate() async => false;

  @override
  Future<bool> checkForUpdate() async => false;

  @override
  void dispose() {}
}

PwaBridge createPwaBridge() => const StubPwaBridge();
