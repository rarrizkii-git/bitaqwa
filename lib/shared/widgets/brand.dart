import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/bitaqwa_palette.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 42,
    this.foreground = Colors.white,
    this.background,
    this.showShadow = true,
  });

  final double size;
  final Color foreground;
  final Color? background;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? palette.primaryDeep,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
        boxShadow: showShadow
            ? <BoxShadow>[
                BoxShadow(
                  color: (background ?? palette.primaryDeep)
                      .withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(size * 0.19),
      child: SvgPicture.asset(
        'assets/images/brand_mark.svg',
        colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
        semanticsLabel: 'Logo Bitaqwa',
      ),
    );
  }
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    this.markSize = 42,
    this.showTagline = true,
    this.onTap,
    this.foreground,
  });

  final double markSize;
  final bool showTagline;
  final VoidCallback? onTap;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = foreground ?? palette.text;
    return Semantics(
      button: onTap != null,
      label: 'Bitaqwa, kembali ke beranda',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BrandMark(size: markSize),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Bitaqwa',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: markSize * 0.52,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.8,
                      color: color,
                    ),
                  ),
                  if (showTagline) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      'TEMAN IBADAH',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.1,
                        color: palette.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoldRule extends StatelessWidget {
  const GoldRule({super.key, this.width = 40, this.color});
  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2,
      decoration: BoxDecoration(
        color: color ?? context.palette.gold,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.label, {super.key, this.color, this.icon = Icons.star});

  final String label;
  final Color? color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = color ?? palette.primary;
    // A Wrap keeps the eyebrow intact inside narrow cards: a Row would give the
    // label unbounded width and overflow once the available space shrinks.
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Icon(icon, size: 12, color: palette.gold),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
            color: tone,
          ),
        ),
      ],
    );
  }
}

class SoftBadge extends StatelessWidget {
  const SoftBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = color ?? palette.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: tone.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: tone),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

class SourceNote extends StatelessWidget {
  const SourceNote({super.key, required this.text, this.icon = Icons.info_outline_rounded});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 15, color: palette.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                  height: 1.55,
                ),
          ),
        ),
      ],
    );
  }
}

const kPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: <Color>[AppColors.deepEmerald, AppColors.emerald],
);
