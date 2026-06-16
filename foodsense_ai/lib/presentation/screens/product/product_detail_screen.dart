import 'package:flutter/material.dart';
import '../../../data/services/food_api_service.dart';
import '../../widgets/common/app_logo.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  bool _isLoading = true;
  bool _isAnalyzing = false;
  String? _error;
  Map<String, dynamic>? _aiResult;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final barcode = ModalRoute.of(context)?.settings.arguments as String?;
    if (barcode != null) _loadProduct(barcode);
  }

  Future<void> _loadProduct(String barcode) async {
    setState(() { _isLoading = true; _error = null; });
    final product = await FoodApiService.getProductByBarcode(barcode);
    if (mounted) {
      setState(() {
        _product = product;
        _isLoading = false;
        if (product == null) _error = 'Urun bulunamadi. Barkod: $barcode';
      });
      // Urun bulununca otomatik AI analizi yap
      if (product != null) _analyzeWithAI();
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_product == null) return;
    setState(() => _isAnalyzing = true);
    final result = await FoodApiService.analyzeWithAI(_product!);
    if (mounted) setState(() { _aiResult = result; _isAnalyzing = false; });
  }

  Color _getScoreColor(int score) {
    if (score >= 65) return const Color(0xFF2E7D32);
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: const SafeArea(
                  child: Center(child: AppLogo(size: 40)),
                ),
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    SizedBox(height: 16),
                    Text('Urun bilgileri yukleniyor...'),
                  ],
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('😕', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      const Text('Urun Bulunamadi',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_error!, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Tekrar Tara'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_product != null)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Urun Baslik
                  _buildProductHeader(),
                  const SizedBox(height: 16),

                  // AI Analiz Sonucu
                  if (_isAnalyzing)
                    _buildAnalyzingCard()
                  else if (_aiResult != null)
                    _buildAIResultCard()
                  else
                    _buildAnalyzeButton(),

                  const SizedBox(height: 16),

                  // Alerjenler
                  if (_product!.allergens.isNotEmpty)
                    _buildAllergenCard(),
                  if (_product!.allergens.isNotEmpty) const SizedBox(height: 16),

                  // Besin Degerleri
                  if (_product!.nutrients != null)
                    _buildNutrientsCard(),
                  if (_product!.nutrients != null) const SizedBox(height: 16),

                  // Icerik Listesi
                  if (_product!.ingredients != null)
                    _buildIngredientsCard(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _product!.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _product!.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                      const Center(child: Text('🛒', style: TextStyle(fontSize: 36))),
                  ),
                )
              : const Center(child: Text('🛒', style: TextStyle(fontSize: 36))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_product!.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (_product!.brand != null) ...[
                  const SizedBox(height: 4),
                  Text(_product!.brand!,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '# ${_product!.barcode}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Color(0xFF2E7D32)),
          const SizedBox(height: 16),
          const Text('🤖 AI Modeli Analiz Ediyor...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Makine ogrenimi ile saglik skoru hesaplaniyor',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton.icon(
      onPressed: _analyzeWithAI,
      icon: const Text('🤖', style: TextStyle(fontSize: 20)),
      label: const Text('AI ile Analiz Et',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildAIResultCard() {
    final score = _aiResult!['health_score'] as int;
    final label = _aiResult!['category_label'] as String;
    final warnings = List<String>.from(_aiResult!['warnings'] ?? []);
    final positives = List<String>.from(_aiResult!['positives'] ?? []);
    final suggestions = List<String>.from(_aiResult!['suggestions'] ?? []);
    final additives = List<Map<String, dynamic>>.from(
      (_aiResult!['detected_additives'] ?? []).map((e) => Map<String, dynamic>.from(e)));
    final color = _getScoreColor(score);

    return Column(
      children: [
        // Skor karti
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text('AI Saglik Analizi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(label,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Dairesel skor
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120, height: 120,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                    ),
                  ),
                  Column(
                    children: [
                      Text('$score',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color)),
                      Text('/100', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(_aiResult!['summary'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Uyarilar
        if (warnings.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('⚠️', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Uyarilar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                ...warnings.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_rounded, color: Colors.red.shade400, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(w, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        if (warnings.isNotEmpty) const SizedBox(height: 12),

        // Pozitifler
        if (positives.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('✅', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Olumlu Ozellikler',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                ...positives.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade400, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(p, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        if (positives.isNotEmpty) const SizedBox(height: 12),

        // Katki maddeleri
        if (additives.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🧪', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Katki Maddeleri',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                ...additives.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: a['risk'] == 'yuksek'
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(a['code'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: a['risk'] == 'yuksek'
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
                          )),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(a['description'] ?? '',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        if (additives.isNotEmpty) const SizedBox(height: 12),

        // Oneriler
        if (suggestions.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Oneriler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                ...suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('→', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(s, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAllergenCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Alerjenler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _product!.allergens.map((a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(a, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Besin Degerleri (100g)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            ('🔥 Enerji', '${_product!.nutrients!['energy']?.toStringAsFixed(0) ?? '-'} kcal'),
            ('🥩 Protein', '${_product!.nutrients!['protein']?.toStringAsFixed(1) ?? '-'} g'),
            ('🍞 Karbonhidrat', '${_product!.nutrients!['carbohydrates']?.toStringAsFixed(1) ?? '-'} g'),
            ('🍬 Seker', '${_product!.nutrients!['sugars']?.toStringAsFixed(1) ?? '-'} g'),
            ('🧈 Yag', '${_product!.nutrients!['fat']?.toStringAsFixed(1) ?? '-'} g'),
            ('🌿 Lif', '${_product!.nutrients!['fiber']?.toStringAsFixed(1) ?? '-'} g'),
            ('🧂 Tuz', '${_product!.nutrients!['salt']?.toStringAsFixed(2) ?? '-'} g'),
          ].map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 14)),
                Text(item.$2,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📋', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Icerik Listesi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_product!.ingredients!,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }
}