import '../models/lecture.dart';
import '../models/ustadz.dart';

/// The curated Kajian Online catalogue.
///
/// Every entry below was checked against the original YouTube source: the
/// video ID resolves through YouTube's oEmbed endpoint, the title matches the
/// source, and the publisher is the channel that actually hosts the video.
/// `verifiedOn` records the latest review date.
///
/// This check is about *provenance*, not religious review: it says the video is
/// the one the catalogue claims it is, not that its content has been endorsed
/// by a scholar or a religious authority. The UI must never present it as the
/// latter.
///
/// Content is intentionally kept out of widgets so it can later move to a CMS
/// without rewriting the presentation layer. Entries must never be invented:
/// add a lecture only after its source has been verified.
class KajianCatalog {
  const KajianCatalog();

  static const verifiedOn = '10 November 2026';

  static const ustadzList = <Ustadz>[
    Ustadz(
      id: 'khalid-basalamah',
      name: 'Khalid Basalamah',
      honorific: 'Ustadz',
      bio:
          'Kajian beliau dibagikan melalui kanal Khalid Basalamah '
          'Official di YouTube. Bahasan yang tersedia di Bitaqwa mencakup tauhid, '
          'sirah nabawiyah, hadits, dan manhaj.',
      channelName: 'Khalid Basalamah Official',
      channelUrl: 'https://www.youtube.com/@KhalidBasalamah',
      verified: true,
    ),
    Ustadz(
      id: 'nuzul-dzikri',
      name: 'Muhammad Nuzul Dzikri',
      honorific: 'Ustadz',
      bio:
          'Kajian beliau dibagikan melalui kanal Muhammad Nuzul Dzikri. '
          'Bahasan yang tersedia di Bitaqwa berfokus pada tazkiyatun nafs dan '
          'pembinaan hati.',
      channelName: 'Muhammad Nuzul Dzikri',
      channelUrl: 'https://www.youtube.com/@MuhammadNuzulDzikri',
      verified: true,
    ),
    Ustadz(
      id: 'raehanul-bahraen',
      name: 'Raehanul Bahraen',
      honorific: 'Ustadz dr.',
      credentials: 'M.Sc, Sp.PK',
      bio:
          'Ustadz dr. Raehanul Bahraen, M.Sc, Sp.PK membawakan kajian fikih '
          'dan akhlak melalui kanal Raehanul Bahraen. Nama dan gelar beliau '
          'tercantum pada judul video sumber.',
      channelName: 'Raehanul Bahraen',
      channelUrl: 'https://www.youtube.com/@RaehanulBahraen',
      verified: true,
    ),
    Ustadz(
      id: 'ammi-nur-baits',
      name: 'Ammi Nur Baits',
      honorific: 'Ustadz',
      bio:
          'Kajian beliau dibagikan melalui kanal anb channel (ANB). Bahasan '
          'yang tersedia di Bitaqwa mencakup aqidah, akhlak, dan tazkiyah.',
      channelName: 'anb channel',
      channelUrl: 'https://www.youtube.com/@AmmiNurBaits',
      verified: true,
    ),
    Ustadz(
      id: 'abdullah-zaen',
      name: 'Abdullah Zaen',
      honorific: 'Ustadz Dr.',
      credentials: 'Lc., M.A.',
      bio:
          'Kajian beliau dibagikan melalui kanal Yufid.TV. Bahasan yang '
          'tersedia di Bitaqwa mencakup tafsir, hadits, dan sirah.',
      channelName: 'Yufid.TV - Pengajian & Ceramah Islam',
      channelUrl: 'https://www.youtube.com/@yufid',
      verified: true,
    ),
    Ustadz(
      id: 'firanda-andirja',
      name: 'Firanda Andirja',
      honorific: 'Ustadz',
      bio:
          'Kajian tafsir beliau dibagikan melalui kanal Yufid.TV. Bitaqwa '
          'menautkan langsung ke video sumber tanpa mengunggah ulang.',
      channelName: 'Yufid.TV - Pengajian & Ceramah Islam',
      channelUrl: 'https://www.youtube.com/@yufid',
      verified: true,
    ),
    Ustadz(
      id: 'shalih-asy-syilasy',
      name: 'Shalih bin Muhammad Asy Syilasy',
      honorific: 'Syaikh',
      bio:
          'Kajian beliau diterjemahkan oleh Ustadz Ammi Nur Baits dan '
          'dibagikan melalui kanal Yufid.TV, termasuk pembahasan tentang '
          'manhaj.',
      channelName: 'Yufid.TV - Pengajian & Ceramah Islam',
      channelUrl: 'https://www.youtube.com/@yufid',
      verified: true,
    ),
  ];

