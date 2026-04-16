import 'package:flutter_test/flutter_test.dart';
import 'package:foodsense_ai/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel toJson should return valid map', () {
      // Arrange
      final user = UserModel(
        uid: 'test123',
        email: 'test@example.com',
        emailVerified: true,
        displayName: 'Test User',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['uid'], 'test123');
      expect(json['email'], 'test@example.com');
      expect(json['emailVerified'], true);
      expect(json['displayName'], 'Test User');
    });

    test('UserModel fromJson should create valid UserModel', () {
      // Arrange
      final json = {
        'uid': 'test456',
        'email': 'user@example.com',
        'emailVerified': false,
        'displayName': 'Another User',
      };

      // Act
      final user = UserModel.fromJson(json);

      // Assert
      expect(user.uid, 'test456');
      expect(user.email, 'user@example.com');
      expect(user.emailVerified, false);
      expect(user.displayName, 'Another User');
    });

    test('UserModel fromJson should handle missing displayName', () {
      // Arrange
      final json = {
        'uid': 'test789',
        'email': 'minimal@example.com',
        'emailVerified': true,
      };

      // Act
      final user = UserModel.fromJson(json);

      // Assert
      expect(user.uid, 'test789');
      expect(user.email, 'minimal@example.com');
      expect(user.emailVerified, true);
      expect(user.displayName, null);
    });
  });
}
