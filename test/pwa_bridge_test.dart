import 'dart:async';

import 'package:bitaqwa/core/providers/pwa_providers.dart';
import 'package:bitaqwa/core/utils/pwa_bridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stand-in for the browser bridge so the provider layer can be exercised on
/// the Dart VM, where the conditional import resolves to the stub.
class _FakePwaBridge implements PwaBridge {
  _FakePwaBridge({PwaState initial = PwaState.unsupported}) : _state = initial;

  final StreamController<PwaState> _changes =
      StreamController<PwaState>.broadcast();

  PwaState _state;
  bool disposed = false;
  bool promptInstallResult = false;
  bool applyUpdateResult = false;
  bool checkForUpdateResult = false;
  int promptInstallCalls = 0;
  int applyUpdateCalls = 0;
  int checkForUpdateCalls = 0;

  void emit(PwaState next) {
    _state = next;
    _changes.add(next);
  }

  @override
  bool get isSupported => true;

  @override
  PwaState get state => _state;

  @override
  Stream<PwaState> get states => _changes.stream;

  @override
  Future<bool> promptInstall() async {
    promptInstallCalls++;
    return promptInstallResult;
  }

  @override
  Future<bool> applyUpdate() async {
    applyUpdateCalls++;
    return applyUpdateResult;
  }

  @override
  Future<bool> checkForUpdate() async {
    checkForUpdateCalls++;
    return checkForUpdateResult;
  }

  @override
  void dispose() {
    disposed = true;
    _changes.close();
  }
}

void main() {
  group('PwaState', () {
    test('defaults to an unavailable, online, browser-tab snapshot', () {
      const state = PwaState.unsupported;
      expect(state.updateReady, isFalse);
      expect(state.install, PwaInstallState.unavailable);
      expect(state.standalone, isFalse);
      expect(state.offline, isFalse);
    });

    test('implements value equality', () {
      const a = PwaState(
        updateReady: true,
        install: PwaInstallState.available,
        standalone: true,
        offline: true,
      );
      const b = PwaState(
        updateReady: true,
        install: PwaInstallState.available,
        standalone: true,
        offline: true,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const PwaState(updateReady: true)));
    });

    test('copyWith changes one field and keeps the rest', () {
      const state = PwaState(
        updateReady: true,
        install: PwaInstallState.installed,
        standalone: true,
        offline: true,
      );
      final next = state.copyWith(offline: false);
      expect(next.offline, isFalse);
      expect(next.updateReady, isTrue);
      expect(next.install, PwaInstallState.installed);
      expect(next.standalone, isTrue);
    });
  });

  group('createPwaBridge', () {
    test('resolves to the inert stub off the web', () async {
      final bridge = createPwaBridge();
      addTearDown(bridge.dispose);

      expect(bridge.isSupported, isFalse);
      expect(bridge.state, PwaState.unsupported);
      expect(await bridge.promptInstall(), isFalse);
      expect(await bridge.applyUpdate(), isFalse);
      expect(await bridge.checkForUpdate(), isFalse);
      expect(await bridge.states.toList(), <PwaState>[PwaState.unsupported]);
    });

    test('dispose is idempotent', () {
      final bridge = createPwaBridge();
      bridge.dispose();
      expect(bridge.dispose, returnsNormally);
    });
  });

  group('pwaStateProvider', () {
    test('starts from the bridge state and follows emissions', () async {
      final bridge = _FakePwaBridge();
      final container = ProviderContainer.test(
        overrides: [pwaBridgeFactoryProvider.overrideWithValue(() => bridge)],
      );
      final subscription = container.listen(pwaStateProvider, (_, _) {});
      addTearDown(subscription.close);

      expect(container.read(pwaStateProvider), PwaState.unsupported);

      bridge.emit(
        const PwaState(
          updateReady: true,
          install: PwaInstallState.available,
          offline: true,
        ),
      );
      await pumpEventQueue();

      final state = container.read(pwaStateProvider);
      expect(state.updateReady, isTrue);
      expect(state.install, PwaInstallState.available);
      expect(state.offline, isTrue);
      expect(state.standalone, isFalse);
    });

    test('delegates install, update, and check operations', () async {
      final bridge = _FakePwaBridge()
        ..promptInstallResult = true
        ..applyUpdateResult = true
        ..checkForUpdateResult = true;
      final container = ProviderContainer.test(
        overrides: [pwaBridgeFactoryProvider.overrideWithValue(() => bridge)],
      );
      final subscription = container.listen(pwaStateProvider, (_, _) {});
      addTearDown(subscription.close);

      final notifier = container.read(pwaStateProvider.notifier);
      expect(await notifier.promptInstall(), isTrue);
      expect(await notifier.applyUpdate(), isTrue);
      expect(await notifier.checkForUpdate(), isTrue);
      expect(bridge.promptInstallCalls, 1);
      expect(bridge.applyUpdateCalls, 1);
      expect(bridge.checkForUpdateCalls, 1);
    });

    test('detaches the bridge when the container is disposed', () {
      final bridge = _FakePwaBridge();
      final container = ProviderContainer.test(
        overrides: [pwaBridgeFactoryProvider.overrideWithValue(() => bridge)],
      );
      final subscription = container.listen(pwaStateProvider, (_, _) {});

      expect(container.read(pwaBridgeProvider), same(bridge));
      expect(bridge.disposed, isFalse);
      subscription.close();
      container.dispose();
      expect(bridge.disposed, isTrue);
    });
  });
}
