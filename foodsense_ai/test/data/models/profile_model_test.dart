import 'package:flutter_test/flutter_test.dart';
import 'package:foodsense_ai/data/models/profile_model.dart';

void main() {
  group('ProfileModel Tests', () {
    test('ProfileModel toJson should return valid map', () {
      // Arrange
      final profile = ProfileModel(
        userId: 'user123',
        name: 'John Doe',
        allergies: ['gluten', 'dairy'],
        dietType: 'Vegan',
      );

      // Act
      final json = profile.toJson();

      // Assert
      expect(json['userId'], 'user123');
      expect(json['name'], 'John Doe');
      expect(json['allergies'], ['gluten', 'dairy']);
      expect(json['dietType'], 'Vegan');
      expect(json['createdAt'], isNotNull);
    });

    test('ProfileModel fromJson should create valid ProfileModel', () {
      // Arrange
      final json = {
        'userId': 'user456',
        'name': 'Jane Smith',
        'allergies': ['nuts', 'shellfish'],
        'dietType': 'Vegetarian',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Act
      final profile = ProfileModel.fromJson(json);

      // Assert
      expect(profile.userId, 'user456');
      expect(profile.name, 'Jane Smith');
      expect(profile.allergies, ['nuts', 'shellfish']);
      expect(profile.dietType, 'Vegetarian');
    });

    test('ProfileModel copyWith should update only specified fields', () {
      // Arrange
      final original = ProfileModel(
        userId: 'user789',
        name: 'Original Name',
        allergies: ['eggs'],
        dietType: 'Keto',
      );

      // Act
      final updated = original.copyWith(
        name: 'Updated Name',
        allergies: ['eggs', 'soy'],
      );

      // Assert
      expect(updated.userId, 'user789');
      expect(updated.name, 'Updated Name');
      expect(updated.allergies, ['eggs', 'soy']);
      expect(updated.dietType, 'Keto');
    });

    test('ProfileModel should handle empty allergies list', () {
      // Arrange & Act
      final profile = ProfileModel(
        userId: 'user000',
        name: 'No Allergies',
      );

      // Assert
      expect(profile.allergies, isEmpty);
      expect(profile.dietType, null);
    });
  });
}
