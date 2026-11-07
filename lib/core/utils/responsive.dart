import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';

enum ScreenSize { mobile, tablet, desktop, wide }

/// Shared breakpoints. Layouts are designed mobile-first, then genuinely
/// re-composed for tablet and desktop rather than simply scaled.
abstract final class Breakpoints {
  static const double mobile = 700;
  static const double tablet = 1024;
  static const double wide = 1440;

  static ScreenSize of(double width) {
    if (width < mobile) return ScreenSize.mobile;
    if (width < tablet) return ScreenSize.tablet;
    if (width < wide) return ScreenSize.desktop;
    return ScreenSize.wide;
  }
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  ScreenSize get screen => Breakpoints.of(screenWidth);

  bool get isMobile => screen == ScreenSize.mobile;
  bool get isTablet => screen == ScreenSize.tablet;
  bool get isDesktop => screen == ScreenSize.desktop || screen == ScreenSize.wide;

  bool get isCompactLayout => screenWidth < Breakpoints.tablet;

  /// Adaptive horizontal gutter for full-width sections.
  double get pageGutter {
    if (screenWidth < 480) return 20;
    if (screenWidth < Breakpoints.mobile) return 24;
    if (screenWidth < Breakpoints.tablet) return 40;
    if (screenWidth < Breakpoints.wide) return 56;
    return 72;
  }

  /// Responsive value picker.
  T responsive<T>({required T mobile, T? tablet, T? desktop, T? wide}) {
    return switch (screen) {
      ScreenSize.mobile => mobile,
      ScreenSize.tablet => tablet ?? mobile,
      ScreenSize.desktop => desktop ?? tablet ?? mobile,
      ScreenSize.wide => wide ?? desktop ?? tablet ?? mobile,
    };
  }

  EdgeInsets get sectionPadding => EdgeInsets.symmetric(
        horizontal: pageGutter,
        vertical: isMobile ? 56 : 88,
      );
}

/// Constrains content to the site's editorial column.
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppConstants.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final gutter = context.pageGutter;
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(horizontal: gutter),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
