import 'package:intl/intl.dart';

/// Lightweight formatters. `id_ID` date symbols are initialised in `main.dart`.
String formatClock(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Formats a calendar date in the viewer's local time zone.
///
/// Source timestamps (for example YouTube's `publishedAt`) arrive as UTC after
/// parsing. Formatting them without conversion would show the UTC calendar day,
/// which can be a day off from what the viewer sees on the source site.
String formatDateLong(DateTime date) {
  final formatted = DateFormat(
    'EEEE, d MMMM yyyy',
    'id_ID',
  ).format(date.toLocal());
  return _capitalize(formatted);
}

String formatDateShort(DateTime date) {
  final formatted = DateFormat('d MMM yyyy', 'id_ID').format(date.toLocal());
  return formatted;
}

String formatMonthYear(DateTime date) =>
    DateFormat('MMMM yyyy', 'id_ID').format(date.toLocal());

String relativeDayLabel(DateTime date, DateTime today) {
  final a = DateTime(date.year, date.month, date.day);
  final b = DateTime(today.year, today.month, today.day);
  final difference = a.difference(b).inDays;
  if (difference == 0) return 'Hari ini';
  if (difference == 1) return 'Besok';
  if (difference == -1) return 'Kemarin';
  return formatDateShort(date);
}

String formatCountdown(Duration duration) {
  final total = duration.isNegative ? Duration.zero : duration;
  final hours = total.inHours;
  final minutes = total.inMinutes.remainder(60);
  final seconds = total.inSeconds.remainder(60);
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String formatDurationMinutes(Duration duration) {
  final minutes = duration.inMinutes;
  if (minutes < 60) return '$minutes menit';
  final hours = duration.inHours;
  final rest = minutes.remainder(60);
  return rest == 0 ? '$hours jam' : '$hours jam $rest menit';
}

/// Clock-style duration for video cards: `12:04` or `1:08:32`.
String formatVideoDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds < 0 ? 0 : totalSeconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  final paddedSeconds = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$paddedSeconds';
  }
  return '$minutes:$paddedSeconds';
}

String formatRupiah(int amount) {
  final formatted = NumberFormat('#,##0', 'id_ID').format(amount);
  return 'Rp$formatted';
}

/// Formats a milligram weight as grams without trailing zeroes.
String formatGoldGrams(int milligrams) {
  final grams = NumberFormat('#,##0.###', 'id_ID').format(milligrams / 1000);
  return '$grams g';
}

String formatBearing(double bearing) => '${bearing.round()}\u00b0';

String formatDistance(double km) {
  if (km >= 1000) {
    final formatted = NumberFormat('#,##0', 'id_ID').format(km.round());
    return '$formatted km';
  }
  return '${km.round()} km';
}

String greetingForHour(int hour) {
  if (hour < 11) return 'Selamat pagi';
  if (hour < 15) return 'Selamat siang';
  if (hour < 18) return 'Selamat sore';
  return 'Selamat malam';
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
