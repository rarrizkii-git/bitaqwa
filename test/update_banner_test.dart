import 'dart:async';

import 'package:bitaqwa/core/providers/app_providers.dart';
import 'package:bitaqwa/core/providers/pwa_providers.dart';
import 'package:bitaqwa/core/services/preferences_service.dart';
import 'package:bitaqwa/core/theme/bitaqwa_palette.dart';
import 'package:bitaqwa/core/utils/pwa_bridge.dart';
import 'package:bitaqwa/features/pwa/presentation/update_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal browser stand-in. The banner only needs the state stream plus the
/// `applyUpdate` call count, so this fake stays deliberately small.
class _FakePwaBridge implements PwaBridge {
  _FakePwaBridge({PwaState initial = PwaState.unsupported}) : _state = initial;

  final StreamController<PwaState> _changes =
      StreamController<PwaState>.broadcast();

  PwaState _state;
  bool applyUpdateResult = true;
  int applyUpdateCalls = 0;

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
  Future<bool> promptInstall() async => false;

  @override
  Future<bool> applyUpdate() async {
    applyUpdateCalls += 1;
    return applyUpdateResult;
  }

  @override
  Future<bool> checkForUpdate() async => false;

  @override
  void dispose() => _changes.close();
}

const PwaState _pendingUpdate = PwaState(updateReady: true);
const Key _contentKey = Key('page-content');
const String _bannerTitle = 'Versi baru Bitaqwa tersedia';

