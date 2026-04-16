import 'package:flutter_test/flutter_test.dart';
import 'package:foodsense_ai/core/constants/app_constants.dart';

void main() {
  group('AppConstants Tests', () {
    test('Firestore collection names should be correct', () {
      expect(AppConstants.firestoreUsersCollection, 'users');
      expect(AppConstants.firestoreProfilesCollection, 'user_profiles');
    });

    test('Password validation constants should be correct', () {
      expect(AppConstants.minPasswordLength, 6);
    });

    test('Email regex should validate correct emails', () {
      final regex = RegExp(AppConstants.emailRegex);
      
      expect(regex.hasMatch('test@example.com'), true);
      expect(regex.hasMatch('user.name@domain.co.uk'), true);
      expect(regex.hasMatch('invalid.email'), false);
      expect(regex.hasMatch('@invalid.com'), false);
      expect(regex.hasMatch('no-at-sign.com'), false);
    });

    test('Route names should be correct', () {
      expect(AppConstants.loginRoute, '/login');
      expect(AppConstants.registerRoute, '/register');
      expect(AppConstants.profileWizardRoute, '/profile-wizard');
      expect(AppConstants.dashboardRoute, '/dashboard');
    });
  });
}
