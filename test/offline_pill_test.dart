import 'dart:async';

import 'package:bitaqwa/core/providers/app_providers.dart';
import 'package:bitaqwa/core/providers/connectivity_providers.dart';
import 'package:bitaqwa/core/theme/bitaqwa_palette.dart';
import 'package:bitaqwa/core/utils/connectivity.dart';
import 'package:bitaqwa/features/pwa/presentation/offline_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const String _pillLabel = 'Koneksi terputus';
const String _semanticsLabel = 'Koneksi internet terputus';
const Key _contentKey = Key('page-content');

/// Stand-in for the browser connectivity source. The pill only needs the
/// current value plus the change feed, so this fake stays deliberately small.
class _FakeConnectivity implements Connectivity {
  _FakeConnectivity({this.online = true});

  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  bool online;
  int disposeCalls = 0;

  @override
  bool get isOnline => online;

  @override
  Stream<bool> get changes => _changes.stream;

  void setOnline(bool value) {
    if (online == value) return;
    online = value;
    _changes.add(value);
  }

  @override
  void dispose() {
    if (disposeCalls > 0) return;
    disposeCalls += 1;
    _changes.close();
  }
}

class _FixedReduceMotion extends ReduceMotionNotifier {
  _FixedReduceMotion(this.value);

  final bool value;

  @override
  bool build() => value;
}

