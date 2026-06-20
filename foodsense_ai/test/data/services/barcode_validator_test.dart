import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Barcode Validation Tests', () {

    bool isValidBarcode(String barcode) {
      if (barcode.isEmpty) return false;
      if (barcode.length < 8 || barcode.length > 13) return false;
      for (int i = 0; i < barcode.length; i++) {
        if (barcode.codeUnitAt(i) < 48 || barcode.codeUnitAt(i) > 57) return false;
      }
      return true;
    }

    String formatBarcode(String barcode) {
      return barcode.trim().replaceAll(' ', '');
    }

    test('valid EAN-13 barcode should pass', () {
      expect(isValidBarcode('5449000000996'), true);
    });

    test('valid EAN-8 barcode should pass', () {
      expect(isValidBarcode('12345678'), true);
    });

    test('empty barcode should fail', () {
      expect(isValidBarcode(''), false);
    });

    test('barcode with letters should fail', () {
      expect(isValidBarcode('ABC12345678'), false);
    });

    test('too short barcode should fail', () {
      expect(isValidBarcode('123'), false);
    });

    test('too long barcode should fail', () {
      expect(isValidBarcode('12345678901234'), false);
    });

    test('barcode with spaces should be formatted', () {
      expect(formatBarcode(' 5449000000996 '), '5449000000996');
    });

    test('valid 12 digit barcode should pass', () {
      expect(isValidBarcode('012345678905'), true);
    });
  });
}
