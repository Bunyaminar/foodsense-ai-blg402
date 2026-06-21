import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nutrition Calculator Tests', () {

    double calculateBMI(double weight, double height) {
      if (height <= 0) return 0;
      return weight / (height * height);
    }

    String getBMICategory(double bmi) {
      if (bmi < 18.5) return 'Dusuk Kilo';
      if (bmi < 25) return 'Normal';
      if (bmi < 30) return 'Fazla Kilo';
      return 'Obez';
    }

    double calculateDailyCalories(double weight, double height, int age, bool isMale) {
      if (isMale) {
        return 88.362 + (13.397 * weight) + (4.799 * height * 100) - (5.677 * age);
      } else {
        return 447.593 + (9.247 * weight) + (3.098 * height * 100) - (4.330 * age);
      }
    }

    double calculateProteinNeed(double weight) {
      return weight * 0.8;
    }

    test('normal BMI should return Normal category', () {
      final bmi = calculateBMI(70, 1.75);
      expect(getBMICategory(bmi), 'Normal');
    });

    test('high BMI should return Obez category', () {
      final bmi = calculateBMI(100, 1.70);
      expect(getBMICategory(bmi), 'Obez');
    });

    test('low BMI should return Dusuk Kilo', () {
      final bmi = calculateBMI(45, 1.70);
      expect(getBMICategory(bmi), 'Dusuk Kilo');
    });

    test('zero height should return 0 BMI', () {
      expect(calculateBMI(70, 0), 0);
    });

    test('male calorie calculation should be higher than female', () {
      final male = calculateDailyCalories(70, 1.75, 30, true);
      final female = calculateDailyCalories(70, 1.75, 30, false);
      expect(male, greaterThan(female));
    });

    test('protein need should be 0.8g per kg', () {
      expect(calculateProteinNeed(70), closeTo(56, 0.1));
      expect(calculateProteinNeed(80), closeTo(64, 0.1));
    });

    test('BMI calculation should be accurate', () {
      final bmi = calculateBMI(70, 1.75);
      expect(bmi, closeTo(22.86, 0.1));
    });
  });
}
