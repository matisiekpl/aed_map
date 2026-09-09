import 'package:aed_map/constants.dart';
import 'package:aed_map/models/aed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Defibrillator', () {
    test('toXml keeps image tag that was not removed by the user', () {
      final defibrillator = Defibrillator(
        id: 7,
        location: warsaw,
        description: 'test_description',
        indoor: 'no',
        access: 'yes',
        image: '',
      );

      final xml = defibrillator.toXml(1, 2, oldTags: [
        ['image', 'https://example.com/photo.jpg'],
      ]).toString();

      expect(xml, contains('k="image" v="https://example.com/photo.jpg"'));
    });

    test('toXml removes image tag marked as removed', () {
      final defibrillator = Defibrillator(
        id: 7,
        location: warsaw,
        description: 'test_description',
        indoor: 'no',
        access: 'yes',
        image: '',
      );

      final xml = defibrillator.toXml(1, 2, oldTags: [
        ['image', 'https://example.com/photo.jpg'],
      ], removedTags: {
        'image'
      }).toString();

      expect(xml, isNot(contains('k="image"')));
      expect(xml, isNot(contains('https://example.com/photo.jpg')));
    });

    test('toXml writes language variants and keeps unknown ones', () {
      final defibrillator = Defibrillator(
        id: 7,
        location: warsaw,
        description: 'Na poziomie 0',
        descriptionTranslations: {'en': 'On level 0'},
        indoor: 'no',
        access: 'yes',
        image: '',
      );

      final xml = defibrillator.toXml(1, 2, oldTags: [
        ['defibrillator:location', 'Stary polski opis'],
        ['defibrillator:location:de', 'Auf Ebene 0'],
      ]).toString();

      expect(xml, contains('k="defibrillator:location" v="Na poziomie 0"'));
      expect(xml, contains('k="defibrillator:location:en" v="On level 0"'));
      expect(xml, isNot(contains('Stary polski opis')));
      expect(xml, contains('k="defibrillator:location:de" v="Auf Ebene 0"'));
    });

    test('toXml removes location translation marked as removed', () {
      final defibrillator = Defibrillator(
        id: 7,
        location: warsaw,
        description: 'Na poziomie 0',
        indoor: 'no',
        access: 'yes',
        image: '',
      );

      final xml = defibrillator.toXml(1, 2, oldTags: [
        ['defibrillator:location:de', 'Auf Ebene 0'],
      ], removedTags: {
        'defibrillator:location:de'
      }).toString();

      expect(xml, isNot(contains('Auf Ebene 0')));
    });

    test('localizedDescription falls back to any translation', () {
      final defibrillator = Defibrillator(
        id: 7,
        location: warsaw,
        descriptionTranslations: {'zh': 'in the hall'},
        indoor: 'no',
        access: 'yes',
      );

      expect(defibrillator.localizedDescription('pl'), 'in the hall');
    });
  });
}
