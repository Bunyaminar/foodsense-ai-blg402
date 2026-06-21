import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firestore Data Tests', () {

    Map<String, dynamic> createFavoriteItem({
      required String barcode,
      required String name,
      required int score,
      String? imageUrl,
    }) {
      return {
        'barcode': barcode,
        'productName': name,
        'healthScore': score,
        'imageUrl': imageUrl,
        'addedAt': DateTime.now().toIso8601String(),
      };
    }

    Map<String, dynamic> createHistoryItem({
      required String barcode,
      required String name,
      required int score,
    }) {
      return {
        'barcode': barcode,
        'productName': name,
        'healthScore': score,
        'analyzedAt': DateTime.now().toIso8601String(),
      };
    }

    bool isValidFavoriteItem(Map<String, dynamic> item) {
      return item.containsKey('barcode') &&
             item.containsKey('productName') &&
             item.containsKey('healthScore') &&
             item.containsKey('addedAt');
    }

    bool isValidHistoryItem(Map<String, dynamic> item) {
      return item.containsKey('barcode') &&
             item.containsKey('productName') &&
             item.containsKey('healthScore') &&
             item.containsKey('analyzedAt');
    }

    test('favorite item should have required fields', () {
      final item = createFavoriteItem(
        barcode: '5449000000996',
        name: 'Coca Cola',
        score: 35,
      );
      expect(isValidFavoriteItem(item), true);
    });

    test('history item should have required fields', () {
      final item = createHistoryItem(
        barcode: '5449000000996',
        name: 'Coca Cola',
        score: 35,
      );
      expect(isValidHistoryItem(item), true);
    });

    test('favorite item barcode should match', () {
      final item = createFavoriteItem(
        barcode: '5449000000996',
        name: 'Coca Cola',
        score: 35,
      );
      expect(item['barcode'], '5449000000996');
    });

    test('favorite item without imageUrl should have null imageUrl', () {
      final item = createFavoriteItem(
        barcode: '123',
        name: 'Test',
        score: 50,
      );
      expect(item['imageUrl'], isNull);
    });

    test('health score should be stored correctly', () {
      final item = createHistoryItem(
        barcode: '123',
        name: 'Test',
        score: 75,
      );
      expect(item['healthScore'], 75);
    });

    test('multiple items should be independent', () {
      final item1 = createFavoriteItem(barcode: '111', name: 'A', score: 80);
      final item2 = createFavoriteItem(barcode: '222', name: 'B', score: 40);
      expect(item1['barcode'], isNot(equals(item2['barcode'])));
      expect(item1['healthScore'], isNot(equals(item2['healthScore'])));
    });

    test('date should be in ISO format', () {
      final item = createHistoryItem(barcode: '123', name: 'Test', score: 50);
      expect(DateTime.tryParse(item['analyzedAt']), isNotNull);
    });
  });
}
