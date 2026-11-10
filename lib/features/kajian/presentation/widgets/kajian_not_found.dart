import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/page_scaffold.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/islamic_art.dart';
import 'kajian_page_body.dart';

/// A calm, honest dead end for unknown themes, teachers and lecture IDs.
///
/// The screen offers a way back into the library instead of pretending that
/// the requested content exists.
class KajianNotFoundPage extends StatelessWidget {
  const KajianNotFoundPage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Column(
        children: <Widget>[
          PageHeader(
            eyebrow: eyebrow,
            title: title,
            description: description,
            action: const RotatingStar(size: 110, opacity: 0.28),
          ),
          KajianPageBody(
            child: Column(
              children: <Widget>[
                const OrnamentDivider(width: 220),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    AppButton(
                      label: 'Kembali ke Kajian',
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => context.go('/kajian'),
                    ),
                    AppButton(
                      label: 'Kajian tersimpan',
                      icon: Icons.bookmark_border_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.go('/kajian/tersimpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
