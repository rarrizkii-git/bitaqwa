import 'package:flutter/material.dart';

import '../../../../core/theme/bitaqwa_palette.dart';
import '../../../../shared/widgets/app_button.dart';

class KajianEmptyState extends StatelessWidget {
  const KajianEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.note,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 46),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: palette.primarySoft.withValues(
                alpha: context.isDarkMode ? 0.5 : 1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 27, color: palette.primary),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.muted,
                    height: 1.6,
                  ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: 20),
            AppButton(
              label: actionLabel!,
              icon: Icons.arrow_back_rounded,
              size: AppButtonSize.compact,
              variant: AppButtonVariant.secondary,
              onPressed: onAction,
            ),
          ],
          if (note != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              note!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.muted,
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
