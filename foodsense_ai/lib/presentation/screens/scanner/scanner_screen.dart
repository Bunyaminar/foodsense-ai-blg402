import 'package:flutter/material.dart';
import '../../widgets/common/app_logo.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _manualController = TextEditingController();
  String _searchQuery = '';

  // 50 örnek ürün
  final List<Map<String, dynamic>> _allProducts = [
    // Global İçecekler
    {'emoji': '🥤', 'name': 'Coca Cola', 'barcode': '5449000000996', 'color': 0xFFE53935, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Pepsi', 'barcode': '5449000214911', 'color': 0xFF1565C0, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Fanta', 'barcode': '5010477348735', 'color': 0xFFFF6F00, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Sprite', 'barcode': '5449000054227', 'color': 0xFF2E7D32, 'category': 'İçecek'},
    {'emoji': '⚡', 'name': 'Red Bull', 'barcode': '9002490100070', 'color': 0xFF424242, 'category': 'İçecek'},
    {'emoji': '🧃', 'name': 'Minute Maid', 'barcode': '5449000133328', 'color': 0xFFFF8F00, 'category': 'İçecek'},
    {'emoji': '💧', 'name': 'Evian Su', 'barcode': '3068320109843', 'color': 0xFF0288D1, 'category': 'İçecek'},
    {'emoji': '🥛', 'name': 'Nestle Sut', 'barcode': '7613034626844', 'color': 0xFF1565C0, 'category': 'Sut'},

    // Çikolata & Tatlı
    {'emoji': '🍫', 'name': 'Nutella', 'barcode': '3017620422003', 'color': 0xFF4E342E, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Milka', 'barcode': '7622210016522', 'color': 0xFF7B1FA2, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Snickers', 'barcode': '5000159461122', 'color': 0xFF4E342E, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Twix', 'barcode': '5000159472005', 'color': 0xFFFF8F00, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'KitKat', 'barcode': '7613035518209', 'color': 0xFFE53935, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Bounty', 'barcode': '5000159461177', 'color': 0xFF4E342E, 'category': 'Tatli'},
    {'emoji': '🍭', 'name': 'Haribo', 'barcode': '4001686325988', 'color': 0xFFFFD600, 'category': 'Tatli'},
    {'emoji': '🍪', 'name': 'Oreo', 'barcode': '7622210449283', 'color': 0xFF212121, 'category': 'Tatli'},

    // Cips & Atıştırmalık
    {'emoji': '🍟', 'name': 'Pringles', 'barcode': '5053990108812', 'color': 0xFFE53935, 'category': 'Atistirmalik'},
    {'emoji': '🍟', 'name': 'Lays', 'barcode': '4890008100309', 'color': 0xFFFFD600, 'category': 'Atistirmalik'},
    {'emoji': '🍿', 'name': 'Cheetos', 'barcode': '8710398513014', 'color': 0xFFFF6F00, 'category': 'Atistirmalik'},
    {'emoji': '🥨', 'name': 'Ritz', 'barcode': '7622210052322', 'color': 0xFFFF8F00, 'category': 'Atistirmalik'},
    {'emoji': '🍪', 'name': 'Digestive', 'barcode': '5000168201118', 'color': 0xFF795548, 'category': 'Atistirmalik'},

    // Kahvaltılık
    {'emoji': '🥣', 'name': 'Cornflakes', 'barcode': '5053827148865', 'color': 0xFFFF8F00, 'category': 'Kahvaltilik'},
    {'emoji': '🥣', 'name': 'Nesquik', 'barcode': '7613034056245', 'color': 0xFF6A1B9A, 'category': 'Kahvaltilik'},
    {'emoji': '🍯', 'name': 'Nutella Mini', 'barcode': '3017620425035', 'color': 0xFF4E342E, 'category': 'Kahvaltilik'},

    // Türk Ürünleri
    {'emoji': '🍪', 'name': 'Eti Cin', 'barcode': '8690526790033', 'color': 0xFF2E7D32, 'category': 'Turk'},
    {'emoji': '🍫', 'name': 'Eti Browni', 'barcode': '8690526636762', 'color': 0xFF4E342E, 'category': 'Turk'},
    {'emoji': '🍫', 'name': 'Eti Tutku', 'barcode': '8690526082458', 'color': 0xFF880E4F, 'category': 'Turk'},
    {'emoji': '🍪', 'name': 'Ulker Biskuvi', 'barcode': '8690504015727', 'color': 0xFF1565C0, 'category': 'Turk'},
    {'emoji': '🍫', 'name': 'Ulker Cikolata', 'barcode': '8690504151027', 'color': 0xFF4E342E, 'category': 'Turk'},
    {'emoji': '🥛', 'name': 'Pinar Sut', 'barcode': '8690632050144', 'color': 0xFF0288D1, 'category': 'Turk'},
    {'emoji': '🧀', 'name': 'Pinar Kasar', 'barcode': '8690632078017', 'color': 0xFFFF8F00, 'category': 'Turk'},
    {'emoji': '🥛', 'name': 'Sutas Yogurt', 'barcode': '8690632145016', 'color': 0xFF0288D1, 'category': 'Turk'},
    {'emoji': '🍵', 'name': 'Lipton Cay', 'barcode': '8714100919316', 'color': 0xFF2E7D32, 'category': 'Turk'},
    {'emoji': '☕', 'name': 'Nescafe', 'barcode': '7613035469488', 'color': 0xFF4E342E, 'category': 'Turk'},
    {'emoji': '🍟', 'name': 'Eti Cips', 'barcode': '8690526013544', 'color': 0xFFFF8F00, 'category': 'Turk'},
    {'emoji': '🥤', 'name': 'Uludag Gazoz', 'barcode': '8690514001043', 'color': 0xFF1565C0, 'category': 'Turk'},
    {'emoji': '🧆', 'name': 'Torku Helva', 'barcode': '8690526510017', 'color': 0xFFFF8F00, 'category': 'Turk'},
    {'emoji': '🍫', 'name': 'Caykur Cay', 'barcode': '8690627010019', 'color': 0xFF2E7D32, 'category': 'Turk'},

    // Sağlıklı
    {'emoji': '🥣', 'name': 'Quaker Yulaf', 'barcode': '8710398100078', 'color': 0xFF795548, 'category': 'Saglikli'},
    {'emoji': '🌾', 'name': 'Special K', 'barcode': '5053827072023', 'color': 0xFFE53935, 'category': 'Saglikli'},
    {'emoji': '🥜', 'name': 'Nature Valley', 'barcode': '0016000275171', 'color': 0xFF795548, 'category': 'Saglikli'},
    {'emoji': '🍓', 'name': 'Activia', 'barcode': '3228857000166', 'color': 0xFF2E7D32, 'category': 'Saglikli'},
    {'emoji': '🥛', 'name': 'Alpro Soya', 'barcode': '5411188108085', 'color': 0xFF2E7D32, 'category': 'Saglikli'},

    // Soslar & Diğer
    {'emoji': '🍅', 'name': 'Heinz Ketcap', 'barcode': '0013000006408', 'color': 0xFFE53935, 'category': 'Sos'},
    {'emoji': '🧴', 'name': 'Hellmanns Mayo', 'barcode': '8711200364824', 'color': 0xFFFFD600, 'category': 'Sos'},
    {'emoji': '🫙', 'name': 'Skippy Fistik Ezmesi', 'barcode': '0037600103336', 'color': 0xFFFF8F00, 'category': 'Sos'},
    {'emoji': '🍝', 'name': 'Barilla Makarna', 'barcode': '8076802085738', 'color': 0xFF1565C0, 'category': 'Diger'},
    {'emoji': '🍚', 'name': 'Uncle Bens Pirinc', 'barcode': '5010034000287', 'color': 0xFFFF8F00, 'category': 'Diger'},
  ];

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_searchQuery.isEmpty) return _allProducts;
    return _allProducts.where((p) =>
      p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
      p['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _navigateToDetail(String barcode) {
    Navigator.pushNamed(context, '/product-detail', arguments: barcode);
  }

  void _submitManual() {
    final code = _manualController.text.trim();
    if (code.isEmpty) return;
    _navigateToDetail(code);
  }

  // Kategoriye göre grupla
  Map<String, List<Map<String, dynamic>>> get _groupedProducts {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final product in _filteredProducts) {
      final category = product['category'] as String;
      groups.putIfAbsent(category, () => []);
      groups[category]!.add(product);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, primary.withValues(alpha: 0.7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const AppLogo(size: 32),
                    const Spacer(),
                    Text('${_allProducts.length} Urun',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12)),
                  ],
                ),
              ),

              // İkon ve başlık
              const Text('📷', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text('Urun Tarayici',
                style: TextStyle(color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Barkod gir veya listeden sec',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13)),
              const SizedBox(height: 16),

              // Alt panel
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Manuel giriş
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _manualController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Barkod numarasi girin...',
                                      prefixIcon: const Icon(Icons.qr_code),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onSubmitted: (_) => _submitManual(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _submitManual,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Icon(Icons.search),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Arama
                            TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Urun ara (Coca Cola, Turk...)',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Ürün listesi
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _groupedProducts.length,
                          itemBuilder: (context, groupIndex) {
                            final category = _groupedProducts.keys.elementAt(groupIndex);
                            final products = _groupedProducts[category]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(category,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    )),
                                ),
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 2.8,
                                  children: products.map((p) =>
                                    _buildProductChip(
                                      p['emoji'], p['name'],
                                      p['barcode'], Color(p['color']))).toList(),
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductChip(String emoji, String name, String barcode, Color color) {
    return GestureDetector(
      onTap: () => _navigateToDetail(barcode),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Center(child: Text(emoji,
                style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 11),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
            ),
            Icon(Icons.chevron_right,
              size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}