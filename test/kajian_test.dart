import 'package:bitaqwa/core/data/kajian_catalog.dart';
import 'package:bitaqwa/core/models/lecture.dart';
import 'package:bitaqwa/core/providers/app_providers.dart';
import 'package:bitaqwa/core/services/preferences_service.dart';
import 'package:bitaqwa/features/kajian/domain/youtube_video.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _catalog = KajianCatalog();

void main() {
  group('Kajian catalogue integrity', () {
    test('lecture ids are unique and non-empty', () {
      final ids = _catalog.allLectures.map((lecture) => lecture.id).toList();
      expect(ids, isNotEmpty);
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(id.trim(), isNotEmpty);
      }
    });

    test('YouTube video ids are unique and well formed', () {
      final videoIds = _catalog.allLectures
          .map((lecture) => lecture.videoId)
          .toList();
      expect(videoIds.toSet().length, videoIds.length);
      for (final videoId in videoIds) {
        expect(
          YoutubeVideo.isValidId(videoId),
          isTrue,
          reason: '$videoId must be an 11-character YouTube id',
        );
      }
    });

    test('every lecture references an existing Ustadz', () {
      for (final lecture in _catalog.allLectures) {
        expect(
          _catalog.ustadzById(lecture.ustadzId),
          isNotNull,
          reason: '${lecture.id} points at a missing Ustadz',
        );
      }
    });

    test('Ustadz ids are unique and channel links are YouTube links', () {
      final ids = _catalog.allUstadz.map((ustadz) => ustadz.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final ustadz in _catalog.allUstadz) {
        expect(ustadz.name.trim(), isNotEmpty);
        expect(ustadz.bio.trim(), isNotEmpty);
        expect(ustadz.channelUrl, startsWith('https://www.youtube.com/'));
      }
    });

    test('all required themes exist', () {
      const required = <String>{
        'aqidah',
        'fiqih',
        'manhaj',
        'tafsir',
        'hadits',
        'akhlak',
        'sirah',
        'tazkiyah',
      };
      final present = LectureCategory.values.map((item) => item.slug).toSet();
      expect(present, containsAll(required));
      for (final category in LectureCategory.values) {
        expect(LectureCategory.fromSlug(category.slug), category);
      }
      expect(LectureCategory.fromSlug('tidak-ada'), isNull);
    });

    test('lecture metadata is complete and parseable', () {
      for (final lecture in _catalog.allLectures) {
        expect(lecture.title.trim(), isNotEmpty);
        expect(lecture.verified, isTrue, reason: lecture.id);
        expect(lecture.youtubeUrl, contains(lecture.videoId));
        expect(lecture.publishedDate, isNotNull, reason: lecture.id);
        expect(lecture.durationSeconds, isNotNull, reason: lecture.id);
        expect(lecture.durationSeconds, greaterThan(0), reason: lecture.id);
        if (lecture.description != null) {
          expect(lecture.description!.trim(), isNotEmpty);
        }
      }
    });

    test('featured lectures are a small curated subset', () {
      final featured = _catalog.featuredLectures;
      expect(featured, isNotEmpty);
      expect(featured.length, lessThanOrEqualTo(4));
      expect(featured.length, lessThan(_catalog.allLectures.length));
    });

    test('lookups return the expected entries', () {
      expect(_catalog.byId('tauhid-jalan-keselamatan'), isNotNull);
      expect(_catalog.byId('tidak-ada'), isNull);
      expect(_catalog.byId(null), isNull);
      expect(_catalog.ustadzById('khalid-basalamah'), isNotNull);
      expect(_catalog.ustadzById('tidak-ada'), isNull);
      expect(_catalog.ustadzById(null), isNull);
    });
  });

  group('Kajian search', () {
    test('finds a lecture by title', () {
      final results = _catalog.search('Tauhid Jalan Keselamatan');
      expect(
        results.map((lecture) => lecture.id),
        contains('tauhid-jalan-keselamatan'),
      );
    });

    test('finds lectures by Ustadz name', () {
      final ustadz = _catalog.allUstadz.first;
      final results = _catalog.search(ustadz.name);
      expect(results, isNotEmpty);
      expect(results.every((lecture) => lecture.ustadzId == ustadz.id), isTrue);
    });

    test('search is case-insensitive', () {
      final lower = _catalog.search('tauhid');
      final upper = _catalog.search('TAUHID');
      final mixed = _catalog.search('TaUhId');
      expect(lower.map((lecture) => lecture.id), upper.map((l) => l.id));
      expect(lower.map((lecture) => lecture.id), mixed.map((l) => l.id));
    });

    test('empty query returns the whole catalogue', () {
      expect(_catalog.search(''), hasLength(_catalog.allLectures.length));
      expect(_catalog.search('   '), hasLength(_catalog.allLectures.length));
    });

    test('unknown query returns no results', () {
      expect(_catalog.search('zzzz-tidak-ada-zzzz'), isEmpty);
    });

    test('multiple words narrow the result set', () {
      final single = _catalog.search('tafsir');
      final combined = _catalog.search('tafsir yasin');
      expect(combined.length, lessThanOrEqualTo(single.length));
      expect(
        combined.every(
          (lecture) =>
              lecture.title.toLowerCase().contains('yasin') ||
              lecture.category.label.toLowerCase().contains('yasin'),
        ),
        isTrue,
      );
    });

    test('search respects the category and Ustadz filters', () {
      final byCategory = _catalog.search('', category: LectureCategory.fiqih);
      expect(byCategory, isNotEmpty);
      expect(
        byCategory.every(
          (lecture) => lecture.category == LectureCategory.fiqih,
        ),
        isTrue,
      );

      final ustadz = _catalog.allUstadz.first;
      final byUstadz = _catalog.search('', ustadzId: ustadz.id);
      expect(byUstadz, isNotEmpty);
      expect(
        byUstadz.every((lecture) => lecture.ustadzId == ustadz.id),
        isTrue,
      );
    });

    test('filtered search can legitimately return nothing', () {
      final results = _catalog.search(
        'zzzz-tidak-ada-zzzz',
        category: LectureCategory.aqidah,
      );
      expect(results, isEmpty);
    });
  });

  group('Kajian category filtering', () {
    test('byCategory only returns lectures from that theme', () {
      for (final category in LectureCategory.values) {
        final lectures = _catalog.byCategory(category);
        expect(
          lectures.every((lecture) => lecture.category == category),
          isTrue,
          reason: category.slug,
        );
        expect(lectures, hasLength(_catalog.countForCategory(category)));
      }
    });

    test('category counts add up to the whole catalogue', () {
      final total = LectureCategory.values
          .map(_catalog.countForCategory)
          .fold<int>(0, (sum, count) => sum + count);
      expect(total, _catalog.allLectures.length);
    });

    test('Ustadz counts match their lecture lists', () {
      for (final ustadz in _catalog.allUstadz) {
        expect(
          _catalog.byUstadz(ustadz.id),
          hasLength(_catalog.countForUstadz(ustadz.id)),
        );
      }
    });

    test('category lists are sorted newest first', () {
      for (final category in LectureCategory.values) {
        final dates = _catalog
            .byCategory(category)
            .map((lecture) => lecture.publishedDate)
            .whereType<DateTime>()
            .toList();
        for (var i = 1; i < dates.length; i++) {
          expect(
            dates[i - 1].isBefore(dates[i]),
            isFalse,
            reason: '${category.slug} is not newest-first',
          );
        }
      }
    });
  });

  group('Kajian related lectures', () {
    test('never includes the current lecture or duplicates', () {
      for (final lecture in _catalog.allLectures) {
        final related = _catalog.related(lecture);
        expect(
          related.map((item) => item.id),
          isNot(contains(lecture.id)),
          reason: lecture.id,
        );
        expect(
          related.map((item) => item.id).toSet().length,
          related.length,
          reason: lecture.id,
        );
        expect(related.length, lessThanOrEqualTo(3));
      }
    });

    test('prefers lectures from the same theme', () {
      final lecture = _catalog.allLectures.firstWhere(
        (item) => _catalog.countForCategory(item.category) > 1,
      );
      final related = _catalog.related(lecture, limit: 1);
      expect(related, isNotEmpty);
      expect(related.first.category, lecture.category);
    });

    test('respects the requested limit', () {
      final lecture = _catalog.allLectures.first;
      expect(_catalog.related(lecture, limit: 1), hasLength(1));
      expect(_catalog.related(lecture, limit: 2), hasLength(2));
      expect(_catalog.related(lecture, limit: 0), isEmpty);
    });
  });

  group('YouTube id parsing', () {
    test('accepts a raw id', () {
      expect(YoutubeVideo.parseId('BkL00UHhg7o'), 'BkL00UHhg7o');
    });

    test('accepts a standard watch URL', () {
      expect(
        YoutubeVideo.parseId('https://www.youtube.com/watch?v=BkL00UHhg7o'),
        'BkL00UHhg7o',
      );
      expect(
        YoutubeVideo.parseId(
          'https://www.youtube.com/watch?list=PL123&v=BkL00UHhg7o&t=42s',
        ),
        'BkL00UHhg7o',
      );
    });

    test('accepts short and embed URLs', () {
      expect(
        YoutubeVideo.parseId('https://youtu.be/BkL00UHhg7o?t=10'),
        'BkL00UHhg7o',
      );
      expect(
        YoutubeVideo.parseId('https://www.youtube.com/embed/BkL00UHhg7o'),
        'BkL00UHhg7o',
      );
      expect(
        YoutubeVideo.parseId('https://www.youtube.com/shorts/BkL00UHhg7o'),
        'BkL00UHhg7o',
      );
    });

    test('rejects invalid input', () {
      expect(YoutubeVideo.parseId(''), isNull);
      expect(YoutubeVideo.parseId('   '), isNull);
      expect(YoutubeVideo.parseId('bukan url'), isNull);
      expect(YoutubeVideo.parseId('https://vimeo.com/123456'), isNull);
      expect(
        YoutubeVideo.parseId('https://www.youtube.com/watch?v=terlalupendek'),
        isNull,
      );
      expect(YoutubeVideo.parseId('abc'), isNull);
      expect(YoutubeVideo.isValidId('BkL00UHhg7o!'), isFalse);
    });

    test('builds a watch URL from an id', () {
      expect(
        YoutubeVideo.watchUrl('BkL00UHhg7o'),
        'https://www.youtube.com/watch?v=BkL00UHhg7o',
      );
    });
  });

  group('Kajian bookmarks provider', () {
    late SharedPreferences prefs;
    late PreferencesService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      service = PreferencesService(prefs);
    });

    ProviderContainer createContainer() {
      final container = ProviderContainer(
        overrides: [preferencesProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('starts empty', () {
      final container = createContainer();
      expect(container.read(kajianBookmarksProvider), isEmpty);
    });

    test('adds and removes a bookmark', () {
      final container = createContainer();
      final notifier = container.read(kajianBookmarksProvider.notifier);

      notifier.toggle('tauhid-jalan-keselamatan');
      expect(
        container.read(kajianBookmarksProvider),
        contains('tauhid-jalan-keselamatan'),
      );

      notifier.toggle('tauhid-jalan-keselamatan');
      expect(container.read(kajianBookmarksProvider), isEmpty);
    });

    test('never stores duplicates', () {
      final container = createContainer();
      final notifier = container.read(kajianBookmarksProvider.notifier);

      notifier.toggle('a');
      notifier.toggle('b');
      notifier.toggle('a');
      notifier.toggle('a');

      final bookmarks = container.read(kajianBookmarksProvider);
      expect(bookmarks, hasLength(2));
      expect(bookmarks, containsAll(<String>['a', 'b']));
    });

    test('persists and restores bookmarks', () async {
      final container = createContainer();
      container
          .read(kajianBookmarksProvider.notifier)
          .toggle('tauhid-jalan-keselamatan');

      // The write is fire-and-forget; let the microtask queue drain.
      await Future<void>.delayed(Duration.zero);

      expect(
        service.readKajianBookmarks(),
        contains('tauhid-jalan-keselamatan'),
      );

      final restored = createContainer();
      expect(
        restored.read(kajianBookmarksProvider),
        contains('tauhid-jalan-keselamatan'),
      );
    });

    test('clear empties both state and storage', () async {
      final container = createContainer();
      final notifier = container.read(kajianBookmarksProvider.notifier);

      notifier.toggle('a');
      notifier.toggle('b');
      await Future<void>.delayed(Duration.zero);

      notifier.clear();
      expect(container.read(kajianBookmarksProvider), isEmpty);

      await Future<void>.delayed(Duration.zero);
      expect(service.readKajianBookmarks(), isEmpty);

      final restored = createContainer();
      expect(restored.read(kajianBookmarksProvider), isEmpty);
    });

    test('restores values already present in storage', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'bitaqwa.kajian_bookmarks': <String>['a', 'b'],
      });
      final stored = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          preferencesProvider.overrideWithValue(PreferencesService(stored)),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(kajianBookmarksProvider),
        containsAll(<String>['a', 'b']),
      );
    });
  });
}
