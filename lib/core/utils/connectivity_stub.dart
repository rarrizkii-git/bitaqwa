import 'dart:async';

import 'connectivity.dart';

/// Non-web fallback. Bitaqwa ships as a Flutter Web application, so this exists
/// to keep the facade importable under `flutter test` and on any future
/// non-web target.
class StubConnectivity implements Connectivity {
  const StubConnectivity();

  @override
  bool get isOnline => true;

  @override
  Stream<bool> get changes => const Stream<bool>.empty();

  @override
  void dispose() {}
}

Connectivity createConnectivity() => const StubConnectivity();