  static const lectureList = <Lecture>[
    // Aqidah
    Lecture(
      id: 'tauhid-jalan-keselamatan',
      title: 'Tauhid Jalan Keselamatan',
      ustadzId: 'khalid-basalamah',
      videoId: 'BkL00UHhg7o',
      category: LectureCategory.aqidah,
      durationSeconds: 2705,
      publishedAt: '2021-05-25T16:00:01-07:00',
      featured: true,
      verified: true,
    ),
    Lecture(
      id: 'memahami-enam-rukun-iman',
      title: 'Mencari Tenang: Memahami 6 Rukun Iman',
      ustadzId: 'ammi-nur-baits',
      videoId: 'JQbYzBG1Fqc',
      category: LectureCategory.aqidah,
      durationSeconds: 5210,
      publishedAt: '2026-11-07T15:08:14-08:00',
      verified: true,
    ),
    Lecture(
      id: 'surga-dan-neraka',
      title: 'Surga dan Neraka',
      ustadzId: 'ammi-nur-baits',
      videoId: 'VSOrCyjPDZg',
      category: LectureCategory.aqidah,
      durationSeconds: 5590,
      publishedAt: '2026-11-07T04:48:37-08:00',
      verified: true,
    ),

    // Fiqih
    Lecture(
      id: 'thaharah-fiqh-bersuci-1',
      title: 'Belajar Thaharah dan Fiqh Bersuci #1',
      ustadzId: 'raehanul-bahraen',
      videoId: 'xOKa3VncezU',
      category: LectureCategory.fiqih,
      durationSeconds: 4235,
      publishedAt: '2026-11-03T18:27:25-08:00',
      featured: true,
      verified: true,
    ),
    Lecture(
      id: 'thaharah-fiqh-bersuci-2',
      title: 'Belajar Thaharah dan Fiqh Bersuci #2',
      ustadzId: 'raehanul-bahraen',
      videoId: 'Qi1jjJe6kRc',
      category: LectureCategory.fiqih,
      durationSeconds: 3860,
      publishedAt: '2026-11-04T18:39:18-08:00',
      verified: true,
    ),
    Lecture(
      id: 'fikih-kematian',
      title:
          'Fikih Terkait Kematian, Mati Batang Otak, Pasien Kritis & Euthanasia',
      ustadzId: 'raehanul-bahraen',
      videoId: 'hD9j1-L2VI4',
      category: LectureCategory.fiqih,
      durationSeconds: 3410,
      publishedAt: '2026-11-01T18:05:36-08:00',
      verified: true,
    ),

    // Manhaj
    Lecture(
      id: 'istiqomah-manhaj-salaf',
      title: 'Kiat-Kiat Agar Istiqomah di Atas Manhaj Salaf',
      ustadzId: 'khalid-basalamah',
      videoId: 'p10tgcpUXHY',
      category: LectureCategory.manhaj,
      description:
          'Seseorang ketika menempuh jalan (agama) yang lurus (benar) tanpa '
          'berpaling ke kiri serta ke kanan maka seseorang tersebut telah '
          'istiqomah. Ibnu Rajab Al Hambali mengatakan istiqomah ini mencakup '
          'pelaksanaan semua bentuk ketaatan kepada Allah.',
      durationSeconds: 161,
      publishedAt: '2023-12-11T22:00:30-08:00',
      verified: true,
    ),
    Lecture(
      id: 'saling-mentahdzir',
      title: 'Saling Mentahdzir di Antara Penuntut Ilmu Adalah Penyakit',
      ustadzId: 'khalid-basalamah',
      videoId: 'ZTbCkOlC4MM',
      category: LectureCategory.manhaj,
      durationSeconds: 275,
      publishedAt: '2018-03-19T04:30:00-07:00',
      verified: true,
    ),
    Lecture(
      id: 'apa-itu-manhaj',
      title: 'Apa Itu Manhaj?',
      ustadzId: 'shalih-asy-syilasy',
      videoId: 'NoCIBQjD6Ro',
      category: LectureCategory.manhaj,
      description:
          'Manhaj adalah metode seseorang dalam beragama. Sedangkan manhaj '
          'salaf adalah manhaj yang dikenalkan oleh ulama-ulama Islam dalam '
          'mengambil ilmu agama.',
      durationSeconds: 6965,
      publishedAt: '2019-10-03T02:57:09-07:00',
      verified: true,
    ),

    // Tafsir
    Lecture(
      id: 'tafsir-al-fatihah',
      title: 'Tafsir al-Fatihah: Ringkas dan Aplikatif',
      ustadzId: 'abdullah-zaen',
      videoId: 'X1yZgdYXOdU',
      category: LectureCategory.tafsir,
      durationSeconds: 5374,
      publishedAt: '2023-06-10T06:04:52-07:00',
      featured: true,
      verified: true,
    ),
    Lecture(
      id: 'tafsir-surat-al-fajr',
      title: 'Tafsir Surat Al-Fajr',
      ustadzId: 'firanda-andirja',
      videoId: 'AB7RTnLQJ7M',
      category: LectureCategory.tafsir,
      durationSeconds: 3844,
      publishedAt: '2015-03-07T18:07:33-08:00',
      verified: true,
    ),
    Lecture(
      id: 'tafsir-surat-yasin',
      title: 'Faidah dan Tafsir Global Surat Yasin',
      ustadzId: 'abdullah-zaen',
      videoId: 'qKpC393kPR0',
      category: LectureCategory.tafsir,
      description:
          'Anda tahu Surah Yasin, sering membacanya, sudahkah anda mengetahui '
          'makna dan pelajaran yang terkandung di dalamnya?',
      durationSeconds: 5583,
      publishedAt: '2016-02-22T15:21:12-08:00',
      verified: true,
    ),

    // Hadits
    Lecture(
      id: 'hadits-doa-takut-penguasa',
      title: 'Doa Ketika Takut pada Penguasa (Hadits 708)',
      ustadzId: 'abdullah-zaen',
      videoId: 'Sgvt8YiiiJ8',
      category: LectureCategory.hadits,
      durationSeconds: 631,
      publishedAt: '2026-11-08T09:00:29-08:00',
      verified: true,
    ),
    Lecture(
      id: 'hadits-mengganti-nama-ash-sharm',
      title: 'Mengganti Nama Ash-Sharm (Hadits 822)',
      ustadzId: 'abdullah-zaen',
      videoId: 'kRBj0ANXu1k',
      category: LectureCategory.hadits,
      durationSeconds: 505,
      publishedAt: '2026-11-08T21:07:59-08:00',
      verified: true,
    ),
    Lecture(
      id: 'hadits-qudsi-umat-terus-bertanya',
      title:
          'Shahih Hadits Qudsi: \u201cSungguh umatmu akan terus bertanya\u201d',
      ustadzId: 'khalid-basalamah',
      videoId: 'LcTwGuZiRlQ',
      category: LectureCategory.hadits,
      durationSeconds: 3143,
      publishedAt: '2026-11-06T21:00:06-08:00',
      verified: true,
    ),

    // Akhlak dan Adab
    Lecture(
      id: 'akhlak-baik-bisa-dipelajari',
      title: 'Akhlak Baik Bisa Dipelajari',
      ustadzId: 'ammi-nur-baits',
      videoId: 'KyOOoE9cUYw',
      category: LectureCategory.akhlak,
      durationSeconds: 5109,
      publishedAt: '2026-11-07T18:43:21-08:00',
      verified: true,
    ),
    Lecture(
      id: 'pujian-tak-sesuai-kenyataan',
      title: 'Saat Pujian Tak Sesuai Kenyataan Diri',
      ustadzId: 'nuzul-dzikri',
      videoId: 'yDT_MVmdTUg',
      category: LectureCategory.akhlak,
      description:
          'Video pendek dari Kajian Riyaadhus Shaalihiin No. 2238 '
          '\u201cTakut Menjadi Munafik\u201d.',
      durationSeconds: 220,
      publishedAt: '2026-11-09T00:54:36-08:00',
      verified: true,
    ),
    Lecture(
      id: 'benteng-kesetiaan-rumah-tangga',
      title:
          'Benteng Kesetiaan di Dalam Rumah Tangga Bukan Cinta, tetapi Rasa Takut kepada Allah',
      ustadzId: 'raehanul-bahraen',
      videoId: '5s40hKY0RdA',
      category: LectureCategory.akhlak,
      durationSeconds: 33,
      publishedAt: '2026-11-09T02:37:27-08:00',
      verified: true,
    ),

    // Sirah Nabawiyah
    Lecture(
      id: 'sirah-pengantar',
      title: 'Sirah Nabawiyah #1: Pengantar Sirah Nabawiyah',
      ustadzId: 'khalid-basalamah',
      videoId: 'BWgwRJjm3sc',
      category: LectureCategory.sirah,
      durationSeconds: 7804,
      publishedAt: '2016-09-21T15:27:37-07:00',
      featured: true,
      verified: true,
    ),
    Lecture(
      id: 'sirah-kelahiran-nabi',
      title:
          'Sirah Nabawiyah #4: Kelahiran Nabi Muhammad \u0635\u0644\u0649 \u0627\u0644\u0644\u0647 \u0639\u0644\u064a\u0647 \u0648\u0633\u0644\u0645',
      ustadzId: 'khalid-basalamah',
      videoId: 'F31ZyPcSAXQ',
      category: LectureCategory.sirah,
      durationSeconds: 6153,
      publishedAt: '2017-06-17T01:28:32-07:00',
      verified: true,
    ),
    Lecture(
      id: 'sirah-perang-badar-1',
      title: 'Sirah Nabawiyah #8: Perang Badar (Part 1)',
      ustadzId: 'khalid-basalamah',
      videoId: 'SAEvHVHzbyg',
      category: LectureCategory.sirah,
      durationSeconds: 7168,
      publishedAt: '2017-10-25T23:28:14-07:00',
      verified: true,
    ),

    // Tazkiyatun Nafs
    Lecture(
      id: 'kunci-bersihnya-hati',
      title: 'Kunci Bersihnya Hati',
      ustadzId: 'nuzul-dzikri',
      videoId: 'Xd0_KAC0JiU',
      category: LectureCategory.tazkiyah,
      description:
          'Kajian Wanita Kitab Al-Wabilush Shayyib. Pasal: Keutamaan '
          'shadaqah. Halaman 95.',
      durationSeconds: 2726,
      publishedAt: '2025-04-20T21:12:44-07:00',
      verified: true,
    ),
    Lecture(
      id: 'menjaga-hati-dari-pujian',
      title: 'Cara Menjaga Hati agar Tidak Suka Pujian & Popularitas',
      ustadzId: 'nuzul-dzikri',
      videoId: '7w-Ruc5oupY',
      category: LectureCategory.tazkiyah,
      description:
          'Video pendek dari Kajian Riyaadhus Shaalihiin No. 2253 '
          '\u201cSetiap Detik Adalah Ujian\u201d.',
      durationSeconds: 231,
      publishedAt: '2026-11-05T01:04:07-08:00',
      verified: true,
    ),
    Lecture(
      id: 'tak-ada-kata-terlambat',
      title: 'Tak Ada Kata Terlambat untuk Belajar dan Beramal',
      ustadzId: 'ammi-nur-baits',
      videoId: 'dDxB71Nl-bY',
      category: LectureCategory.tazkiyah,
      durationSeconds: 4841,
      publishedAt: '2026-11-06T20:20:47-08:00',
      verified: true,
    ),
  ];

