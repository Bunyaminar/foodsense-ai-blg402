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
  String? _error;
  int? _healthScore;

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
        if (product != null) {
          _healthScore = FoodApiService.calculateHealthScore(product);
        } else {
          _error = 'Urun bulunamadi. Barkod: $barcode';
        }
      });
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 70) return const Color(0xFF2E7D32);
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 70) return 'Saglikli';
    if (score >= 40) return 'Orta';
    return 'Dikkatli Ol';
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
                    Text('Urun bilgileri yukleniliyor...'),
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

                  // Urun Baslik Karti
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8)],
                    ),
                    child: Row(
                      children: [
                        // Urun resmi
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
                              Text(
                                _product!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_product!.brand != null) ...[
                                const SizedBox(height: 4),
                                Text(_product!.brand!,
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '# ${_product!.barcode}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF2E7D32),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Saglik Skoru
                  if (_healthScore != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          const Text('Saglik Skoru',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120, height: 120,
                                child: CircularProgressIndicator(
                                  value: _healthScore! / 100,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey.shade200,
                                  color: _getScoreColor(_healthScore!),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$_healthScore',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: _getScoreColor(_healthScore!),
                                    ),
                                  ),
                                  Text(
                                    _getScoreLabel(_healthScore!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getScoreColor(_healthScore!),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Alerjenler
                  if (_product!.allergens.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('⚠️', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text('Alerjenler',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _product!.allergens.map((allergen) =>
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(allergen,
                                  style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  if (_product!.allergens.isNotEmpty) const SizedBox(height: 16),

                  // Besin Degerleri
                  if (_product!.nutrients != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)],
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
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  )),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Icerik listesi
                  if (_product!.ingredients != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)],
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
                          Text(
                            _product!.ingredients!,
                            style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}