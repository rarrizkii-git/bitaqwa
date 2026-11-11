import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/connectivity.dart';

/// Creates the platform connectivity source.
///
/// Tests override this with a fake so the production wiring in
/// [connectivitySourceProvider] — including disposal — is still exercised.
final connectivityFactoryProvider = Provider<Connectivity Function()>(
  (ref) => createConnectivity,
);

/// The browser connectivity source, detached with its provider.
final connectivitySourceProvider = Provider<Connectivity>((ref) {
  final source = ref.watch(connectivityFactoryProvider)();
  ref.onDispose(source.dispose);
  return source;
});

/// Whether the browser currently reports a network connection.
///
/// Advisory only: `true` means an interface is connected, not that Bitaqwa's
/// origin is reachable.
class ConnectivityNotifier extends Notifier<bool> {
  @override
  bool build() {
    final source = ref.watch(connectivitySourceProvider);
    final subscription = source.changes.listen((online) {
      if (state != online) state = online;
    });
    ref.onDispose(subscription.cancel);
    return source.isOnline;
  }
}

final connectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(
  ConnectivityNotifier.new,
);
