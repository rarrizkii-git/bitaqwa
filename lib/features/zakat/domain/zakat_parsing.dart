/// Parsing helpers shared by the calculator form and unit tests.
///
/// The UI formats amounts with Indonesian thousands separators. These helpers
/// deliberately accept both `12,5` and `12.5` for grams because mobile and
/// desktop keyboards expose different decimal keys.
abstract final class ZakatParsing {
  static final RegExp _digitsOnly = RegExp(r'^\d+$');
  static final RegExp _rupiahShape = RegExp(
    r'^(?:rp\s*)?[0-9.\s]+$',
    caseSensitive: false,
  );

  static int? parseRupiah(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || !_rupiahShape.hasMatch(trimmed)) return null;
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  static int? parseGoldWeightMilligrams(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.contains('-')) return null;

    final normalized = trimmed.replaceAll('.', ',');
    final parts = normalized.split(',');
    if (parts.length > 2) return null;

    final whole = parts.first.isEmpty ? '0' : parts.first;
    final fraction = parts.length == 2 ? parts[1] : '';
    if (!_digitsOnly.hasMatch(whole)) return null;
    if (fraction.isNotEmpty && !RegExp(r'^\d{1,3}$').hasMatch(fraction)) {
      return null;
    }

    final digits = whole + fraction.padRight(3, '0');
    return int.tryParse(digits);
  }
}
