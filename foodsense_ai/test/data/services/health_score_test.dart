import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Health Score Tests', () {
    
    int calculateScore(Map<String, dynamic> nutrients) {
      double score = 100.0;
      final sugar = (nutrients['sugars'] ?? 0).toDouble();
      final salt = (nutrients['salt'] ?? 0).toDouble();
      final fat = (nutrients['fat'] ?? 0).toDouble();
      final fiber = (nutrients['fiber'] ?? 0).toDouble();
      final protein = (nutrients['protein'] ?? 0).toDouble();
      
      if (sugar > 10) score -= 20;
      if (sugar > 20) score -= 10;
      if (salt > 1.5) score -= 15;
      if (fat > 20) score -= 10;
      if (fiber > 3) score += 5;
      if (protein > 10) score += 5;
      
      return score.clamp(0, 100).toInt();
    }

    test('healthy product should have high score', () {
      final nutrients = {
        'sugars': 2.0,
        'salt': 0.1,
        'fat': 3.0,
        'fiber': 5.0,
        'protein': 15.0,
      };
      final score = calculateScore(nutrients);
      expect(score, greaterThanOrEqualTo(80));
    });

    test('high sugar product should have low score', () {
      final nutrients = {
        'sugars': 25.0,
        'salt': 0.1,
        'fat': 3.0,
        'fiber': 1.0,
        'protein': 2.0,
      };
      final score = calculateScore(nutrients);
      expect(score, lessThan(80));
    });

    test('high salt product should lose points', () {
      final nutrients = {
        'sugars': 1.0,
        'salt': 3.0,
        'fat': 5.0,
        'fiber': 2.0,
        'protein': 5.0,
      };
      final score = calculateScore(nutrients);
      expect(score, lessThan(90));
    });

    test('fiber rich product should gain bonus points', () {
      final nutrients = {
        'sugars': 2.0,
        'salt': 0.2,
        'fat': 3.0,
        'fiber': 8.0,
        'protein': 12.0,
      };
      final score = calculateScore(nutrients);
      expect(score, greaterThanOrEqualTo(90));
    });

    test('score should be between 0 and 100', () {
      final nutrients = {
        'sugars': 50.0,
        'salt': 5.0,
        'fat': 40.0,
        'fiber': 0.0,
        'protein': 0.0,
      };
      final score = calculateScore(nutrients);
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });

    test('zero values should return full score', () {
      final nutrients = {
        'sugars': 0.0,
        'salt': 0.0,
        'fat': 0.0,
        'fiber': 0.0,
        'protein': 0.0,
      };
      final score = calculateScore(nutrients);
      expect(score, equals(100));
    });
  });
}