  List<Ustadz> get allUstadz => ustadzList;

  List<Lecture> get allLectures => lectureList;

  List<Lecture> get featuredLectures =>
      lectureList.where((lecture) => lecture.featured).toList(growable: false);

  /// Newest first. Lectures without a source publication date come last.
  List<Lecture> get latestLectures {
    final lectures = List<Lecture>.of(lectureList);
    lectures.sort(_latestFirst);
    return lectures;
  }

  Lecture? byId(String? id) {
    if (id == null) return null;
    for (final lecture in lectureList) {
      if (lecture.id == id) return lecture;
    }
    return null;
  }

  Ustadz? ustadzById(String? id) {
    if (id == null) return null;
    for (final ustadz in ustadzList) {
      if (ustadz.id == id) return ustadz;
    }
    return null;
  }

  Ustadz? ustadzOf(Lecture lecture) => ustadzById(lecture.ustadzId);

  int countForCategory(LectureCategory category) => lectureList
      .where((lecture) => lecture.category == category)
      .length;

  int countForUstadz(String ustadzId) =>
      lectureList.where((lecture) => lecture.ustadzId == ustadzId).length;

  List<Lecture> byCategory(LectureCategory category) {
    final lectures = lectureList
        .where((lecture) => lecture.category == category)
        .toList(growable: false);
    return List<Lecture>.of(lectures)..sort(_latestFirst);
  }

