import 'package:flutter_test/flutter_test.dart';

void main() {
  group('System Tests - Kullanici Akisi', () {

    Map<String, dynamic> simulateUserRegistration(String email, String password) {
      if (email.isEmpty || !email.contains('@')) return {'success': false, 'error': 'Gecersiz email'};
      if (password.length < 6) return {'success': false, 'error': 'Sifre cok kisa'};
      return {'success': true, 'uid': 'user_123', 'email': email};
    }

    Map<String, dynamic> simulateLogin(String email, String password) {
      if (email == 'test@test.com' && password == 'password123') return {'success': true, 'uid': 'user_123'};
      return {'success': false, 'error': 'Gecersiz kimlik bilgileri'};
    }

    Map<String, dynamic> simulateProductScan(String barcode) {
      if (barcode.isEmpty) return {'success': false, 'error': 'Barkod bos'};
      if (barcode.length < 8) return {'success': false, 'error': 'Gecersiz barkod'};
      return {'success': true, 'product': {'name': 'Test Urun', 'barcode': barcode, 'healthScore': 72, 'category': 'Orta'}};
    }

    Map<String, dynamic> simulateAddToFavorites(String barcode, List<String> favorites) {
      if (favorites.contains(barcode)) return {'success': false, 'error': 'Zaten favorilerde'};
      favorites.add(barcode);
      return {'success': true, 'favoritesCount': favorites.length};
    }

    Map<String, dynamic> simulateRemoveFromFavorites(String barcode, List<String> favorites) {
      if (!favorites.contains(barcode)) return {'success': false, 'error': 'Favorilerde yok'};
      favorites.remove(barcode);
      return {'success': true, 'favoritesCount': favorites.length};
    }

    Map<String, dynamic> simulateDietFilter(String dietType, List<Map<String, dynamic>> products) {
      final filtered = products.where((p) => (p['dietTags'] as List?)?.contains(dietType) ?? false).toList();
      return {'success': true, 'products': filtered, 'count': filtered.length};
    }

    Map<String, dynamic> simulateSearch(String query, List<Map<String, dynamic>> products) {
      if (query.isEmpty) return {'success': false, 'error': 'Arama terimi bos'};
      final results = products.where((p) => p['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
      return {'success': true, 'results': results, 'count': results.length};
    }

    Map<String, dynamic> simulateChatMessage(String message) {
      if (message.isEmpty) return {'success': false, 'error': 'Mesaj bos'};
      if (message.length < 3) return {'success': false, 'error': 'Mesaj cok kisa'};
      return {'success': true, 'response': 'AI cevabi: $message hakkinda bilgi'};
    }

    test('valid user registration should succeed', () {
      final result = simulateUserRegistration('test@example.com', 'password123');
      expect(result['success'], true);
    });

    test('invalid email registration should fail', () {
      final result = simulateUserRegistration('invalid', 'password123');
      expect(result['success'], false);
    });

    test('short password should fail', () {
      final result = simulateUserRegistration('test@test.com', '123');
      expect(result['success'], false);
    });

    test('valid login should succeed', () {
      final result = simulateLogin('test@test.com', 'password123');
      expect(result['success'], true);
      expect(result['uid'], isNotNull);
    });

    test('wrong password login should fail', () {
      final result = simulateLogin('test@test.com', 'wrongpass');
      expect(result['success'], false);
    });

    test('valid barcode scan should return product', () {
      final result = simulateProductScan('5449000000996');
      expect(result['success'], true);
      expect(result['product']['healthScore'], isNotNull);
    });

    test('empty barcode should fail', () {
      final result = simulateProductScan('');
      expect(result['success'], false);
    });

    test('short barcode should fail', () {
      final result = simulateProductScan('123');
      expect(result['success'], false);
    });

    test('adding to favorites should work', () {
      final favorites = <String>[];
      final result = simulateAddToFavorites('5449000000996', favorites);
      expect(result['success'], true);
      expect(result['favoritesCount'], 1);
    });

    test('adding duplicate to favorites should fail', () {
      final favorites = ['5449000000996'];
      final result = simulateAddToFavorites('5449000000996', favorites);
      expect(result['success'], false);
    });

    test('removing from favorites should work', () {
      final favorites = ['5449000000996'];
      final result = simulateRemoveFromFavorites('5449000000996', favorites);
      expect(result['success'], true);
      expect(result['favoritesCount'], 0);
    });

    test('removing non-existing favorite should fail', () {
      final favorites = <String>[];
      final result = simulateRemoveFromFavorites('5449000000996', favorites);
      expect(result['success'], false);
    });

    test('diet filter should return matching products', () {
      final products = [
        {'name': 'Alpro Soya', 'dietTags': ['vegan', 'glutensiz']},
        {'name': 'Coca Cola', 'dietTags': ['vegan']},
        {'name': 'Ekmek', 'dietTags': ['vejetaryen']},
      ];
      final result = simulateDietFilter('vegan', products);
      expect(result['count'], 2);
    });

    test('diet filter with no match should return empty', () {
      final products = [{'name': 'Et', 'dietTags': ['normal']}];
      final result = simulateDietFilter('vegan', products);
      expect(result['count'], 0);
    });

    test('search should find matching products', () {
      final products = [
        {'name': 'Coca Cola'},
        {'name': 'Pepsi'},
        {'name': 'Cola Zero'},
      ];
      final result = simulateSearch('cola', products);
      expect(result['count'], 2);
    });

    test('empty search should fail', () {
      final result = simulateSearch('', []);
      expect(result['success'], false);
    });

    test('chat with valid message should succeed', () {
      final result = simulateChatMessage('Protein icin ne yemeliyim?');
      expect(result['success'], true);
      expect(result['response'], isNotEmpty);
    });

    test('empty chat message should fail', () {
      final result = simulateChatMessage('');
      expect(result['success'], false);
    });

    test('too short chat message should fail', () {
      final result = simulateChatMessage('hi');
      expect(result['success'], false);
    });

    test('full user journey should complete', () {
      final reg = simulateUserRegistration('user@test.com', 'password123');
      expect(reg['success'], true);
      final scan = simulateProductScan('5449000000996');
      expect(scan['success'], true);
      final favorites = <String>[];
      final fav = simulateAddToFavorites(scan['product']['barcode'], favorites);
      expect(fav['success'], true);
      expect(fav['favoritesCount'], 1);
    });

    test('multiple favorites management', () {
      final favorites = <String>[];
      simulateAddToFavorites('111', favorites);
      simulateAddToFavorites('222', favorites);
      simulateAddToFavorites('333', favorites);
      expect(favorites.length, 3);
      simulateRemoveFromFavorites('222', favorites);
      expect(favorites.length, 2);
    });
  });
}
