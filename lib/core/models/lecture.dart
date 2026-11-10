import 'package:flutter/foundation.dart';

/// Themes used to organise the curated Kajian Online library.
///
/// The category list is data, not UI. Adding a theme here (and adding its
/// label, Arabic name and description) makes it available throughout the
/// catalogue without any layout changes.
enum LectureCategory {
  aqidah(
    slug: 'aqidah',
    label: 'Aqidah',
    arabicLabel: 'العقيدة',
    description:
        'Pokok keimanan: tauhid, rukun iman, dan keyakinan yang menjadi '
        'landasan seluruh ibadah.',
  ),
  fiqih(
    slug: 'fiqih',
    label: 'Fiqih',
    arabicLabel: 'الفقه',
    description:
        'Tuntunan ibadah dan muamalah sehari-hari, dari bersuci hingga '
        'hukum praktis yang dibutuhkan muslim.',
  ),
  manhaj(
    slug: 'manhaj',
    label: 'Manhaj',
    arabicLabel: 'المنهج',
    description:
        'Pembahasan metodologi beragama: bagaimana ilmu agama dipelajari, '
        'dipahami, dan diamalkan.',
  ),
  tafsir(
    slug: 'tafsir',
    label: 'Tafsir',
    arabicLabel: 'التفسير',
    description:
        'Penjelasan makna dan pelajaran dari ayat-ayat Al-Qur\u2019an agar '
        'pembacaan terasa lebih terarah.',
  ),
  hadits(
    slug: 'hadits',
    label: 'Hadits',
    arabicLabel: 'الحديث',
    description:
        'Pembacaan dan penjelasan hadis Nabi \u0635\u0644\u0649 \u0627\u0644\u0644\u0647 '
        '\u0639\u0644\u064a\u0647 \u0648\u0633\u0644\u0645 beserta adab dan faidahnya.',
  ),
  akhlak(
    slug: 'akhlak',
    label: 'Akhlak dan Adab',
    arabicLabel: 'الأخلاق والآداب',
    description:
        'Pembinaan budi pekerti, adab, dan hubungan baik dengan Allah serta '
        'sesama manusia.',
  ),
  sirah(
    slug: 'sirah',
    label: 'Sirah Nabawiyah',
    arabicLabel: 'السيرة النبوية',
    description:
        'Perjalanan hidup Nabi Muhammad \u0635\u0644\u0649 \u0627\u0644\u0644\u0647 \u0639\u0644\u064a\u0647 '
        '\u0648\u0633\u0644\u0645 dan pelajaran dari setiap fase dakwahnya.',
  ),
  tazkiyah(
    slug: 'tazkiyah',
    label: 'Tazkiyatun Nafs',
    arabicLabel: 'تزكية النفس',
    description:
        'Penyucian jiwa, pengobatan hati, dan upaya menjaga istiqamah dalam '
        'ibadah sehari-hari.',
  );

  const LectureCategory({
    required this.slug,
    required this.label,
    required this.arabicLabel,
    required this.description,
  });

  final String slug;
  final String label;
  final String arabicLabel;
  final String description;

  static LectureCategory? fromSlug(String? slug) {
    if (slug == null) return null;
    for (final category in LectureCategory.values) {
      if (category.slug == slug) return category;
    }
    return null;
  }
}

/// A single curated lecture.
///
/// Lecture metadata is deliberately kept separate from widgets. The YouTube
/// URL is derived from [videoId] so the catalogue can never drift from the
/// playback source, and [publishedAt] stays an ISO-8601 string so the whole
/// catalogue remains `const`.
@immutable
class Lecture {
  const Lecture({
    required this.id,
    required this.title,
    required this.ustadzId,
    required this.videoId,
    required this.category,
    required this.verified,
    this.description,
    this.durationSeconds,
    this.publishedAt,
    this.featured = false,
    this.thumbnailOverride,
  });

  final String id;
  final String title;
  final String ustadzId;
  final String videoId;
  final LectureCategory category;

  /// A short excerpt from the source video description. Kept optional because
  /// several source videos do not publish a meaningful description.
  final String? description;

  /// Duration reported by the YouTube watch page, in seconds.
  final int? durationSeconds;

  /// Publication timestamp in ISO-8601, exactly as reported by YouTube.
  final String? publishedAt;

  /// Curated by the Bitaqwa editors; not an algorithmic recommendation.
  final bool featured;

  /// True only after the video ID, title, channel and source URL have been
  /// checked against the original YouTube source.
  final bool verified;

  /// Optional explicit thumbnail. When absent, the YouTube thumbnail for
  /// [videoId] is used.
  final String? thumbnailOverride;

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  String get thumbnailUrl =>
      thumbnailOverride ?? 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';

  /// Higher-resolution thumbnail, with the standard size as a fallback in the
  /// UI when the source does not provide a max-resolution image.
  String get highResolutionThumbnailUrl =>
      thumbnailOverride ?? 'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg';

  DateTime? get publishedDate =>
      publishedAt == null ? null : DateTime.tryParse(publishedAt!);

  bool get hasDescription =>
      description != null && description!.trim().isNotEmpty;
}
