import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/bitaqwa_palette.dart';

/// Formats Rupiah fields with Indonesian thousands separators while keeping
/// the cursor at the end of the amount.
class RupiahInputFormatter extends TextInputFormatter {
  RupiahInputFormatter();

  static final NumberFormat _format = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == newValue.text) return newValue;
    // A pasted negative amount must be rejected, not silently turned positive.
    if (newValue.text.contains('-')) return oldValue;

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (normalized.length > 15) return oldValue;

    final parsed = int.tryParse(normalized);
    if (parsed == null) return oldValue;

    final formatted = _format.format(parsed);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Accepts a decimal gram amount, normalises a dot to a comma, and limits the
/// fraction to three digits (milligram precision).
class GoldWeightInputFormatter extends TextInputFormatter {
  const GoldWeightInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == newValue.text) return newValue;
    // Do not let a negative weight become a positive one after normalisation.
    if (newValue.text.contains('-')) return oldValue;

    final normalized = newValue.text.replaceAll('.', ',');
    final parts = normalized.split(',');
    if (parts.length > 2) return oldValue;

    final whole = parts.first.replaceAll(RegExp(r'[^0-9]'), '');
    final fraction = parts.length == 2
        ? parts[1].replaceAll(RegExp(r'[^0-9]'), '')
        : null;

    if (whole.length > 7) return oldValue;
    if (fraction != null && fraction.length > 3) return oldValue;

    final text = fraction == null ? whole : '$whole,$fraction';
    if (text.isEmpty) return const TextEditingValue();
    if (text == ',') return const TextEditingValue(text: '0,');

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class ZakatAmountField extends StatelessWidget {
  const ZakatAmountField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText = '0',
    this.helperText,
    this.errorText,
    this.onChanged,
    this.required = false,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool required;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 7),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: textInputAction,
            inputFormatters: <TextInputFormatter>[RupiahInputFormatter()],
            autocorrect: false,
            enableSuggestions: false,
            onChanged: onChanged,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontSize: 15, color: palette.text),
            decoration: InputDecoration(
              hintText: hintText,
              prefixText: 'Rp ',
              prefixStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: palette.muted,
              ),
              helperText: helperText,
              helperMaxLines: 2,
              errorText: errorText,
              errorMaxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}

class ZakatWeightField extends StatelessWidget {
  const ZakatWeightField({
    super.key,
    required this.controller,
    this.errorText,
    this.helperText = 'Gunakan koma untuk desimal, misalnya 12,5.',
    this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final String? helperText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _FieldLabel(label: 'Berat emas', required: false),
        const SizedBox(height: 7),
        Semantics(
          label: 'Berat emas dalam gram',
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            inputFormatters: const <TextInputFormatter>[
              GoldWeightInputFormatter(),
            ],
            autocorrect: false,
            enableSuggestions: false,
            onChanged: onChanged,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontSize: 15, color: palette.text),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'gram',
              helperText: helperText,
              helperMaxLines: 2,
              errorText: errorText,
              errorMaxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        children: <InlineSpan>[
          if (required)
            TextSpan(
              text: '  ·  wajib',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.palette.text,
      ),
    );
  }
}

/// A quiet form-section heading with an editorial ledger number.
class ZakatSectionHeader extends StatelessWidget {
  const ZakatSectionHeader({
    super.key,
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 30,
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: palette.gold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: palette.text),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.muted,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum ZakatNoticeTone { info, caution }

class ZakatNotice extends StatelessWidget {
  const ZakatNotice({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.tone = ZakatNoticeTone.info,
    this.trailing,
  });

  final String title;
  final String message;
  final IconData icon;
  final ZakatNoticeTone tone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = tone == ZakatNoticeTone.caution
        ? palette.gold
        : palette.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: context.isDarkMode ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: context.isDarkMode ? 0.28 : 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 17, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.55,
                    color: palette.muted,
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  const SizedBox(height: 10),
                  trailing!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ZakatChoiceRow extends StatelessWidget {
  const ZakatChoiceRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: selected
            ? palette.primarySoft.withValues(
                alpha: context.isDarkMode ? 0.55 : 0.72,
              )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: _SelectionDot(selected: selected),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? palette.primary : palette.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.45,
                          color: palette.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZakatHaulOption extends StatelessWidget {
  const ZakatHaulOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.hasError = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final error = Theme.of(context).colorScheme.error;
    final borderColor = hasError && !selected
        ? error.withValues(alpha: 0.55)
        : selected
        ? palette.primary.withValues(alpha: 0.3)
        : palette.border;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: selected
                  ? palette.primarySoft.withValues(
                      alpha: context.isDarkMode ? 0.55 : 0.72,
                    )
                  : palette.surfaceAlt.withValues(
                      alpha: context.isDarkMode ? 0.5 : 0.45,
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _SelectionDot(selected: selected),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? palette.primary : palette.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? palette.primary : Colors.transparent,
        border: Border.all(
          color: selected ? palette.primary : palette.border,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(
              Icons.check,
              size: 10,
              color: context.isDarkMode
                  ? const Color(0xFF042018)
                  : Colors.white,
            )
          : null,
    );
  }
}

class ZakatSegment<T> {
  const ZakatSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class ZakatSegmentedToggle<T> extends StatelessWidget {
  const ZakatSegmentedToggle({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<ZakatSegment<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(
          alpha: context.isDarkMode ? 0.55 : 0.65,
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: <Widget>[
          for (final option in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: option.value == value,
                label: option.label,
                onTap: () => onChanged(option.value),
                excludeSemantics: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onChanged(option.value),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: option.value == value
                            ? palette.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: option.value == value
                              ? palette.primary.withValues(alpha: 0.22)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (option.icon != null) ...<Widget>[
                            Icon(
                              option.icon,
                              size: 14,
                              color: option.value == value
                                  ? palette.primary
                                  : palette.muted,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: option.value == value
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: option.value == value
                                    ? palette.primary
                                    : palette.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
