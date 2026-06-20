import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/food_api_service.dart';
import '../../../data/services/favorites_service.dart';
import '../../../data/services/history_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  ProductModel? _product;
  bool _isLoading = true;
  bool _isAnalyzing = false;
  String? _error;
  Map<String, dynamic>? _aiResult;
  bool _isFavorite = false;

  late AnimationController _scoreController;
  late Animation<double> _scoreAnim;
  late AnimationController _heartController;
  late Animation<double> _heartAnim;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));
    _scoreAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOut));
    _heartController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
    _heartAnim = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final barcode = ModalRoute.of(context)?.settings.arguments as String?;
    if (barcode != null && _product == null) _loadProduct(barcode);
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
      if (product != null) {
        _checkFavorite();
        _analyzeWithAI();
      }
    }
  }

  Future<void> _checkFavorite() async {
    if (_product == null) return;
    final isFav = await FavoritesService.isFavorite(_product!.barcode);
    if (mounted) setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    if (_product == null) return;
    _heartController.forward().then((_) => _heartController.reverse());
    if (_isFavorite) {
      await FavoritesService.removeFavorite(_product!.barcode);
      setState(() => _isFavorite = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Favorilerden kaldirildi', style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    } else {
      final score = _aiResult?['health_score'] as int?;
      await FavoritesService.addFavorite(_product!, healthScore: score);
      setState(() => _isFavorite = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Favorilere eklendi!', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_product == null) return;
    setState(() => _isAnalyzing = true);
    final result = await FoodApiService.analyzeWithAI(_product!);
    if (mounted) {
      setState(() { _aiResult = result; _isAnalyzing = false; });
      if (result != null) {
        _scoreController.forward(from: 0);
        await HistoryService.saveAnalysis(
          barcode: _product!.barcode,
          productName: _product!.name,
          brand: _product!.brand,
          imageUrl: _product!.imageUrl,
          healthScore: result['health_score'] as int,
          category: result['category'] as String,
          warnings: List<String>.from(result['warnings'] ?? []),
          positives: List<String>.from(result['positives'] ?? []),
        );
      }
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 65) return const Color(0xFF2E7D32);
    if (score >= 40) return const Color(0xFFFF8F00);
    return const Color(0xFFE53935);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1B1B1B),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('FoodsenseAI',
              style: GoogleFonts.poppins(
                color: primary, fontSize: 16, fontWeight: FontWeight.bold)),
            actions: [
              if (_product != null)
                ScaleTransition(
                  scale: _heartAnim,
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.red : Colors.grey),
                    onPressed: _toggleFavorite,
                  ),
                ),
              IconButton(
                icon: Icon(Icons.settings_outlined, color: Colors.grey.shade400),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Urun Bulunamadi',
                        style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: Text('Geri Don', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

                  // Urun baslik
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80, height: 80,
                            color: Colors.grey.shade100,
                            child: _product!.imageUrl != null
                              ? Image.network(_product!.imageUrl!, fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                    const Center(child: Text('🛒', style: TextStyle(fontSize: 36))))
                              : const Center(child: Text('🛒', style: TextStyle(fontSize: 36))),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_product!.brand != null)
                                Text(_product!.brand!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade500, fontSize: 12)),
                              Text(_product!.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 16, height: 1.3)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6, runSpacing: 4,
                                children: [
                                  if (_product!.allergens.isNotEmpty)
                                    _chip('Alerjen Icerebilir',
                                      Colors.red.shade100, Colors.red.shade700),
                                  if (_aiResult != null)
                                    _chip(
                                      _aiResult!['category_label'] ?? '',
                                      _aiResult!['category'] == 'healthy'
                                        ? Colors.green.shade100
                                        : _aiResult!['category'] == 'medium'
                                          ? Colors.orange.shade100
                                          : Colors.red.shade100,
                                      _aiResult!['category'] == 'healthy'
                                        ? Colors.green.shade700
                                        : _aiResult!['category'] == 'medium'
                                          ? Colors.orange.shade700
                                          : Colors.red.shade700),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // AI Saglik Puani
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                    child: _isAnalyzing
                      ? Column(children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text('AI Analiz Ediliyor...',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        ])
                      : _aiResult != null
                        ? Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('AI Saglik Puani',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Bu urun besin degerleri acisindan ${_aiResult!['health_score'] >= 65 ? "oldukca dengeli" : _aiResult!['health_score'] >= 40 ? "orta duzeyde" : "dikkat gerektiriyor"}.',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              AnimatedBuilder(
                                animation: _scoreAnim,
                                builder: (context, child) {
                                  final score = _aiResult!['health_score'] as int;
                                  final color = _getScoreColor(score);
                                  return SizedBox(
                                    width: 72, height: 72,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: _scoreAnim.value * score / 100,
                                          strokeWidth: 7,
                                          backgroundColor: Colors.grey.shade200,
                                          color: color,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('${(score * _scoreAnim.value).toInt()}',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18, color: color)),
                                            Text('/100',
                                              style: GoogleFonts.poppins(
                                                fontSize: 9, color: Colors.grey.shade400)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        : ElevatedButton.icon(
                            onPressed: _analyzeWithAI,
                            icon: const Icon(Icons.analytics_rounded),
                            label: Text('AI ile Analiz Et',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                          ),
                  ),
                  const SizedBox(height: 12),

                  if (_aiResult != null) ...[
                    if ((_aiResult!['warnings'] as List).isNotEmpty) ...[
                      _resultCard(
                        title: 'Dikkat Edilmesi Gerekenler',
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFE53935),
                        bgColor: const Color(0xFFFFF3F3),
                        items: List<String>.from(_aiResult!['warnings'])),
                      const SizedBox(height: 12),
                    ],

                    if ((_aiResult!['positives'] as List).isNotEmpty) ...[
                      _resultCard(
                        title: 'Olumlu Ozellikler',
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF2E7D32),
                        bgColor: const Color(0xFFF3FFF3),
                        items: List<String>.from(_aiResult!['positives'])),
                      const SizedBox(height: 12),
                    ],

                    if ((_aiResult!['detected_additives'] as List).isNotEmpty) ...[
                      _additivesCard(
                        List<Map<String, dynamic>>.from(
                          (_aiResult!['detected_additives'] as List)
                            .map((e) => Map<String, dynamic>.from(e)))),
                      const SizedBox(height: 12),
                    ],
                  ],

                  if (_product!.allergens.isNotEmpty) ...[
                    _allergensCard(),
                    const SizedBox(height: 12),
                  ],

                  if (_product!.nutrients != null) ...[
                    _nutrientsCard(),
                    const SizedBox(height: 12),
                  ],

                  if (_product!.ingredients != null) ...[
                    _ingredientsCard(),
                    const SizedBox(height: 24),
                  ],
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
        style: GoogleFonts.poppins(
          color: text, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _resultCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          ]),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 6, height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Text(item,
                  style: GoogleFonts.poppins(fontSize: 13, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _additivesCard(List<Map<String, dynamic>> additives) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('⚗️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('Katki Maddeleri',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: additives.map((a) {
              final isHigh = a['risk'] == 'yuksek';
              final color = isHigh ? const Color(0xFFE53935) : const Color(0xFFFF8F00);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(a['code'] ?? '',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 12, color: color)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4)),
                      child: Text(isHigh ? 'YUKSEK' : 'ORTA',
                        style: GoogleFonts.poppins(
                          fontSize: 9, color: color, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _allergensCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alerjenler',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _product!.allergens.map((a) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade200)),
              child: Text(a,
                style: GoogleFonts.poppins(
                  color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _nutrientsCard() {
    final n = _product!.nutrients!;
    final rows = [
      ('Enerji', '${n['energy']?.toStringAsFixed(0) ?? '-'} kcal', false),
      ('Yag', '${n['fat']?.toStringAsFixed(1) ?? '-'} g', false),
      ('Karbonhidrat', '${n['carbohydrates']?.toStringAsFixed(1) ?? '-'} g', false),
      ('- Seker', '${n['sugars']?.toStringAsFixed(1) ?? '-'} g', true),
      ('Lif', '${n['fiber']?.toStringAsFixed(1) ?? '-'} g', false),
      ('Protein', '${n['protein']?.toStringAsFixed(1) ?? '-'} g', false),
      ('Tuz', '${n['salt']?.toStringAsFixed(2) ?? '-'} g', false),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Besin Degerleri (100g)',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: rows.asMap().entries.map((entry) {
                final i = entry.key;
                final row = entry.value;
                final isHighSugar = row.$1 == '- Seker' && (n['sugars'] ?? 0) > 10;
                return Container(
                  decoration: BoxDecoration(
                    border: i < rows.length - 1
                      ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                      : null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(row.$1,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: row.$3 ? Colors.grey.shade500 : Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1B1B1B))),
                        Text(row.$2,
                          style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: isHighSugar ? const Color(0xFFE53935) : Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1B1B1B))),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredientsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Icindekiler',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Text(_product!.ingredients!,
            style: GoogleFonts.poppins(
              fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }
}
