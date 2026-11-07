import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/bitaqwa_palette.dart';

enum AppButtonVariant { primary, secondary, ghost, inverted }

enum AppButtonSize { regular, compact }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.expand = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool expand;
  final String? semanticLabel;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDarkMode;

    late Color background;
    late Color foreground;
    Color? borderColor;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        background = _enabled
            ? (_hovered ? palette.primaryDeep : palette.primary)
            : palette.primary.withValues(alpha: 0.4);
        foreground = isDark && !_hovered
            ? const Color(0xFF042018)
            : Colors.white;
        if (_hovered && isDark) foreground = Colors.white;
        break;
      case AppButtonVariant.secondary:
        background = _hovered
            ? palette.primary.withValues(alpha: 0.09)
            : Colors.transparent;
        foreground = palette.text;
        borderColor = _hovered ? palette.primary : palette.border;
        break;
      case AppButtonVariant.ghost:
        background = _hovered
            ? palette.primary.withValues(alpha: 0.08)
            : Colors.transparent;
        foreground = palette.primary;
        break;
      case AppButtonVariant.inverted:
        background = _hovered ? Colors.white : palette.surfaceAlt;
        foreground = palette.primaryDeep;
        break;
    }

    final horizontal = widget.size == AppButtonSize.regular ? 24.0 : 17.0;
    final vertical = widget.size == AppButtonSize.regular ? 17.0 : 12.0;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[
          Icon(widget.icon, size: widget.size == AppButtonSize.regular ? 18 : 16),
          const SizedBox(width: 9),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: widget.size == AppButtonSize.regular ? 14 : 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: foreground,
          ),
        ),
        if (widget.trailingIcon != null) ...<Widget>[
          const SizedBox(width: 9),
          AnimatedSlide(
            offset: _hovered ? const Offset(0.15, 0) : Offset.zero,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Icon(
              widget.trailingIcon,
              size: widget.size == AppButtonSize.regular ? 17 : 15,
              color: foreground,
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel ?? widget.label,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: widget.expand ? double.infinity : null,
          transform: Matrix4.translationValues(
            0,
            _hovered && _enabled ? -1.5 : 0,
            0,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor, width: 1),
            boxShadow: _hovered && _enabled && widget.variant == AppButtonVariant.primary
                ? <BoxShadow>[
                    BoxShadow(
                      color: palette.primary.withValues(alpha: isDark ? 0.2 : 0.24),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal,
                  vertical: vertical,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppTextLink extends StatefulWidget {
  const AppTextLink({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Icons.arrow_forward_rounded,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData icon;
  final Color? color;

  @override
  State<AppTextLink> createState() => _AppTextLinkState();
}

class _AppTextLinkState extends State<AppTextLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = widget.color ?? palette.primary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: _hovered ? 18 : 0,
                height: 1,
                color: tone,
                margin: EdgeInsets.only(right: _hovered ? 6 : 0),
              ),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: tone,
                ),
              ),
              const SizedBox(width: 7),
              AnimatedSlide(
                offset: _hovered ? const Offset(0.25, 0) : Offset.zero,
                duration: const Duration(milliseconds: 180),
                child: Icon(widget.icon, size: 15, color: tone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.palette;
    return Tooltip(
      message: isDark ? 'Mode terang' : 'Mode gelap',
      child: InkResponse(
        onTap: () {
          ref.read(themeModeProvider.notifier).setMode(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
        },
        radius: 24,
        child: Container(
          width: compact ? 38 : 42,
          height: compact ? 38 : 42,
          decoration: BoxDecoration(
            color: palette.surfaceAlt.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: palette.border),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey<bool>(isDark),
              size: compact ? 18 : 19,
              color: palette.text,
            ),
          ),
        ),
      ),
    );
  }
}
