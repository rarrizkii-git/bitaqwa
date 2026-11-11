import 'dart:async';

import 'package:bitaqwa/core/providers/pwa_providers.dart';
import 'package:bitaqwa/core/theme/bitaqwa_palette.dart';
import 'package:bitaqwa/core/utils/pwa_bridge.dart';
import 'package:bitaqwa/features/pwa/presentation/install_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal browser stand-in: the card only needs the state stream, the
/// `promptInstall` call count, and `isSupported`.
class _FakePwaBridge implements PwaBridge {
  _FakePwaBridge({
    PwaState initial = PwaState.unsupported,
    this.isSupported = true,
  }) : _state = initial;

  final StreamController<PwaState> _changes =
      StreamController<PwaState>.broadcast();

  PwaState _state;

  @override
  final bool isSupported;

  bool promptInstallResult = true;
  int promptInstallCalls = 0;

  void emit(PwaState next) {
    _state = next;
    _changes.add(next);
  }

  @override
  PwaState get state => _state;

  @override
  Stream<PwaState> get states => _changes.stream;

  @override
  Future<bool> promptInstall() async {
    promptInstallCalls += 1;
    return promptInstallResult;
  }

  @override
  Future<bool> applyUpdate() async => false;

  @override
  Future<bool> checkForUpdate() async => false;

  @override
  void dispose() => _changes.close();
}

const String _title = 'Pasang Bitaqwa';
const String _action = 'Pasang aplikasi';

const PwaState _installable = PwaState(install: PwaInstallState.available);

