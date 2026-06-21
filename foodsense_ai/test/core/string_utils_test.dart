import 'package:flutter_test/flutter_test.dart';

void main() {
  group('String Utils Tests', () {

    String capitalizeFirst(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }

    String truncate(String text, int maxLength) {
      if (text.length <= maxLength) return text;
      return text.substring(0, maxLength) + '...';
    }

    bool isValidEmail(String email) {
      return email.contains('@') && email.contains('.') && email.length > 5;
    }

    bool isStrongPassword(String password) {
      return password.length >= 8;
    }

    String formatProductName(String name) {
      return name.trim().replaceAll(RegExp(r'\s+'), ' ');
    }

    test('capitalize first should work', () {
      expect(capitalizeFirst('hello'), 'Hello');
      expect(capitalizeFirst('WORLD'), 'World');
    });

    test('empty string capitalize should return empty', () {
      expect(capitalizeFirst(''), '');
    });

    test('truncate should add ellipsis', () {
      expect(truncate('Hello World', 5), 'Hello...');
    });

    test('short string should not be truncated', () {
      expect(truncate('Hi', 10), 'Hi');
    });

    test('valid email should pass', () {
      expect(isValidEmail('test@example.com'), true);
      expect(isValidEmail('user.name@domain.org'), true);
    });

    test('invalid email should fail', () {
      expect(isValidEmail('notanemail'), false);
      expect(isValidEmail('ab'), false);
    });

    test('strong password should have 8+ chars', () {
      expect(isStrongPassword('12345678'), true);
      expect(isStrongPassword('1234567'), false);
    });

    test('product name formatting should remove extra spaces', () {
      expect(formatProductName('  Coca   Cola  '), 'Coca Cola');
    });
  });
}
