import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/bitaqwa_palette.dart';
import '../../core/utils/responsive.dart';
import '../widgets/brand.dart';
import '../widgets/islamic_art.dart';
import 'footer.dart';

/// Shared page shell: scroll tracking for the navbar, plus the site footer.
class PageScaffold extends ConsumerStatefulWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.controller,
    this.showFooter = true,
  });

  final Widget child;
  final ScrollController? controller;
  final bool showFooter;

  @override
  ConsumerState<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends ConsumerState<PageScaffold> {
  late ScrollController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _ownsController = widget.controller == null;
    _controller.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateScrollState();
    });
  }

  @override
  void didUpdateWidget(covariant PageScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleScroll);
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? ScrollController();
      _ownsController = widget.controller == null;
      _controller.addListener(_handleScroll);
      _updateScrollState();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleScroll() => _updateScrollState();

  void _updateScrollState() {
    if (!mounted || !_controller.hasClients) return;
    ref.read(navScrollProvider.notifier).update(
          _controller.offset,
          _controller.position.maxScrollExtent,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: <Widget>[
            widget.child,
            if (widget.showFooter) const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.centered = false,
    this.trailing,
    this.titleColor,
    this.maxWidth = 640,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final bool centered;
  final Widget? trailing;
  final Color? titleColor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final titleStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          fontSize: context.responsive(mobile: 32.0, tablet: 38.0, desktop: 42.0),
          color: titleColor ?? palette.text,
        );

    final copy = Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: <Widget>[
        Eyebrow(eyebrow),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            title,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: titleStyle,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              subtitle!,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.muted,
                  ),
            ),
          ),
        ],
      ],
    );

    if (trailing == null) return copy;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment:
                centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: <Widget>[
              copy,
              const SizedBox(height: 22),
              trailing!,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(child: copy),
            const SizedBox(width: 40),
            trailing!,
          ],
        );
      },
    );
  }
}

/// Editorial header used by the dedicated feature pages.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.action,
    this.meta,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget? action;
  final Widget? meta;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: IslamicPattern(
            color: palette.pattern,
            opacity: context.isDarkMode ? 0.055 : 0.045,
            spacing: 58,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                palette.surfaceAlt.withValues(alpha: 0.72),
                palette.background,
              ],
            ),
            border: Border(
              bottom: BorderSide(color: palette.border),
            ),
          ),
          padding: EdgeInsets.only(
            top: context.responsive(mobile: 42.0, tablet: 56.0, desktop: 66.0),
            bottom: context.responsive(mobile: 44.0, tablet: 58.0, desktop: 68.0),
          ),
          child: ContentWidth(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Eyebrow(eyebrow),
                      const SizedBox(height: 18),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontSize: context.responsive(
                                  mobile: 34.0,
                                  tablet: 44.0,
                                  desktop: 50.0,
                                ),
                                height: 1.08,
                                letterSpacing: -1.2,
                                color: palette.text,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: palette.muted),
                        ),
                      ),
                      if (meta != null) ...<Widget>[
                        const SizedBox(height: 24),
                        meta!,
                      ],
                    ],
                  ),
                ),
                if (action != null) ...<Widget>[
                  const SizedBox(width: 32),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: action,
                  ),
                ] else if (context.isDesktop)
                  Padding(
                    padding: const EdgeInsets.only(left: 48, bottom: 8),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: RotatingStar(
                        size: 150,
                        opacity: context.isDarkMode ? 0.35 : 0.22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