  List<Lecture> byUstadz(String ustadzId) {
    final lectures = lectureList
        .where((lecture) => lecture.ustadzId == ustadzId)
        .toList(growable: false);
    return List<Lecture>.of(lectures)..sort(_latestFirst);
  }

  /// Searches title, Ustadz name, category and credentials.
  ///
  /// Multiple words are treated as an AND query so that "tafsir yasin" narrows
  /// the result instead of widening it.
  List<Lecture> search(
    String query, {
    LectureCategory? category,
    String? ustadzId,
  }) {
    final tokens = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);

    final results = lectureList.where((lecture) {
      if (category != null && lecture.category != category) return false;
      if (ustadzId != null && lecture.ustadzId != ustadzId) return false;
      if (tokens.isEmpty) return true;

      final ustadz = ustadzById(lecture.ustadzId);
      final haystack = <String>[
        lecture.title,
        lecture.category.label,
        lecture.category.arabicLabel,
        ustadz?.name ?? '',
        ustadz?.honorific ?? '',
        ustadz?.credentials ?? '',
      ].join(' ').toLowerCase();

      return tokens.every(haystack.contains);
    }).toList();

    results.sort(_latestFirst);
    return results;
  }

  /// Related lectures: same theme first, then other lectures by the same
  /// Ustadz, then the most recent remaining lectures.
  List<Lecture> related(Lecture lecture, {int limit = 3}) {
    final related = <Lecture>[];
    final seen = <String>{lecture.id};

    void addAll(Iterable<Lecture> candidates) {
      for (final candidate in candidates) {
        if (related.length >= limit) return;
        if (seen.add(candidate.id)) related.add(candidate);
      }
    }

    addAll(byCategory(lecture.category));
    addAll(byUstadz(lecture.ustadzId));
    addAll(latestLectures);
    return related;
  }

  static int _latestFirst(Lecture a, Lecture b) {
    final aDate = a.publishedDate;
    final bDate = b.publishedDate;
    if (aDate == null && bDate == null) return a.title.compareTo(b.title);
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  }
}