/// Mounts the pill the same way `_SiteShell` does: inside a [Stack] overlay
/// above the page content, below the navigation.
Future<ProviderContainer> _pumpPill(
  WidgetTester tester, {
  required _FakeConnectivity connectivity,
  bool reduceMotion = false,
  Size size = const Size(1000, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer.test(
    overrides: [
      connectivityFactoryProvider.overrideWithValue(() => connectivity),
      reduceMotionProvider.overrideWith(() => _FixedReduceMotion(reduceMotion)),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: const <ThemeExtension<dynamic>>[BitaqwaPalette.light],
        ),
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(key: _contentKey, color: Colors.white),
              ),
              const Positioned(left: 0, right: 0, top: 0, child: OfflinePill()),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

/// Advances past the show delay and lets the transition finish.
Future<void> _settleVisible(WidgetTester tester) async {
  await tester.pump(OfflinePill.showDelay + const Duration(milliseconds: 20));
  await tester.pumpAndSettle();
}

void main() {
  group('OfflinePill visibility', () {
    testWidgets('waits for the 700 ms delay before showing', (tester) async {
      final connectivity = _FakeConnectivity(online: false);
      await _pumpPill(tester, connectivity: connectivity);

      expect(find.text(_pillLabel), findsNothing);

      await tester.pump(const Duration(milliseconds: 650));
      expect(find.text(_pillLabel), findsNothing);

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(_pillLabel), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('stays hidden while the browser is online', (tester) async {
      final connectivity = _FakeConnectivity(online: true);
      await _pumpPill(tester, connectivity: connectivity);

      await tester.pump(const Duration(seconds: 2));

      expect(find.text(_pillLabel), findsNothing);
    });

    testWidgets('hides as soon as connectivity returns', (tester) async {
      final connectivity = _FakeConnectivity(online: false);
      final container = await _pumpPill(tester, connectivity: connectivity);
      await _settleVisible(tester);
      expect(find.text(_pillLabel), findsOneWidget);

      connectivity.setOnline(true);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text(_pillLabel), findsNothing);
      expect(container.read(connectivityProvider), isTrue);
    });

    testWidgets('appears when the browser drops later', (tester) async {
      final connectivity = _FakeConnectivity(online: true);
      final container = await _pumpPill(tester, connectivity: connectivity);

      connectivity.setOnline(false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(_pillLabel), findsNothing);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text(_pillLabel), findsOneWidget);
      expect(container.read(connectivityProvider), isFalse);
    });
  });

  group('OfflinePill flapping', () {
    testWidgets('rapid offline/online changes leave no stale notice', (
      tester,
    ) async {
      final connectivity = _FakeConnectivity(online: true);
      final container = await _pumpPill(tester, connectivity: connectivity);

      for (var i = 0; i < 3; i++) {
        connectivity.setOnline(false);
        await tester.pump(const Duration(milliseconds: 300));
        connectivity.setOnline(true);
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text(_pillLabel), findsNothing);
      expect(container.read(connectivityProvider), isTrue);
    });

    testWidgets('a new short drop does not resurrect the notice early', (
      tester,
    ) async {
      final connectivity = _FakeConnectivity(online: false);
      await _pumpPill(tester, connectivity: connectivity);
      await _settleVisible(tester);
      expect(find.text(_pillLabel), findsOneWidget);

      connectivity.setOnline(true);
      await tester.pumpAndSettle();
      expect(find.text(_pillLabel), findsNothing);

      // Back offline, but only for 300 ms: the notice must wait again.
      connectivity.setOnline(false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(_pillLabel), findsNothing);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(_pillLabel), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('OfflinePill platform safety', () {
    test('the VM fallback reports online and never emits', () async {
      final connectivity = createConnectivity();
      addTearDown(connectivity.dispose);

      expect(connectivity.isOnline, isTrue);
      expect(
        await connectivity.changes.isEmpty.timeout(const Duration(seconds: 1)),
        isTrue,
      );
    });

    test('connectivityProvider defaults to online under flutter test', () {
      final container = ProviderContainer.test();

      expect(container.read(connectivityProvider), isTrue);
    });
  });

  group('OfflinePill presentation', () {
    testWidgets('never shifts the page layout', (tester) async {
      final connectivity = _FakeConnectivity(online: true);
      await _pumpPill(tester, connectivity: connectivity);
      final before = tester.getRect(find.byKey(_contentKey));

      connectivity.setOnline(false);
      await _settleVisible(tester);

      expect(tester.getRect(find.byKey(_contentKey)), before);
      expect(before.size, const Size(1000, 800));
      expect(find.text(_pillLabel), findsOneWidget);
    });

    testWidgets('fits a phone screen', (tester) async {
      const size = Size(390, 844);
      final connectivity = _FakeConnectivity(online: false);
      await _pumpPill(tester, connectivity: connectivity, size: size);
      await _settleVisible(tester);

      final pill = tester.getRect(find.text(_pillLabel));
      expect(pill.left, greaterThanOrEqualTo(0));
      expect(pill.right, lessThanOrEqualTo(size.width));
      expect(pill.top, greaterThanOrEqualTo(0));
    });

    testWidgets('collapses the transition under reduced motion', (
      tester,
    ) async {
      final connectivity = _FakeConnectivity(online: false);
      await _pumpPill(tester, connectivity: connectivity, reduceMotion: true);
      await _settleVisible(tester);

      final switcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(switcher.duration, Duration.zero);
      expect(find.text(_pillLabel), findsOneWidget);
    });

    testWidgets('animates when motion is allowed', (tester) async {
      final connectivity = _FakeConnectivity(online: false);
      await _pumpPill(tester, connectivity: connectivity);
      await tester.pump(
        OfflinePill.showDelay + const Duration(milliseconds: 20),
      );
      await tester.pump();

      final switcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(switcher.duration, OfflinePill.transition);
      await tester.pumpAndSettle();
    });

    testWidgets('announces the offline state as a single live region', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      final connectivity = _FakeConnectivity(online: false);
      await _pumpPill(tester, connectivity: connectivity);
      await _settleVisible(tester);

      final node = find.bySemanticsLabel(_semanticsLabel);
      expect(node, findsOneWidget);
      expect(
        tester.getSemantics(node),
        isSemantics(label: _semanticsLabel, isLiveRegion: true),
      );
      // The visible text is excluded, so it is not announced twice.
      expect(find.bySemanticsLabel(_pillLabel), findsNothing);

      connectivity.setOnline(true);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(_semanticsLabel), findsNothing);

      semantics.dispose();
    });
  });
}
