import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Food API Service Tests', () {

    String translateNutrient(String key) {
      final Map<String, String> translations = {
        'energy-kcal': 'Kalori',
        'fat': 'Yag',
        'saturated-fat': 'Doymus Yag',
        'carbohydrates': 'Karbonhidrat',
        'sugars': 'Seker',
        'fiber': 'Lif',
        'proteins': 'Protein',
        'salt': 'Tuz',
      };
      return translations[key] ?? key;
    }

    bool isValidUrl(String url) {
      return url.startsWith('http://') || url.startsWith('https://');
    }

    String formatScore(int score) {
      if (score >= 65) return 'Saglikli';
      if (score >= 40) return 'Orta';
      return 'Dikkat';
    }

    String getScoreEmoji(int score) {
      if (score >= 65) return '✅';
      if (score >= 40) return '⚠️';
      return '❌';
    }

    test('nutrient translation should work correctly', () {
      expect(translateNutrient('energy-kcal'), 'Kalori');
      expect(translateNutrient('fat'), 'Yag');
      expect(translateNutrient('proteins'), 'Protein');
      expect(translateNutrient('sugars'), 'Seker');
    });

    test('unknown nutrient should return key itself', () {
      expect(translateNutrient('unknown-key'), 'unknown-key');
    });

    test('valid URL check should work', () {
      expect(isValidUrl('https://example.com'), true);
      expect(isValidUrl('http://example.com'), true);
      expect(isValidUrl('ftp://example.com'), false);
      expect(isValidUrl('not-a-url'), false);
    });

    test('score format should return correct label', () {
      expect(formatScore(80), 'Saglikli');
      expect(formatScore(65), 'Saglikli');
      expect(formatScore(50), 'Orta');
      expect(formatScore(40), 'Orta');
      expect(formatScore(39), 'Dikkat');
      expect(formatScore(0), 'Dikkat');
    });

    test('score emoji should match score range', () {
      expect(getScoreEmoji(80), '✅');
      expect(getScoreEmoji(50), '⚠️');
      expect(getScoreEmoji(20), '❌');
    });

    test('all nutrient keys should be translatable', () {
      final keys = ['energy-kcal', 'fat', 'saturated-fat', 'carbohydrates', 'sugars', 'fiber', 'proteins', 'salt'];
      for (final key in keys) {
        final translation = translateNutrient(key);
        expect(translation, isNotEmpty);
        expect(translation, isNot(equals(key)));
      }
    });
  });
}
