import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/bitaqwa_palette.dart';

/// Eight-point star tessellation used as a quiet Islamic texture.
class IslamicPattern extends StatelessWidget {
  const IslamicPattern({
    super.key,
    this.color,
    this.opacity = 0.06,
    this.spacing = 64,
    this.strokeWidth = 1,
  });

  final Color? color;
  final double opacity;
  final double spacing;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final tone = (color ?? Theme.of(context).colorScheme.primary)
        .withValues(alpha: opacity);
    return RepaintBoundary(
      child: CustomPaint(
        painter: _IslamicPatternPainter(
          color: tone,
          spacing: spacing,
          strokeWidth: strokeWidth,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  const _IslamicPatternPainter({
    required this.color,
    required this.spacing,
    required this.strokeWidth,
  });

  final Color color;
  final double spacing;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final radius = spacing * 0.33;
    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final offsetX = ((y / spacing).round().isEven) ? 0 : spacing / 2;
        _drawStar(canvas, Offset(x + offsetX, y), radius, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final angle = -math.pi / 2 + i * math.pi / 8;
      final r = i.isEven ? radius : radius * 0.42;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// A pointed mihrab arch used to frame the hero illustration.
class MihrabClipper extends CustomClipper<Path> {
  const MihrabClipper({this.topInset = 0.02});

  final double topInset;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final apex = h * topInset;
    final shoulder = h * 0.27;

    return Path()
      ..moveTo(0, h)
      ..lineTo(0, shoulder)
      ..cubicTo(0, h * 0.10, w * 0.32, apex, w * 0.5, apex)
      ..cubicTo(w * 0.68, apex, w, h * 0.10, w, shoulder)
      ..lineTo(w, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant MihrabClipper oldClipper) =>
      oldClipper.topInset != topInset;
}

class RotatingStar extends ConsumerStatefulWidget {
  const RotatingStar({
    super.key,
    this.size = 120,
    this.color,
    this.opacity = 0.5,
    this.duration = const Duration(seconds: 50),
    this.strokeWidth = 1.2,
  });

  final double size;
  final Color? color;
  final double opacity;
  final Duration duration;
  final double strokeWidth;

  @override
  ConsumerState<RotatingStar> createState() => _RotatingStarState();
}

class _RotatingStarState extends ConsumerState<RotatingStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ref.read(reduceMotionProvider)) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tone = (widget.color ?? Theme.of(context).colorScheme.primary)
        .withValues(alpha: widget.opacity);
    return RepaintBoundary(
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _StarMedallionPainter(
            color: tone,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _StarMedallionPainter extends CustomPainter {
  const _StarMedallionPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 * 0.74;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final angle in <double>[0, math.pi / 4]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 1.55,
            height: radius * 1.55,
          ),
          Radius.circular(radius * 0.14),
        ),
        paint,
      );
      canvas.restore();
    }
    canvas.drawCircle(center, radius * 0.48, paint);
    canvas.drawCircle(
      center,
      radius * 0.08,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _StarMedallionPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

class CrescentMark extends StatelessWidget {
  const CrescentMark({
    super.key,
    this.size = 42,
    this.color,
    this.cutoutColor,
  });

  final double size;
  final Color? color;
  final Color? cutoutColor;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? context.palette.primary;
    return CustomPaint(
      size: Size.square(size),
      painter: _CrescentPainter(
        color: tone,
        cutoutColor: cutoutColor ?? Colors.transparent,
      ),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  const _CrescentPainter({required this.color, required this.cutoutColor});

  final Color color;
  final Color cutoutColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.38;
    final paint = Paint()..color = color;
    canvas.drawCircle(center, radius, paint);

    final cutout = Paint()..color = cutoutColor;
    canvas.drawCircle(
      Offset(center.dx + radius * 0.38, center.dy - radius * 0.1),
      radius * 0.84,
      cutout,
    );
  }

  @override
  bool shouldRepaint(covariant _CrescentPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.cutoutColor != cutoutColor;
}

/// Hand-drawn mosque skyline, used as a soft illustration rather than clipart.
class MosqueSilhouette extends StatelessWidget {
  const MosqueSilhouette({
    super.key,
    this.color,
    this.detailColor,
    this.height = 220,
  });

  final Color? color;
  final Color? detailColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _MosquePainter(
          color: color ?? scheme.primary,
          detailColor:
              detailColor ?? Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}

class _MosquePainter extends CustomPainter {
  const _MosquePainter({required this.color, required this.detailColor});

  final Color color;
  final Color detailColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color;
    final detail = Paint()..color = detailColor;
    final base = h * 0.94;

    // Ground.
    canvas.drawRect(Rect.fromLTWH(w * 0.03, base - 1.5, w * 0.94, 1.5), paint);

    // Main body.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.29, h * 0.55, w * 0.42, base - h * 0.55),
        Radius.circular(w * 0.012),
      ),
      paint,
    );

    // Main onion dome.
    final domeCenterX = w * 0.5;
    final domeBase = h * 0.57;
    final domeRadius = w * 0.17;
    final dome = Path()
      ..moveTo(domeCenterX - domeRadius, domeBase)
      ..cubicTo(
        domeCenterX - domeRadius * 1.04,
        domeBase - domeRadius * 0.9,
        domeCenterX - domeRadius * 0.5,
        domeBase - domeRadius * 1.48,
        domeCenterX,
        domeBase - domeRadius * 1.56,
      )
      ..cubicTo(
        domeCenterX + domeRadius * 0.5,
        domeBase - domeRadius * 1.48,
        domeCenterX + domeRadius * 1.04,
        domeBase - domeRadius * 0.9,
        domeCenterX + domeRadius,
        domeBase,
      )
      ..close();
    canvas.drawPath(dome, paint);

    // Finial and crescent.
    final finialTop = domeBase - domeRadius * 2.02;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(domeCenterX, finialTop + 10),
        width: 2,
        height: 22,
      ),
      paint,
    );
    canvas.drawCircle(
      Offset(domeCenterX - 3, finialTop - 1),
      5,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(domeCenterX - 1, finialTop - 2),
      4.2,
      Paint()..color = detailColor,
    );

    // Side domes.
    for (final side in <double>[0.30, 0.70]) {
      final cx = w * side;
      final r = w * 0.075;
      final domeBaseSide = h * 0.70;
      final sideDome = Path()
        ..moveTo(cx - r, domeBaseSide)
        ..quadraticBezierTo(cx - r * 0.92, domeBaseSide - r * 1.3, cx, domeBaseSide - r * 1.4)
        ..quadraticBezierTo(cx + r * 0.92, domeBaseSide - r * 1.3, cx + r, domeBaseSide)
        ..close();
      canvas.drawPath(sideDome, paint);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, domeBaseSide - r * 1.48),
          width: 1.5,
          height: r * 0.5,
        ),
        paint,
      );
    }

    // Minarets.
    for (final side in <double>[0.16, 0.84]) {
      final cx = w * side;
      final bodyWidth = w * 0.028;
      canvas.drawRect(
        Rect.fromLTWH(cx - bodyWidth / 2, h * 0.42, bodyWidth, base - h * 0.42),
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, h * 0.47),
          width: bodyWidth * 2.1,
          height: 4,
        ),
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, h * 0.55),
          width: bodyWidth * 1.5,
          height: 3,
        ),
        paint,
      );
      final cap = Path()
        ..moveTo(cx - bodyWidth * 0.8, h * 0.42)
        ..quadraticBezierTo(cx, h * 0.37, cx + bodyWidth * 0.8, h * 0.42)
        ..close();
      canvas.drawPath(cap, paint);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, h * 0.355),
          width: 1.2,
          height: h * 0.055,
        ),
        paint,
      );
    }

    // Facade arches.
    final arches = <double>[0.38, 0.50, 0.62];
    for (final side in arches) {
      final cx = w * side;
      final archWidth = w * 0.09;
      final top = h * 0.70;
      final path = Path()
        ..moveTo(cx - archWidth / 2, base)
        ..lineTo(cx - archWidth / 2, top)
        ..quadraticBezierTo(cx, h * 0.62, cx + archWidth / 2, top)
        ..lineTo(cx + archWidth / 2, base)
        ..close();
      canvas.drawPath(path, detail);
      canvas.drawRect(
        Rect.fromLTWH(cx - archWidth * 0.18, h * 0.82, archWidth * 0.36, (base - h * 0.82)),
        detail,
      );
    }

    // Small side windows.
    for (final side in <double>[0.33, 0.67]) {
      final cx = w * side;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, h * 0.78),
            width: w * 0.028,
            height: h * 0.075,
          ),
          const Radius.circular(3),
        ),
        detail,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MosquePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.detailColor != detailColor;
}

class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key, this.width = 220, this.color});

  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: width,
      child: Row(
        children: <Widget>[
          Expanded(child: Container(height: 1, color: tone.withValues(alpha: 0.25))),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: tone,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: tone.withValues(alpha: 0.25))),
        ],
      ),
    );
  }
}

/// Gentle vertical floating motion for hero ornaments and cards.
class Floating extends ConsumerStatefulWidget {
  const Floating({
    super.key,
    required this.child,
    this.offset = 9,
    this.duration = const Duration(milliseconds: 4200),
  });

  final Widget child;
  final double offset;
  final Duration duration;

  @override
  ConsumerState<Floating> createState() => _FloatingState();
}

class _FloatingState extends ConsumerState<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: -widget.offset / 2,
      end: widget.offset / 2,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = ref.read(reduceMotionProvider);
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Subtle parallax decoration for hero backgrounds.
class GlowOrb extends StatelessWidget {
  const GlowOrb({
    super.key,
    this.size = 240,
    this.color,
    this.opacity = 0.16,
  });

  final double size;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? Theme.of(context).colorScheme.primary;
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              tone.withValues(alpha: opacity),
              tone.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
