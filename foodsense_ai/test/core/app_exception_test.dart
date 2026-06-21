import 'package:flutter_test/flutter_test.dart';
import 'package:foodsense_ai/core/exceptions/app_exception.dart';

class TestException extends AppException {
  TestException(String message, {String? code}) : super(message, code: code);
}

void main() {
  group('AppException Tests', () {
    test('should store message correctly', () {
      final e = TestException('Test error');
      expect(e.message, 'Test error');
    });

    test('should store code correctly', () {
      final e = TestException('Error', code: 'ERR_001');
      expect(e.code, 'ERR_001');
    });
  });
}