Future<ProviderContainer> _pumpCard(
  WidgetTester tester, {
  required _FakePwaBridge bridge,
  double width = 420,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final container = ProviderContainer.test(
    overrides: [pwaBridgeFactoryProvider.overrideWithValue(() => bridge)],
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const InstallCard(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Runs [body] with a fixed [defaultTargetPlatform].
///
/// The framework checks debug globals before tear-downs run, so the override
/// is restored inside the test body.
Future<void> _withPlatform(
  TargetPlatform platform,
  Future<void> Function() body,
) async {
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

void main() {
  group('InstallCard availability', () {
    testWidgets('offers the native prompt when the browser has one ready', (
      tester,
    ) async {
      await _pumpCard(tester, bridge: _FakePwaBridge(initial: _installable));

      expect(find.text(_title), findsOneWidget);
      expect(
        find.text(
          'Buka dari layar utama seperti aplikasi, tanpa bilah alamat.',
        ),
        findsOneWidget,
      );
      expect(find.text(_action), findsOneWidget);
    });

    testWidgets('shows the browser guide instead of a dead button', (
      tester,
    ) async {
      await _pumpCard(tester, bridge: _FakePwaBridge());

      expect(find.text(_title), findsOneWidget);
      expect(find.text(_action), findsNothing);
      expect(
        find.text('Browser ini tidak menampilkan tombol pasang otomatis.'),
        findsOneWidget,
      );
    });

    testWidgets('switches from the guide to the prompt when it appears', (
      tester,
    ) async {
      final bridge = _FakePwaBridge();
      await _pumpCard(tester, bridge: bridge);
      expect(find.text(_action), findsNothing);

      bridge.emit(_installable);
      await tester.pumpAndSettle();

      expect(find.text(_action), findsOneWidget);
      expect(
        find.text('Browser ini tidak menampilkan tombol pasang otomatis.'),
        findsNothing,
      );
    });
  });

  group('InstallCard hiding', () {
    testWidgets('renders nothing when Bitaqwa runs standalone', (tester) async {
      await _pumpCard(
        tester,
        bridge: _FakePwaBridge(initial: const PwaState(standalone: true)),
      );

      expect(find.text(_title), findsNothing);
      expect(tester.getSize(find.byType(InstallCard)).height, 0);
    });

    testWidgets('renders nothing when the browser reports installed', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        bridge: _FakePwaBridge(
          initial: const PwaState(install: PwaInstallState.installed),
        ),
      );

      expect(find.text(_title), findsNothing);
    });

    testWidgets('renders nothing without a browser bridge', (tester) async {
      await _pumpCard(
        tester,
        bridge: _FakePwaBridge(initial: _installable, isSupported: false),
      );

      expect(find.text(_title), findsNothing);
      expect(tester.getSize(find.byType(InstallCard)).height, 0);
    });

    testWidgets('leaves no gap behind when hidden', (tester) async {
      await _pumpCard(
        tester,
        bridge: _FakePwaBridge(initial: const PwaState(standalone: true)),
      );

      expect(tester.getSize(find.byType(InstallCard)).height, 0);
    });
  });

  group('InstallCard outcomes', () {
    testWidgets('asks the bridge exactly once per tap', (tester) async {
      final bridge = _FakePwaBridge(initial: _installable);
      await _pumpCard(tester, bridge: bridge);

      await tester.tap(find.text(_action));
      await tester.pumpAndSettle();

      expect(bridge.promptInstallCalls, 1);
    });

    testWidgets('an accepted prompt hides the card and records no dismissal', (
      tester,
    ) async {
      final bridge = _FakePwaBridge(initial: _installable);
      final container = await _pumpCard(tester, bridge: bridge);

      await tester.tap(find.text(_action));
      await tester.pumpAndSettle();
      bridge.emit(const PwaState(install: PwaInstallState.installed));
      await tester.pumpAndSettle();

      expect(find.text(_title), findsNothing);
      expect(container.read(installPromptDismissedProvider), isFalse);
    });

    testWidgets('a dismissed prompt hides the card for the session', (
      tester,
    ) async {
      final bridge = _FakePwaBridge(initial: _installable);
      final container = await _pumpCard(tester, bridge: bridge);

      await tester.tap(find.text(_action));
      await tester.pumpAndSettle();
      // The bridge reports a consumed, dismissed event.
      bridge.emit(const PwaState(install: PwaInstallState.unavailable));
      await tester.pumpAndSettle();

      expect(find.text(_title), findsNothing);
      expect(container.read(installPromptDismissedProvider), isTrue);
    });

    testWidgets('a later prompt does not reopen it in the same session', (
      tester,
    ) async {
      final bridge = _FakePwaBridge(initial: _installable);
      await _pumpCard(tester, bridge: bridge);

      await tester.tap(find.text(_action));
      await tester.pumpAndSettle();
      bridge.emit(const PwaState(install: PwaInstallState.unavailable));
      await tester.pumpAndSettle();

      bridge.emit(_installable);
      await tester.pumpAndSettle();

      expect(find.text(_title), findsNothing);
    });

    testWidgets('a prompt the browser refuses stops the offer', (tester) async {
      final bridge = _FakePwaBridge(initial: _installable)
        ..promptInstallResult = false;
      final container = await _pumpCard(tester, bridge: bridge);

      await tester.tap(find.text(_action));
      await tester.pumpAndSettle();

      expect(find.text(_title), findsNothing);
      expect(container.read(installPromptDismissedProvider), isTrue);
    });
  });

  group('InstallCard guide', () {
    testWidgets('names the Safari path on iPhone and iPad', (tester) async {
      await _withPlatform(TargetPlatform.iOS, () async {
        await _pumpCard(tester, bridge: _FakePwaBridge());

        expect(find.text('Safari di iPhone atau iPad'), findsOneWidget);
        expect(find.textContaining('Tambahkan ke Layar Utama'), findsOneWidget);
      });
    });

    testWidgets('names the Chrome menu path on Android', (tester) async {
      await _withPlatform(TargetPlatform.android, () async {
        await _pumpCard(tester, bridge: _FakePwaBridge());

        expect(find.text('Chrome di Android'), findsOneWidget);
        expect(find.textContaining('Instal aplikasi'), findsOneWidget);
      });
    });

    testWidgets('names the address-bar path on desktop', (tester) async {
      await _withPlatform(TargetPlatform.windows, () async {
        await _pumpCard(tester, bridge: _FakePwaBridge());

        expect(find.text('Chrome atau Edge di komputer'), findsOneWidget);
        expect(find.textContaining('bilah alamat'), findsOneWidget);
      });
    });
  });

  group('InstallCard layout', () {
    testWidgets('fits a phone screen without overflowing', (tester) async {
      await _pumpCard(
        tester,
        bridge: _FakePwaBridge(initial: _installable),
        width: 360,
      );

      expect(tester.takeException(), isNull);
      final action = tester.getRect(find.text(_action));
      expect(action.left, greaterThanOrEqualTo(0));
      expect(action.right, lessThanOrEqualTo(360));
    });

    testWidgets('fits the guide on a phone screen', (tester) async {
      await _withPlatform(TargetPlatform.android, () async {
        await _pumpCard(tester, bridge: _FakePwaBridge(), width: 360);

        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('stays usable at a large text scale', (tester) async {
      await _pumpCard(
        tester,
        bridge: _FakePwaBridge(initial: _installable),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
      expect(find.text(_action), findsOneWidget);
    });

    testWidgets('exposes the action to assistive technology', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCard(tester, bridge: _FakePwaBridge(initial: _installable));

      expect(find.bySemanticsLabel(RegExp('Pasang aplikasi')), findsWidgets);
      handle.dispose();
    });
  });
}
