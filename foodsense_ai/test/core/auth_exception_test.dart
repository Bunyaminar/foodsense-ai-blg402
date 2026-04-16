import 'package:flutter_test/flutter_test.dart';
import 'package:foodsense_ai/core/exceptions/auth_exception.dart';

void main() {
  group('AuthException Tests', () {
    test('fromFirebaseCode should return correct message for email-already-in-use', () {
      final exception = AuthException.fromFirebaseCode('email-already-in-use');
      expect(exception.message, 'Bu e-posta adresi zaten kullanımda');
      expect(exception.code, 'email-already-in-use');
    });

    test('fromFirebaseCode should return correct message for invalid-email', () {
      final exception = AuthException.fromFirebaseCode('invalid-email');
      expect(exception.message, 'Geçersiz e-posta adresi');
      expect(exception.code, 'invalid-email');
    });

    test('fromFirebaseCode should return correct message for weak-password', () {
      final exception = AuthException.fromFirebaseCode('weak-password');
      expect(exception.message, 'Şifre en az 6 karakter olmalıdır');
      expect(exception.code, 'weak-password');
    });

    test('fromFirebaseCode should return correct message for user-not-found', () {
      final exception = AuthException.fromFirebaseCode('user-not-found');
      expect(exception.message, 'Kullanıcı bulunamadı');
      expect(exception.code, 'user-not-found');
    });

    test('fromFirebaseCode should return correct message for wrong-password', () {
      final exception = AuthException.fromFirebaseCode('wrong-password');
      expect(exception.message, 'Hatalı şifre');
      expect(exception.code, 'wrong-password');
    });

    test('fromFirebaseCode should return generic message for unknown code', () {
      final exception = AuthException.fromFirebaseCode('unknown-error');
      expect(exception.message, 'Bir hata oluştu: unknown-error');
      expect(exception.code, 'unknown-error');
    });
  });
}
