import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Diet Compatibility Tests', () {

    bool isVeganCompatible(String ingredients) {
      final nonVegan = ['et', 'tavuk', 'balik', 'sut', 'yumurta', 'bal', 'peynir', 'krema'];
      final lower = ingredients.toLowerCase();
      return !nonVegan.any((item) => lower.contains(item));
    }

    bool isGlutenFree(String ingredients) {
      final glutenItems = ['bugday', 'arpa', 'cavdar', 'yulaf', 'gluten', 'un'];
      final lower = ingredients.toLowerCase();
      return !glutenItems.any((item) => lower.contains(item));
    }

    bool isKetoCompatible(Map<String, dynamic> nutrients) {
      final carbs = (nutrients['carbohydrates'] ?? 0).toDouble();
      return carbs <= 10;
    }

    bool isDiabeticCompatible(Map<String, dynamic> nutrients) {
      final sugar = (nutrients['sugars'] ?? 0).toDouble();
      return sugar <= 5;
    }

    test('vegan product should pass vegan check', () {
      expect(isVeganCompatible('domates, salatalik, zeytinyagi'), true);
    });

    test('meat product should fail vegan check', () {
      expect(isVeganCompatible('dana et, tuz, baharatlar'), false);
    });

    test('milk product should fail vegan check', () {
      expect(isVeganCompatible('sut, seker, vanilya'), false);
    });

    test('gluten free product should pass check', () {
      expect(isGlutenFree('pirinc, misir, tuz'), true);
    });

    test('wheat product should fail gluten free check', () {
      expect(isGlutenFree('bugday unu, su, tuz'), false);
    });

    test('low carb product should be keto compatible', () {
      expect(isKetoCompatible({'carbohydrates': 5.0}), true);
    });

    test('high carb product should not be keto compatible', () {
      expect(isKetoCompatible({'carbohydrates': 50.0}), false);
    });

    test('low sugar product should be diabetic compatible', () {
      expect(isDiabeticCompatible({'sugars': 2.0}), true);
    });

    test('high sugar product should not be diabetic compatible', () {
      expect(isDiabeticCompatible({'sugars': 20.0}), false);
    });
  });
}
