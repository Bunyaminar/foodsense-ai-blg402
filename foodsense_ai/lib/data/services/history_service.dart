import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalysisHistoryItem {
  final String id;
  final String barcode;
  final String productName;
  final String? brand;
  final String? imageUrl;
  final int healthScore;
  final String category;
  final List<String> warnings;
  final List<String> positives;
  final DateTime analyzedAt;

  AnalysisHistoryItem({
    required this.id,
    required this.barcode,
    required this.productName,
    this.brand,
    this.imageUrl,
    required this.healthScore,
    required this.category,
    required this.warnings,
    required this.positives,
    required this.analyzedAt,
  });

  factory AnalysisHistoryItem.fromFirestore(Map<String, dynamic> data, String id) {
    return AnalysisHistoryItem(
      id: id,
      barcode: data['barcode'] ?? '',
      productName: data['productName'] ?? '',
      brand: data['brand'],
      imageUrl: data['imageUrl'],
      healthScore: data['healthScore'] ?? 0,
      category: data['category'] ?? 'unknown',
      warnings: List<String>.from(data['warnings'] ?? []),
      positives: List<String>.from(data['positives'] ?? []),
      analyzedAt: (data['analyzedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'barcode': barcode,
      'productName': productName,
      'brand': brand,
      'imageUrl': imageUrl,
      'healthScore': healthScore,
      'category': category,
      'warnings': warnings,
      'positives': positives,
      'analyzedAt': Timestamp.fromDate(analyzedAt),
    };
  }
}

class HistoryService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static CollectionReference? get _historyRef {
    if (_uid == null) return null;
    return _db.collection('users').doc(_uid).collection('analysis_history');
  }

  // Analizi kaydet
  static Future<bool> saveAnalysis({
    required String barcode,
    required String productName,
    String? brand,
    String? imageUrl,
    required int healthScore,
    required String category,
    required List<String> warnings,
    required List<String> positives,
  }) async {
    try {
      if (_historyRef == null) return false;

      // Aynı barkod varsa güncelle
      final existing = await _historyRef!
          .where('barcode', isEqualTo: barcode)
          .get();

      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.update({
          'healthScore': healthScore,
          'category': category,
          'warnings': warnings,
          'positives': positives,
          'analyzedAt': Timestamp.now(),
        });
      } else {
        await _historyRef!.add({
          'barcode': barcode,
          'productName': productName,
          'brand': brand,
          'imageUrl': imageUrl,
          'healthScore': healthScore,
          'category': category,
          'warnings': warnings,
          'positives': positives,
          'analyzedAt': Timestamp.now(),
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Geçmişi getir
  static Future<List<AnalysisHistoryItem>> getHistory() async {
    try {
      if (_historyRef == null) return [];
      final snapshot = await _historyRef!
          .orderBy('analyzedAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs
          .map((doc) => AnalysisHistoryItem.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Geçmişi temizle
  static Future<void> clearHistory() async {
    try {
      if (_historyRef == null) return;
      final snapshot = await _historyRef!.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {}
  }
}