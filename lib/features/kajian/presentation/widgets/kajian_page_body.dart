import 'package:flutter/material.dart';

import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../core/utils/responsive.dart';

/// The content band shared by the Kajian Online screens.
///
/// Keeping the vertical rhythm in one place means the homepage, category,
/// directory and saved screens all breathe the same way without duplicating
/// padding values.
class KajianPageBody extends StatelessWidget {
  const KajianPageBody({
    super.key,
    required this.child,
    this.top,
    this.bottom,
  });

  final Widget child;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.palette.background,
      padding: EdgeInsets.only(
        top: top ?? (context.isMobile ? 32 : 44),
        bottom: bottom ?? (context.isMobile ? 56 : 84),
      ),
      // `ContentWidth` already applies the page gutter. Adding it here as well
      // would inset the body further than the header above it, which showed up
      // as a visible misalignment below 1200px.
      child: ContentWidth(child: child),
    );
  }
}