/// Mounts the banner the same way `_SiteShell` does: inside a [Stack] overlay
/// above the page content.
Future<ProviderContainer> _pumpBanner(
  WidgetTester tester, {
  required _FakePwaBridge bridge,
  Size size = const Size(1000, 800),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();

  final container = ProviderContainer.test(
    overrides: [
      pwaBridgeFactoryProvider.overrideWithValue(() => bridge),
      preferencesProvider.overrideWithValue(PreferencesService(preferences)),
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
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: UpdateBanner(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _openConfirmation(WidgetTester tester) async {
  await tester.tap(find.text('Perbarui sekarang'));
  await tester.pumpAndSettle();
}

Finder _inDialog(String text) =>
    find.descendant(of: find.byType(Dialog), matching: find.text(text));

void main() {
  group('UpdateBanner visibility', () {
    testWidgets('stays hidden while no update is waiting', (tester) async {
      await _pumpBanner(tester, bridge: _FakePwaBridge());

      expect(find.text(_bannerTitle), findsNothing);
      expect(find.text('Perbarui sekarang'), findsNothing);
    });

    testWidgets('shows the notice and primary action when updateReady is set', (
      tester,
    ) async {
      await _pumpBanner(
        tester,
        bridge: _FakePwaBridge(initial: _pendingUpdate),
      );

      expect(find.text(_bannerTitle), findsOneWidget);
      expect(
        find.text('Muat ulang untuk memakai pembaruan terbaru.'),
        findsOneWidget,
      );
      expect(find.text('Perbarui sekarang'), findsOneWidget);
      expect(find.byTooltip('Tutup untuk sesi ini'), findsOneWidget);
    });

    testWidgets('appears when the bridge reports an update later', (
      tester,
    ) async {
      final bridge = _FakePwaBridge();
      await _pumpBanner(tester, bridge: bridge);
      expect(find.text(_bannerTitle), findsNothing);

      bridge.emit(_pendingUpdate);
      await tester.pumpAndSettle();

      expect(find.text(_bannerTitle), findsOneWidget);
    });

    testWidgets('never shifts the page layout', (tester) async {
      final bridge = _FakePwaBridge();
      await _pumpBanner(tester, bridge: bridge);
      final before = tester.getRect(find.byKey(_contentKey));

      bridge.emit(_pendingUpdate);
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byKey(_contentKey)), before);
      expect(before.size, const Size(1000, 800));
    });

    testWidgets('fits a phone screen without clipping the action', (
      tester,
    ) async {
      const size = Size(390, 844);
      await _pumpBanner(
        tester,
        bridge: _FakePwaBridge(initial: _pendingUpdate),
        size: size,
      );

      expect(find.text(_bannerTitle), findsOneWidget);
      final action = tester.getRect(find.text('Perbarui sekarang'));
      expect(action.left, greaterThanOrEqualTo(0));
      expect(action.right, lessThanOrEqualTo(size.width));
      expect(action.bottom, lessThanOrEqualTo(size.height));
      expect(find.byTooltip('Tutup untuk sesi ini'), findsOneWidget);
    });

    testWidgets('stays usable at a large text scale', (tester) async {
      // Flutter tests render every glyph at a full em, which is far wider than
      // the bundled typeface, so this runs at desktop width to exercise the
      // clamp rather than the test font.
      await _pumpBanner(
        tester,
        bridge: _FakePwaBridge(initial: _pendingUpdate),
        textScale: 2,
      );

      expect(find.text(_bannerTitle), findsOneWidget);
      expect(find.text('Perbarui sekarang'), findsOneWidget);
    });
  });

  group('UpdateBanner dismissal', () {
    testWidgets('closing hides it for the session', (tester) async {
      final container = await _pumpBanner(
        tester,
        bridge: _FakePwaBridge(initial: _pendingUpdate),
      );

      await tester.tap(find.byTooltip('Tutup untuk sesi ini'));
      await tester.pumpAndSettle();

      expect(find.text(_bannerTitle), findsNothing);
      expect(container.read(updateBannerDismissedProvider), isTrue);
    });

    testWidgets('a later update reopens it after a dismissal', (tester) async {
      final bridge = _FakePwaBridge(initial: _pendingUpdate);
      final container = await _pumpBanner(tester, bridge: bridge);

      await tester.tap(find.byTooltip('Tutup untuk sesi ini'));
      await tester.pumpAndSettle();
      expect(find.text(_bannerTitle), findsNothing);

      bridge.emit(const PwaState(updateReady: false));
      await tester.pumpAndSettle();
      bridge.emit(_pendingUpdate);
      await tester.pumpAndSettle();

      expect(find.text(_bannerTitle), findsOneWidget);
      expect(container.read(updateBannerDismissedProvider), isFalse);
    });
  });

  group('UpdateBanner confirmation', () {
    testWidgets('asks before applying and mentions unsaved changes', (
      tester,
    ) async {
      final bridge = _FakePwaBridge(initial: _pendingUpdate);
      await _pumpBanner(tester, bridge: bridge);

      await _openConfirmation(tester);

      expect(find.text('Perbarui Bitaqwa sekarang?'), findsOneWidget);
      expect(
        find.textContaining('akan dimuat ulang untuk memakai versi terbaru'),
        findsOneWidget,
      );
      expect(find.textContaining('akan hilang'), findsOneWidget);
      expect(bridge.applyUpdateCalls, 0);
    });

    testWidgets('confirmation fits a phone screen', (tester) async {
      const size = Size(390, 844);
      await _pumpBanner(
        tester,
        bridge: _FakePwaBridge(initial: _pendingUpdate),
        size: size,
      );

      await _openConfirmation(tester);

      expect(find.text('Perbarui Bitaqwa sekarang?'), findsOneWidget);
      final confirm = tester.getRect(_inDialog('Perbarui sekarang'));
      expect(confirm.right, lessThanOrEqualTo(size.width));
      expect(confirm.bottom, lessThanOrEqualTo(size.height));
    });

    testWidgets('cancelling keeps the notice and applies nothing', (
      tester,
    ) async {
      final bridge = _FakePwaBridge(initial: _pendingUpdate);
      await _pumpBanner(tester, bridge: bridge);

      await _openConfirmation(tester);
      await tester.tap(_inDialog('Nanti'));
      await tester.pumpAndSettle();

      expect(bridge.applyUpdateCalls, 0);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text(_bannerTitle), findsOneWidget);
    });

    testWidgets('confirming applies the update exactly once', (tester) async {
      final bridge = _FakePwaBridge(initial: _pendingUpdate);
      await _pumpBanner(tester, bridge: bridge);

      await _openConfirmation(tester);
      await tester.tap(_inDialog('Perbarui sekarang'));
      await tester.pumpAndSettle();

      expect(bridge.applyUpdateCalls, 1);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('explains when the bridge cannot apply the update', (
      tester,
    ) async {
      final bridge = _FakePwaBridge(initial: _pendingUpdate)
        ..applyUpdateResult = false;
      await _pumpBanner(tester, bridge: bridge);

      await _openConfirmation(tester);
      await tester.tap(_inDialog('Perbarui sekarang'));
      await tester.pumpAndSettle();

      expect(
        find.text('Pembaruan belum siap. Coba lagi sebentar lagi.'),
        findsOneWidget,
      );
      expect(find.text(_bannerTitle), findsOneWidget);
    });
  });
}
