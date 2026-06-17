import 'package:flutter/material.dart';
import '../../../data/services/food_api_service.dart';
import '../../widgets/common/app_logo.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _manualController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allProducts = [
    // İçecekler
    {'emoji': '🥤', 'name': 'Coca Cola', 'barcode': '5449000000996', 'color': 0xFFE53935, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Pepsi', 'barcode': '5449000214911', 'color': 0xFF1565C0, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Fanta Portakal', 'barcode': '5010477348735', 'color': 0xFFFF6F00, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Sprite', 'barcode': '5449000054227', 'color': 0xFF2E7D32, 'category': 'İçecek'},
    {'emoji': '⚡', 'name': 'Red Bull', 'barcode': '9002490100070', 'color': 0xFF424242, 'category': 'İçecek'},
    {'emoji': '🧃', 'name': 'Lipton Ice Tea', 'barcode': '8714100919316', 'color': 0xFFFF8F00, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Uludag Gazoz', 'barcode': '8690514001043', 'color': 0xFF1565C0, 'category': 'İçecek'},
    {'emoji': '☕', 'name': 'Nescafe Classic', 'barcode': '8690626010010', 'color': 0xFF4E342E, 'category': 'İçecek'},
    {'emoji': '🍵', 'name': 'Caykur Rize Cay', 'barcode': '8690627010019', 'color': 0xFF2E7D32, 'category': 'İçecek'},
    // Süt Ürünleri
    {'emoji': '🥛', 'name': 'Pinar Sut', 'barcode': '8690632050144', 'color': 0xFF0288D1, 'category': 'Süt'},
    {'emoji': '🥛', 'name': 'Sutas Sut', 'barcode': '8690632001015', 'color': 0xFF0288D1, 'category': 'Süt'},
    {'emoji': '🍶', 'name': 'Sutas Yogurt', 'barcode': '8690632145016', 'color': 0xFF0288D1, 'category': 'Süt'},
    {'emoji': '🧀', 'name': 'Pinar Kasar', 'barcode': '8690632078017', 'color': 0xFFFF8F00, 'category': 'Süt'},
    {'emoji': '🥛', 'name': 'Pinar Ayran', 'barcode': '8690632055003', 'color': 0xFF0288D1, 'category': 'Süt'},
    {'emoji': '🍦', 'name': 'Pinar Kaymak', 'barcode': '8690632088016', 'color': 0xFFFF8F00, 'category': 'Süt'},
    {'emoji': '🌱', 'name': 'Alpro Soya Sutu', 'barcode': '5411188108085', 'color': 0xFF2E7D32, 'category': 'Süt'},
    // Çikolata & Tatlı
    {'emoji': '🍫', 'name': 'Nutella', 'barcode': '3017620422003', 'color': 0xFF4E342E, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Milka Cikolata', 'barcode': '7622210016522', 'color': 0xFF7B1FA2, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Snickers', 'barcode': '5000159461122', 'color': 0xFF4E342E, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Twix', 'barcode': '5000159472005', 'color': 0xFFFF8F00, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Kit Kat', 'barcode': '7613035518209', 'color': 0xFFE53935, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Kinder Bueno', 'barcode': '8000500310427', 'color': 0xFF4E342E, 'category': 'Tatli'},
    {'emoji': '🍭', 'name': 'Haribo Ayicik', 'barcode': '4001686325988', 'color': 0xFFFFD600, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Eti Browni', 'barcode': '8690526636762', 'color': 0xFF4E342E, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Eti Tutku', 'barcode': '8690526082458', 'color': 0xFF880E4F, 'category': 'Tatli'},
    {'emoji': '🍫', 'name': 'Ulker Cikolata', 'barcode': '8690504151027', 'color': 0xFF4E342E, 'category': 'Tatli'},
    {'emoji': '🍯', 'name': 'Torku Findik Krema', 'barcode': '8690526510017', 'color': 0xFFFF8F00, 'category': 'Tatli'},
    {'emoji': '🍰', 'name': 'Eti Karam', 'barcode': '8690526155025', 'color': 0xFFFF8F00, 'category': 'Tatli'},
    {'emoji': '🍬', 'name': 'Eti Puf', 'barcode': '8690526165048', 'color': 0xFFE91E63, 'category': 'Tatli'},
    {'emoji': '🍰', 'name': 'Ulker Dankek', 'barcode': '8690504099701', 'color': 0xFF4E342E, 'category': 'Tatli'},
    {'emoji': '🍪', 'name': 'Ulker Choco Pie', 'barcode': '8690504023142', 'color': 0xFF4E342E, 'category': 'Tatli'},
    // Biskuvi
    {'emoji': '🍪', 'name': 'Eti Cin', 'barcode': '8690526790033', 'color': 0xFF2E7D32, 'category': 'Biskuvi'},
    {'emoji': '🍪', 'name': 'Ulker Biskuvi', 'barcode': '8690504015727', 'color': 0xFF1565C0, 'category': 'Biskuvi'},
    {'emoji': '🍪', 'name': 'Ulker Hanımeller', 'barcode': '8690504016427', 'color': 0xFF7B1FA2, 'category': 'Biskuvi'},
    {'emoji': '🍪', 'name': 'Oreo', 'barcode': '7622210449283', 'color': 0xFF212121, 'category': 'Biskuvi'},
    {'emoji': '🍪', 'name': 'Ulker Dido', 'barcode': '8690769030019', 'color': 0xFF4E342E, 'category': 'Biskuvi'},
    {'emoji': '🍪', 'name': 'Eti Burcak', 'barcode': '8690526610007', 'color': 0xFFFF8F00, 'category': 'Biskuvi'},
    {'emoji': '🍪', 'name': 'McVities Digestive', 'barcode': '5000168201118', 'color': 0xFF795548, 'category': 'Biskuvi'},
    {'emoji': '🥨', 'name': 'Eti Crax Kraker', 'barcode': '8690526195014', 'color': 0xFFFF8F00, 'category': 'Biskuvi'},
    // Atıştırmalık
    {'emoji': '🍟', 'name': 'Pringles', 'barcode': '5053990108812', 'color': 0xFFE53935, 'category': 'Atıştırmalık'},
    {'emoji': '🍟', 'name': 'Lays', 'barcode': '4890008100309', 'color': 0xFFFFD600, 'category': 'Atıştırmalık'},
    {'emoji': '🍟', 'name': 'Eti Cips', 'barcode': '8690526013544', 'color': 0xFFFF8F00, 'category': 'Atıştırmalık'},
    // Kahvaltılık & Tahıl
    {'emoji': '🥣', 'name': 'Quaker Yulaf', 'barcode': '8710398100078', 'color': 0xFF795548, 'category': 'Saglikli'},
    {'emoji': '🥣', 'name': 'Cornflakes', 'barcode': '5053827148865', 'color': 0xFFFF8F00, 'category': 'Saglikli'},
    {'emoji': '🥣', 'name': 'Nestle Fitness', 'barcode': '7613036251471', 'color': 0xFFE53935, 'category': 'Saglikli'},
    {'emoji': '🍝', 'name': 'Barilla Spagetti', 'barcode': '8076802085738', 'color': 0xFF1565C0, 'category': 'Saglikli'},
    {'emoji': '🧘', 'name': 'Activia Yogurt', 'barcode': '3228857000166', 'color': 0xFF2E7D32, 'category': 'Saglikli'},
    // Sos
    {'emoji': '🍅', 'name': 'Heinz Ketcap', 'barcode': '0013000006408', 'color': 0xFFE53935, 'category': 'Sos'},
    {'emoji': '🍫', 'name': 'Ulker Kremali', 'barcode': '8690769050023', 'color': 0xFF4E342E, 'category': 'Tatli'},
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

  Map<String, List<Map<String, dynamic>>> get _groupedProducts {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final product in _filteredProducts) {
      final category = product['category'] as String;
      groups.putIfAbsent(category, () => []);
      groups[category]!.add(product);
    }
    return groups;
  }

  void _navigateToDetail(String barcode) {
    Navigator.pushNamed(context, '/product-detail', arguments: barcode);
  }

  void _submitManual() {
    final code = _manualController.text.trim();
    if (code.isEmpty) return;
    _navigateToDetail(code);
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
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                  ],
                ),
              ),
              const Text('📷', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text('Urun Tarayici',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Barkod gir veya listeden sec',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              const SizedBox(height: 16),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Icon(Icons.search),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Urun ara...',
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
                                      fontSize: 13, fontWeight: FontWeight.bold, color: primary)),
                                ),
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 2.8,
                                  children: products.map((p) =>
                                    _buildProductChip(p['emoji'], p['name'], p['barcode'], Color(p['color']))).toList(),
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
            Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
