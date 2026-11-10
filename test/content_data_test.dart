import 'package:bitaqwa/core/data/duas.dart';
import 'package:bitaqwa/core/data/surahs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bundled content', () {
    test('contains all 114 surahs in order', () {
      expect(Surahs.all, hasLength(114));
      for (var index = 0; index < Surahs.all.length; index++) {
        expect(Surahs.all[index].number, index + 1);
      }
    });

    test('sets have complete text and source fields', () {
      expect(Duas.all, isNotEmpty);
      for (final dua in Duas.all) {
        expect(dua.title.trim(), isNotEmpty);
        expect(dua.arabic.trim(), isNotEmpty);
        expect(dua.translation.trim(), isNotEmpty);
        expect(dua.source.trim(), isNotEmpty);
      }
    });
  });
}
