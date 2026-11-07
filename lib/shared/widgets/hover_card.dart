import 'package:flutter/material.dart';

import '../../core/theme/bitaqwa_palette.dart';

/// A card with a restrained lift-and-glow hover interaction.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(24),
    this.radius = 24,
    this.background,
    this.borderColor,
    this.elevated = true,
    this.lift = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? background;
  final Color? borderColor;
  final bool elevated;
  final bool lift;
  final String? semanticLabel;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDarkMode;
    final hover = _hovered && widget.onTap != null;

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: widget.onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            0,
            hover && widget.lift ? -5 : 0,
            0,
          ),
          decoration: BoxDecoration(
            color: widget.background ?? palette.surface,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: hover
                  ? palette.primary.withValues(alpha: 0.42)
                  : (widget.borderColor ?? palette.border),
            ),
            boxShadow: widget.elevated
                ? <BoxShadow>[
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: hover ? 0.34 : 0.18)
                          : palette.primaryDeep.withValues(
                              alpha: hover ? 0.11 : 0.045,
                            ),
                      blurRadius: hover ? 30 : 16,
                      offset: Offset(0, hover ? 16 : 8),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.radius),
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
