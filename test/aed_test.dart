import 'package:aed_map/constants.dart';
import 'package:aed_map/models/aed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Defibrillator', () {
    test('toXml removes empty image tag', () {
      final defibrillator = Defibrillator(
        id: 7,
        location: warsaw,
        description: 'test_description',
        indoor: 'no',
        access: 'yes',
        image: '',
      );

      final xml = defibrillator.toXml(1, 2, 'pl', oldTags: [
        ['image', 'https://example.com/photo.jpg'],
      ]).toString();

      expect(xml, isNot(contains('k="image"')));
      expect(xml, isNot(contains('https://example.com/photo.jpg')));
    });
  });
}
