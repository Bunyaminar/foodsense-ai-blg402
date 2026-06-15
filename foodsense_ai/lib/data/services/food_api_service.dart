import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductModel {
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final String? ingredients;
  final Map<String, dynamic>? nutrients;
  final List<String> allergens;
  final int? nutriScore;
  final String? novaGroup;

  ProductModel({
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.ingredients,
    this.nutrients,
    this.allergens = const [],
    this.nutriScore,
    this.novaGroup,
  });

  factory ProductModel.fromOpenFoodFacts(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    
    // Alerjenler
    List<String> allergenList = [];
    final allergensTags = product['allergens_tags'] as List? ?? [];
    for (final tag in allergensTags) {
      final allergen = tag.toString().replaceAll('en:', '').replaceAll('-', ' ');
      allergenList.add(allergen);
    }

    // Besin değerleri
    Map<String, dynamic>? nutrients;
    if (product['nutriments'] != null) {
      final n = product['nutriments'];
      nutrients = {
        'energy': n['energy-kcal_100g'],
        'fat': n['fat_100g'],
        'saturatedFat': n['saturated-fat_100g'],
        'carbohydrates': n['carbohydrates_100g'],
        'sugars': n['sugars_100g'],
        'fiber': n['fiber_100g'],
        'protein': n['proteins_100g'],
        'salt': n['salt_100g'],
      };
    }

    return ProductModel(
      barcode: product['code'] ?? '',
      name: product['product_name_tr'] ?? 
            product['product_name'] ?? 
            'Bilinmeyen Urun',
      brand: product['brands'],
      imageUrl: product['image_front_url'],
      ingredients: product['ingredients_text_tr'] ?? 
                   product['ingredients_text'],
      nutrients: nutrients,
      allergens: allergenList,
      nutriScore: product['nutriscore_score'],
      novaGroup: product['nova_group']?.toString(),
    );
  }
}

class FoodApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';

  static Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/$barcode.json');
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FoodsenseAI/1.0 (contact@foodsense.ai)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 1) {
          return ProductModel.fromOpenFoodFacts(json);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Saglik skoru hesapla (0-100)
  static int calculateHealthScore(ProductModel product) {
    int score = 50; // Baslangic skoru

    if (product.nutriScore != null) {
      // NutriScore -15 ile +40 arasi
      final normalized = ((product.nutriScore! + 15) / 55 * 100).clamp(0, 100);
      score = (100 - normalized).toInt();
    }

    // Alerjen varsa dusur
    if (product.allergens.isNotEmpty) {
      score -= product.allergens.length * 5;
    }

    return score.clamp(0, 100);
  }

  // Alerjen uyarisi
  static List<String> checkAllergens(ProductModel product, List<String> userAllergens) {
    List<String> warnings = [];
    for (final allergen in product.allergens) {
      for (final userAllergen in userAllergens) {
        if (allergen.toLowerCase().contains(userAllergen.toLowerCase())) {
          warnings.add(allergen);
        }
      }
    }
    return warnings;
  }
}