import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/providers/app_providers.dart';

/// Scroll-triggered entrance animation.
///
/// Runs once when the child first becomes visible. Users who ask for reduced
/// motion see the final state immediately.
class Reveal extends ConsumerStatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 0.08,
    this.duration = const Duration(milliseconds: 700),
    this.visibleThreshold = 0.08,
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;
  final double visibleThreshold;

  @override
  ConsumerState<Reveal> createState() => _RevealState();
}

class _RevealState extends ConsumerState<Reveal> {
  final GlobalKey _visibilityKey = GlobalKey();
  bool _revealed = false;
  bool _scheduled = false;
  Timer? _timer;

  void _handleVisibility(VisibilityInfo info) {
    if (_revealed || _scheduled) return;
    if (info.visibleFraction <= widget.visibleThreshold) return;
    _scheduled = true;
    final reduceMotion = ref.read(reduceMotionProvider);
    if (reduceMotion || widget.delay == Duration.zero) {
      if (mounted) setState(() => _revealed = true);
      return;
    }
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _revealed = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = ref.watch(reduceMotionProvider);
    final shown = _revealed || reduceMotion;
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _handleVisibility,
      child: AnimatedSlide(
        offset: shown ? Offset.zero : Offset(0, widget.offset),
        duration: reduceMotion ? Duration.zero : widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: shown ? 1 : 0,
          duration: reduceMotion ? Duration.zero : widget.duration,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Stagger helper: gives each item in a list a slightly later reveal.
class StaggeredReveal extends StatelessWidget {
  const StaggeredReveal({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 60),
    this.maxDelay = const Duration(milliseconds: 420),
  });

  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration maxDelay;

  @override
  Widget build(BuildContext context) {
    final delay = baseDelay * index;
    return Reveal(
      delay: delay > maxDelay ? maxDelay : delay,
      child: child,
    );
  }
}

/// Counts up to [value] the first time it scrolls into view.
class CountUp extends ConsumerStatefulWidget {
  const CountUp({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1500),
  });

  final int value;
  final TextStyle? style;
  final String suffix;
  final Duration duration;

  @override
  ConsumerState<CountUp> createState() => _CountUpState();
}

class _CountUpState extends ConsumerState<CountUp>
    with SingleTickerProviderStateMixin {
  final GlobalKey _visibilityKey = GlobalKey();
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (_started) return;
    _started = true;
    if (ref.read(reduceMotionProvider)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1) _start();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final current = (widget.value * _animation.value).round();
          return Text(
            '$current${widget.suffix}',
            style: widget.style,
          );
        },
      ),
    );
  }
}
