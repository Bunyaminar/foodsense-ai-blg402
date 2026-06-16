import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'food_api_service.dart';

class FavoriteItem {
  final String id;
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final int? healthScore;
  final DateTime addedAt;

  FavoriteItem({
    required this.id,
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.healthScore,
    required this.addedAt,
  });

  factory FavoriteItem.fromFirestore(Map<String, dynamic> data, String id) {
    return FavoriteItem(
      id: id,
      barcode: data['barcode'] ?? '',
      name: data['name'] ?? '',
      brand: data['brand'],
      imageUrl: data['imageUrl'],
      healthScore: data['healthScore'],
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'healthScore': healthScore,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}

class FavoritesService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static CollectionReference? get _favoritesRef {
    if (_uid == null) return null;
    return _db.collection('users').doc(_uid).collection('favorites');
  }

  // Favori ekle
  static Future<bool> addFavorite(ProductModel product, {int? healthScore}) async {
    try {
      if (_favoritesRef == null) return false;
      
      // Zaten favoride mi kontrol et
      final existing = await _favoritesRef!
          .where('barcode', isEqualTo: product.barcode)
          .get();
      
      if (existing.docs.isNotEmpty) return true; // Zaten var
      
      await _favoritesRef!.add({
        'barcode': product.barcode,
        'name': product.name,
        'brand': product.brand,
        'imageUrl': product.imageUrl,
        'healthScore': healthScore,
        'addedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Favoriden kaldır
  static Future<bool> removeFavorite(String barcode) async {
    try {
      if (_favoritesRef == null) return false;
      final docs = await _favoritesRef!
          .where('barcode', isEqualTo: barcode)
          .get();
      for (final doc in docs.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Favoride mi kontrol et
  static Future<bool> isFavorite(String barcode) async {
    try {
      if (_favoritesRef == null) return false;
      final docs = await _favoritesRef!
          .where('barcode', isEqualTo: barcode)
          .get();
      return docs.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Tüm favorileri getir
  static Future<List<FavoriteItem>> getFavorites() async {
    try {
      if (_favoritesRef == null) return [];
      final snapshot = await _favoritesRef!
          .orderBy('addedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => FavoriteItem.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }
}