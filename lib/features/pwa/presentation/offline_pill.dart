import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/providers/connectivity_providers.dart';
import '../../../core/theme/bitaqwa_palette.dart';

/// Compact connectivity notice.
///
/// Mounted as an overlay in the site shell, so it never takes layout space.
/// It waits [showDelay] before appearing, which keeps a momentary drop from
/// flashing the notice, and disappears as soon as the browser reconnects.
class OfflinePill extends ConsumerStatefulWidget {
  const OfflinePill({super.key});

  /// Grace period before the notice appears.
  static const Duration showDelay = Duration(milliseconds: 700);

  /// Fade and slide length. Collapses to zero under reduced motion.
  static const Duration transition = Duration(milliseconds: 200);

  @override
  ConsumerState<OfflinePill> createState() => _OfflinePillState();
}

class _OfflinePillState extends ConsumerState<OfflinePill> {
  Timer? _pending;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (!ref.read(connectivityProvider)) _schedule();
    ref.listenManual<bool>(connectivityProvider, (previous, next) {
      if (next) {
        _cancel();
        if (_visible) setState(() => _visible = false);
      } else {
        _schedule();
      }
    });
  }

  void _schedule() {
    _pending?.cancel();
    _pending = Timer(OfflinePill.showDelay, () {
      // The connection can return while the delay is still running; the timer
      // is cancelled on that event, and this check covers the same frame.
      if (!mounted || ref.read(connectivityProvider)) return;
      setState(() => _visible = true);
    });
  }

  void _cancel() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        ref.watch(reduceMotionProvider) ||
        MediaQuery.disableAnimationsOf(context);

    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : OfflinePill.transition,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.4),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _visible
            ? const _OfflineChip(key: ValueKey<String>('offline-pill'))
            : const SizedBox.shrink(
                key: ValueKey<String>('offline-pill-hidden'),
              ),
      ),
    );
  }
}

class _OfflineChip extends StatelessWidget {
  const _OfflineChip({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: MediaQuery.withClampedTextScaling(
          // Compact chrome: stays legible without letting a very large scale
          // push the pill wider than a phone.
          maxScaleFactor: 1.3,
          child: Semantics(
            container: true,
            liveRegion: true,
            label: 'Koneksi internet terputus',
            child: ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: palette.gold.withValues(alpha: isDark ? 0.42 : 0.38),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (isDark ? Colors.black : palette.primaryDeep)
                          .withValues(alpha: isDark ? 0.35 : 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 14,
                      color: palette.goldInk,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Koneksi terputus',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        height: 1.2,
                        color: palette.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
