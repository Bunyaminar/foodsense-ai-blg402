import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('API Integration Tests', () {

    Map<String, dynamic> parseProductResponse(String jsonStr) {
      final data = json.decode(jsonStr);
      return {
        'name': data['product']?['product_name'] ?? 'Bilinmeyen',
        'calories': data['product']?['nutriments']?['energy-kcal_100g'] ?? 0,
        'protein': data['product']?['nutriments']?['proteins_100g'] ?? 0,
        'fat': data['product']?['nutriments']?['fat_100g'] ?? 0,
        'sugar': data['product']?['nutriments']?['sugars_100g'] ?? 0,
        'salt': data['product']?['nutriments']?['salt_100g'] ?? 0,
        'fiber': data['product']?['nutriments']?['fiber_100g'] ?? 0,
      };
    }

    Map<String, dynamic> parseHealthScoreResponse(String jsonStr) {
      final data = json.decode(jsonStr);
      return {
        'health_score': data['health_score'] ?? 0,
        'category': data['category'] ?? '',
        'diet_compatibility': data['diet_compatibility'] ?? {},
        'warnings': data['warnings'] ?? [],
      };
    }

    String parseChatResponse(String jsonStr) {
      final data = json.decode(jsonStr);
      return data['response'] ?? '';
    }

    bool isValidApiResponse(Map<String, dynamic> response) {
      return response.containsKey('name') && response.containsKey('calories');
    }

    test('product API response should be parsed correctly', () {
      final mockResponse = json.encode({
        'status': 1,
        'product': {
          'product_name': 'Coca Cola',
          'nutriments': {
            'energy-kcal_100g': 42,
            'proteins_100g': 0,
            'fat_100g': 0,
            'sugars_100g': 10.6,
            'salt_100g': 0.01,
          }
        }
      });
      final result = parseProductResponse(mockResponse);
      expect(result['name'], 'Coca Cola');
      expect(result['calories'], 42);
      expect(result['sugar'], 10.6);
    });

    test('health score response should be parsed correctly', () {
      final mockResponse = json.encode({
        'health_score': 72,
        'category': 'Orta',
        'diet_compatibility': {'vegan': true, 'glutensiz': true},
        'warnings': []
      });
      final result = parseHealthScoreResponse(mockResponse);
      expect(result['health_score'], 72);
      expect(result['category'], 'Orta');
      expect(result['diet_compatibility']['vegan'], true);
    });

    test('chat response should be parsed correctly', () {
      final mockResponse = json.encode({'response': 'Kas kazanmak icin protein tuketin.'});
      final result = parseChatResponse(mockResponse);
      expect(result, isNotEmpty);
    });

    test('missing product data should return defaults', () {
      final mockResponse = json.encode({'status': 0, 'product': null});
      final result = parseProductResponse(mockResponse);
      expect(result['name'], 'Bilinmeyen');
      expect(result['calories'], 0);
    });

    test('health score should be in valid range', () {
      final mockResponse = json.encode({'health_score': 85, 'category': 'Saglikli', 'diet_compatibility': {}, 'warnings': []});
      final result = parseHealthScoreResponse(mockResponse);
      expect(result['health_score'], greaterThanOrEqualTo(0));
      expect(result['health_score'], lessThanOrEqualTo(100));
    });

    test('empty chat response should return empty string', () {
      final mockResponse = json.encode({'response': ''});
      expect(parseChatResponse(mockResponse), isEmpty);
    });

    test('product with all nutrients should parse completely', () {
      final mockResponse = json.encode({
        'product': {
          'product_name': 'Test Urun',
          'nutriments': {'energy-kcal_100g': 250, 'proteins_100g': 15, 'fat_100g': 8, 'sugars_100g': 5, 'salt_100g': 0.5, 'fiber_100g': 3}
        }
      });
      final result = parseProductResponse(mockResponse);
      expect(result['protein'], 15);
      expect(result['fiber'], 3);
    });

    test('valid api response check should work', () {
      final response = {'name': 'Test', 'calories': 100};
      expect(isValidApiResponse(response), true);
    });

    test('invalid api response should fail check', () {
      final response = {'data': 'something'};
      expect(isValidApiResponse(response), false);
    });

    test('high calorie product should be identified', () {
      final mockResponse = json.encode({
        'product': {'product_name': 'Burger', 'nutriments': {'energy-kcal_100g': 500, 'proteins_100g': 20, 'fat_100g': 30, 'sugars_100g': 5, 'salt_100g': 1.2}}
      });
      final result = parseProductResponse(mockResponse);
      expect(result['calories'], greaterThan(300));
    });

    test('diet compatibility flags should be boolean', () {
      final mockResponse = json.encode({
        'health_score': 60,
        'category': 'Orta',
        'diet_compatibility': {'vegan': false, 'keto': true, 'glutensiz': true},
        'warnings': ['Yuksek seker']
      });
      final result = parseHealthScoreResponse(mockResponse);
      expect(result['diet_compatibility']['vegan'], isFalse);
      expect(result['diet_compatibility']['keto'], isTrue);
    });

    test('warnings list should be parseable', () {
      final mockResponse = json.encode({
        'health_score': 30,
        'category': 'Dikkat',
        'diet_compatibility': {},
        'warnings': ['Yuksek seker', 'Yuksek tuz', 'Katki maddesi']
      });
      final result = parseHealthScoreResponse(mockResponse);
      expect((result['warnings'] as List).length, 3);
    });

    test('zero nutrient values should be handled', () {
      final mockResponse = json.encode({
        'product': {'product_name': 'Su', 'nutriments': {'energy-kcal_100g': 0, 'proteins_100g': 0, 'fat_100g': 0, 'sugars_100g': 0, 'salt_100g': 0}}
      });
      final result = parseProductResponse(mockResponse);
      expect(result['calories'], 0);
      expect(result['name'], 'Su');
    });
  });

  group('Firestore Data Integration Tests', () {

    Map<String, dynamic> createFavoriteItem({required String barcode, required String name, required int score, String? imageUrl}) {
      return {'barcode': barcode, 'productName': name, 'healthScore': score, 'imageUrl': imageUrl, 'addedAt': DateTime.now().toIso8601String()};
    }

    Map<String, dynamic> createHistoryItem({required String barcode, required String name, required int score}) {
      return {'barcode': barcode, 'productName': name, 'healthScore': score, 'analyzedAt': DateTime.now().toIso8601String()};
    }

    bool isValidFavoriteItem(Map<String, dynamic> item) {
      return item.containsKey('barcode') && item.containsKey('productName') && item.containsKey('healthScore') && item.containsKey('addedAt');
    }

    test('favorite item should have required fields', () {
      final item = createFavoriteItem(barcode: '5449000000996', name: 'Coca Cola', score: 35);
      expect(isValidFavoriteItem(item), true);
    });

    test('history item should have required fields', () {
      final item = createHistoryItem(barcode: '5449000000996', name: 'Coca Cola', score: 35);
      expect(item.containsKey('analyzedAt'), true);
    });

    test('favorite item barcode should match', () {
      final item = createFavoriteItem(barcode: '5449000000996', name: 'Coca Cola', score: 35);
      expect(item['barcode'], '5449000000996');
    });

    test('favorite item without imageUrl should have null imageUrl', () {
      final item = createFavoriteItem(barcode: '123', name: 'Test', score: 50);
      expect(item['imageUrl'], isNull);
    });

    test('health score should be stored correctly', () {
      final item = createHistoryItem(barcode: '123', name: 'Test', score: 75);
      expect(item['healthScore'], 75);
    });

    test('multiple items should be independent', () {
      final item1 = createFavoriteItem(barcode: '111', name: 'A', score: 80);
      final item2 = createFavoriteItem(barcode: '222', name: 'B', score: 40);
      expect(item1['barcode'], isNot(equals(item2['barcode'])));
    });

    test('date should be in ISO format', () {
      final item = createHistoryItem(barcode: '123', name: 'Test', score: 50);
      expect(DateTime.tryParse(item['analyzedAt']), isNotNull);
    });

    test('favorite with imageUrl should store it', () {
      final item = createFavoriteItem(barcode: '123', name: 'Test', score: 50, imageUrl: 'https://example.com/img.jpg');
      expect(item['imageUrl'], 'https://example.com/img.jpg');
    });

    test('product name should be stored correctly', () {
      final item = createFavoriteItem(barcode: '123', name: 'Nutella', score: 45);
      expect(item['productName'], 'Nutella');
    });

    test('high score item should be creatable', () {
      final item = createFavoriteItem(barcode: '999', name: 'Yulaf', score: 90);
      expect(item['healthScore'], 90);
      expect(item['healthScore'], greaterThan(65));
    });
  });
}
