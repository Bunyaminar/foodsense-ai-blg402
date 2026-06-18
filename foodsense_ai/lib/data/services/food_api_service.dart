import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      ingredients: product['ingredients_text_tr'] != null && 
                   product['ingredients_text_tr'].toString().isNotEmpty
                   ? product['ingredients_text_tr']
                   : product['ingredients_text'] != null 
                   ? translateIngredients(product['ingredients_text'])
                   : null,
      nutrients: nutrients,
      allergens: allergenList,
      nutriScore: product['nutriscore_score'],
      novaGroup: product['nova_group']?.toString(),
    );
  }
}

const String aiApiUrl = 'https://congenial-sniffle-jrjwxwvx67xfr9p-8000.app.github.dev';

// Basit ingredient cevirisi
String translateIngredients(String ingredients) {
  final translations = {
    // Temel malzemeler
    'water': 'su', 'sugar': 'seker', 'salt': 'tuz', 'flour': 'un',
    'wheat flour': 'bugday unu', 'whole wheat flour': 'tam bugday unu',
    'whole grain wheat flour': 'tam tahilli bugday unu',
    'refined wheat flour': 'rafine bugday unu',
    // Yaglar
    'palm oil': 'palm yagi', 'sunflower oil': 'aycicek yagi',
    'vegetable oil': 'bitkisel yag', 'olive oil': 'zeytinyagi',
    'rapeseed oil': 'kanola yagi', 'coconut oil': 'hindistan cevizi yagi',
    'cocoa butter': 'kakao yagi', 'shea butter': 'shea yagi',
    'butter': 'tereyagi', 'margarine': 'margarin',
    // Sut urunleri
    'milk': 'sut', 'skimmed milk': 'yagsiz sut', 'whole milk': 'tam yag sut',
    'semi-skimmed milk': 'yari yagsiz sut', 'condensed milk': 'sutlu krema',
    'cream': 'krema', 'whey': 'peynir alti suyu', 'lactose': 'laktoz',
    'milk powder': 'sut tozu', 'skimmed milk powder': 'yagsiz sut tozu',
    'buttermilk': 'ayran', 'yogurt': 'yogurt', 'cheese': 'peynir',
    // Yumurta
    'egg': 'yumurta', 'eggs': 'yumurta', 'egg white': 'yumurta aki',
    'egg yolk': 'yumurta sarisi', 'dried egg': 'kurutulmus yumurta',
    // Kakao ve cikolata
    'cocoa powder': 'kakao tozu', 'cocoa mass': 'kakao kitligi',
    'cocoa': 'kakao', 'chocolate': 'cikolata',
    'dark chocolate': 'bitter cikolata', 'milk chocolate': 'sutlu cikolata',
    'white chocolate': 'beyaz cikolata',
    // Kuruyemis
    'hazelnut': 'findik', 'almond': 'badem', 'peanut': 'yer fistigi',
    'walnut': 'ceviz', 'cashew': 'kaju', 'pistachio': 'antep fistigi',
    'pecan': 'pekan cevizi', 'macadamia': 'macadamia',
    'hazelnut paste': 'findik ezmesi', 'almond paste': 'badem ezmesi',
    // Nisasta ve tahil
    'corn starch': 'misir nisastasi', 'wheat starch': 'bugday nisastasi',
    'starch': 'nisasta', 'modified starch': 'modifiye nisasta',
    'rice': 'pirinc', 'oat': 'yulaf', 'oats': 'yulaf',
    'barley': 'arpa', 'rye': 'cavdar', 'corn': 'misir',
    'maize': 'misir', 'semolina': 'irmik',
    // Seker turleri
    'glucose': 'glikoz', 'fructose': 'fruktoz', 'maltose': 'maltoz',
    'glucose syrup': 'glikoz surubu', 'corn syrup': 'misir surubu',
    'honey': 'bal', 'maple syrup': 'akcaagac surubu',
    'molasses': 'melás', 'treacle': 'pekmez', 'invert sugar': 'invert seker',
    'caramel': 'karamel', 'brown sugar': 'kahverengi seker',
    'icing sugar': 'pudra sekeri', 'caster sugar': 'ince seker',
    // Asitler ve koruyucular
    'citric acid': 'sitrik asit', 'lactic acid': 'laktik asit',
    'acetic acid': 'asetik asit', 'ascorbic acid': 'c vitamini',
    'tartaric acid': 'tartarik asit', 'malic acid': 'malik asit',
    'phosphoric acid': 'fosforik asit', 'sorbic acid': 'sorbik asit',
    'benzoic acid': 'benzoik asit',
    // Emulgatörler
    'lecithin': 'lesitim', 'soy lecithin': 'soya lesitini',
    'sunflower lecithin': 'aycicek lesitini',
    'mono and diglycerides': 'mono ve digliseridler',
    'mono- and diglycerides': 'mono ve digliseridler',
    // Aromalar
    'natural flavor': 'dogal aroma', 'natural flavors': 'dogal aromalar',
    'artificial flavor': 'yapay aroma', 'vanilla flavor': 'vanilya aromasi',
    'flavor': 'aroma', 'flavoring': 'aroma maddesi',
    'vanilla': 'vanilya', 'vanilla extract': 'vanilya ekstre',
    'vanillin': 'vanilin',
    // Bitkiler ve baharatlar
    'tomato': 'domates', 'tomato paste': 'domates salcasi',
    'onion': 'sogan', 'garlic': 'sarimsak', 'pepper': 'biber',
    'black pepper': 'karabiber', 'white pepper': 'beyaz biber',
    'paprika': 'kirmizi biber', 'cumin': 'kimyon', 'oregano': 'kekik',
    'thyme': 'kekik', 'rosemary': 'biberiye', 'basil': 'fesleyen',
    'cinnamon': 'tarcin', 'ginger': 'zencefil', 'turmeric': 'zerdeçal',
    'coriander': 'kisnis', 'cardamom': 'kakule', 'clove': 'karanfil',
    'nutmeg': 'muskat', 'bay leaf': 'defne yapragi',
    // Proteinler
    'soy protein': 'soya proteini', 'wheat protein': 'bugday proteini',
    'whey protein': 'peynir alti suyu proteini', 'protein': 'protein',
    'gluten': 'gluten', 'soy': 'soya', 'soybean': 'soya fasulyesi',
    // Vitaminler ve mineraller
    'vitamin c': 'c vitamini', 'vitamin e': 'e vitamini',
    'vitamin d': 'd vitamini', 'vitamin b': 'b vitamini',
    'calcium': 'kalsiyum', 'iron': 'demir', 'zinc': 'cinko',
    'magnesium': 'magnezyum', 'potassium': 'potasyum',
    'sodium': 'sodyum', 'phosphorus': 'fosfor',
    // Diger
    'yeast': 'maya', 'baking powder': 'kabartma tozu',
    'baking soda': 'karbonat', 'gelatin': 'jelatin',
    'pectin': 'pektin', 'carrageenan': 'karragenan',
    'agar': 'agar', 'xanthan gum': 'ksantan sakizi',
    'guar gum': 'guar sakizi', 'locust bean gum': 'keciboynuzu sakizi',
    'fiber': 'lif', 'inulin': 'inulin',
    'coloring': 'renklendirici', 'colour': 'renklendirici',
    'color': 'renklendirici', 'dye': 'boya',
    'preservative': 'koruyucu', 'antioxidant': 'antioksidan',
    'stabilizer': 'stabilizator', 'emulsifier': 'emulgatör',
    'thickener': 'kalinlastirici', 'sweetener': 'tatlandirici',
    'acidity regulator': 'asitlik duzenleyici',
    'raising agent': 'kabartici', 'humectant': 'nemlendirici',
    // Baglaçlar
    'and': 've', 'or': 'veya', 'with': 'ile',
    'contains': 'icerir', 'may contain': 'iz miktarda icerebilir',
    'traces of': 'iz miktarda', 'from': 'kaynakli',
  };

  String result = ingredients.toLowerCase();
  translations.forEach((en, tr) {
    result = result.replaceAll(en, tr);
  });

  // Ilk harfi buyut
  if (result.isNotEmpty) {
    result = result[0].toUpperCase() + result.substring(1);
  }
  return result;
}

class FoodApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';

  // Once Firestore'daki Turk urunlerine bak
  static Future<ProductModel?> getTurkishProduct(String barcode) async {
    try {
      final doc = await FirebaseFirestore.instance
        .collection('turkish_products')
        .doc(barcode)
        .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final nutrients = data['nutrients'] as Map<String, dynamic>?;
        return ProductModel(
          barcode: barcode,
          name: data['name'] ?? '',
          brand: data['brand'],
          ingredients: data['ingredients'],
          nutrients: nutrients != null ? {
            'energy': nutrients['energy'],
            'sugars': nutrients['sugars'],
            'fat': nutrients['fat'],
            'salt': nutrients['salt'],
            'protein': nutrients['protein'],
            'fiber': nutrients['fiber'],
            'carbohydrates': nutrients['carbohydrates'],
          } : null,
          allergens: List<String>.from(data['allergens'] ?? []),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ProductModel?> getProductByBarcode(String barcode) async {
    // Once Turk urunleri veritabanina bak
    final turkishProduct = await getTurkishProduct(barcode);
    if (turkishProduct != null) return turkishProduct;
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

  // AI Model ile analiz et
  static Future<Map<String, dynamic>?> analyzeWithAI(ProductModel product) async {
    try {
      final url = Uri.parse('https://congenial-sniffle-jrjwxwvx67xfr9p-8000.app.github.dev/analyze');
      // Kullanici tercihlerini Firestore'dan getir
      List<String> userAllergens = [];
      String? userDiet;
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final doc = await FirebaseFirestore.instance
            .collection('users').doc(uid)
            .collection('profile').doc('preferences')
            .get();
          if (doc.exists) {
            userAllergens = List<String>.from(doc.data()?['allergies'] ?? []);
            userDiet = doc.data()?['dietType'];
          }
        }
      } catch (e) {}

      final body = {
        'name': product.name,
        'ingredients': product.ingredients ?? '',
        'sugar_100g': (product.nutrients?['sugars'] ?? 0).toDouble(),
        'fat_100g': (product.nutrients?['fat'] ?? 0).toDouble(),
        'salt_100g': (product.nutrients?['salt'] ?? 0).toDouble(),
        'protein_100g': (product.nutrients?['protein'] ?? 0).toDouble(),
        'fiber_100g': (product.nutrients?['fiber'] ?? 0).toDouble(),
        'energy_100g': (product.nutrients?['energy'] ?? 0).toDouble(),
        'nova_group': 4,
        'allergens': product.allergens,
        'user_allergens': userAllergens,
        'user_diet': userDiet ?? '',
      };
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
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