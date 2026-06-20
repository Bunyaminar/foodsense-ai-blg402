import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _barcodeController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showCamera = false;
  bool _isScanning = false;
  MobileScannerController? _cameraController;

  final List<Map<String, dynamic>> _allProducts = [
    {'emoji': '🥤', 'name': 'Coca Cola', 'barcode': '5449000000996', 'color': 0xFFE53935, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Pepsi', 'barcode': '5449000214911', 'color': 0xFF1565C0, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Fanta Portakal', 'barcode': '5010477348735', 'color': 0xFFFF6F00, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Sprite', 'barcode': '5449000054227', 'color': 0xFF2E7D32, 'category': 'İçecek'},
    {'emoji': '⚡', 'name': 'Red Bull', 'barcode': '9002490100070', 'color': 0xFF424242, 'category': 'İçecek'},
    {'emoji': '🧃', 'name': 'Lipton Ice Tea', 'barcode': '8714100919316', 'color': 0xFFFF8F00, 'category': 'İçecek'},
    {'emoji': '🥤', 'name': 'Uludag Gazoz', 'barcode': '8690514001043', 'color': 0xFF1565C0, 'category': 'İçecek'},
    {'emoji': '☕', 'name': 'Nescafe', 'barcode': '8690626010010', 'color': 0xFF4E342E, 'category': 'İçecek'},
    {'emoji': '🍵', 'name': 'Caykur Cay', 'barcode': '8690627010019', 'color': 0xFF2E7D32, 'category': 'İçecek'},
    {'emoji': '🥛', 'name': 'Pinar Sut', 'barcode': '8690632050144', 'color': 0xFF0288D1, 'category': 'Süt Ürünleri'},
    {'emoji': '🥛', 'name': 'Sutas Sut', 'barcode': '8690632001015', 'color': 0xFF0288D1, 'category': 'Süt Ürünleri'},
    {'emoji': '🍶', 'name': 'Sutas Yogurt', 'barcode': '8690632145016', 'color': 0xFF0288D1, 'category': 'Süt Ürünleri'},
    {'emoji': '🧀', 'name': 'Pinar Kasar', 'barcode': '8690632078017', 'color': 0xFFFF8F00, 'category': 'Süt Ürünleri'},
    {'emoji': '🥛', 'name': 'Pinar Ayran', 'barcode': '8690632055003', 'color': 0xFF0288D1, 'category': 'Süt Ürünleri'},
    {'emoji': '🌱', 'name': 'Alpro Soya Sutu', 'barcode': '5411188108085', 'color': 0xFF2E7D32, 'category': 'Süt Ürünleri'},
    {'emoji': '🍫', 'name': 'Nutella', 'barcode': '3017620422003', 'color': 0xFF4E342E, 'category': 'Çikolata'},
    {'emoji': '🍫', 'name': 'Milka', 'barcode': '7622210016522', 'color': 0xFF7B1FA2, 'category': 'Çikolata'},
    {'emoji': '🍫', 'name': 'Snickers', 'barcode': '5000159461122', 'color': 0xFF4E342E, 'category': 'Çikolata'},
    {'emoji': '🍫', 'name': 'Twix', 'barcode': '5000159472005', 'color': 0xFFFF8F00, 'category': 'Çikolata'},
    {'emoji': '🍫', 'name': 'Kit Kat', 'barcode': '7613035518209', 'color': 0xFFE53935, 'category': 'Çikolata'},
    {'emoji': '🍫', 'name': 'Kinder Bueno', 'barcode': '8000500310427', 'color': 0xFF4E342E, 'category': 'Çikolata'},
    {'emoji': '🍫', 'name': 'Eti Browni', 'barcode': '8690526636762', 'color': 0xFF4E342E, 'category': 'Çikolata'},
    {'emoji': '🍫', 'name': 'Eti Tutku', 'barcode': '8690526082458', 'color': 0xFF880E4F, 'category': 'Çikolata'},
    {'emoji': '🍫', 'name': 'Ulker Cikolata', 'barcode': '8690504151027', 'color': 0xFF4E342E, 'category': 'Çikolata'},
    {'emoji': '🍯', 'name': 'Torku Findik Krema', 'barcode': '8690526510017', 'color': 0xFFFF8F00, 'category': 'Çikolata'},
    {'emoji': '🍪', 'name': 'Eti Cin', 'barcode': '8690526790033', 'color': 0xFF2E7D32, 'category': 'Bisküvi'},
    {'emoji': '🍪', 'name': 'Ulker Biskuvi', 'barcode': '8690504015727', 'color': 0xFF1565C0, 'category': 'Bisküvi'},
    {'emoji': '🍪', 'name': 'Ulker Hanimeller', 'barcode': '8690504016427', 'color': 0xFF7B1FA2, 'category': 'Bisküvi'},
    {'emoji': '🍪', 'name': 'Oreo', 'barcode': '7622210449283', 'color': 0xFF212121, 'category': 'Bisküvi'},
    {'emoji': '🍪', 'name': 'Ulker Dido', 'barcode': '8690769030019', 'color': 0xFF4E342E, 'category': 'Bisküvi'},
    {'emoji': '🍪', 'name': 'Eti Burcak', 'barcode': '8690526610007', 'color': 0xFFFF8F00, 'category': 'Bisküvi'},
    {'emoji': '🍪', 'name': 'McVities Digestive', 'barcode': '5000168201118', 'color': 0xFF795548, 'category': 'Bisküvi'},
    {'emoji': '🥨', 'name': 'Eti Crax', 'barcode': '8690526195014', 'color': 0xFFFF8F00, 'category': 'Bisküvi'},
    {'emoji': '🍟', 'name': 'Pringles', 'barcode': '5053990108812', 'color': 0xFFE53935, 'category': 'Atıştırmalık'},
    {'emoji': '🍟', 'name': 'Lays', 'barcode': '4890008100309', 'color': 0xFFFFD600, 'category': 'Atıştırmalık'},
    {'emoji': '🍟', 'name': 'Eti Cips', 'barcode': '8690526013544', 'color': 0xFFFF8F00, 'category': 'Atıştırmalık'},
    {'emoji': '🍬', 'name': 'Haribo', 'barcode': '4001686325988', 'color': 0xFFFFD600, 'category': 'Atıştırmalık'},
    {'emoji': '🥣', 'name': 'Quaker Yulaf', 'barcode': '8710398100078', 'color': 0xFF795548, 'category': 'Sağlıklı'},
    {'emoji': '🥣', 'name': 'Cornflakes', 'barcode': '5053827148865', 'color': 0xFFFF8F00, 'category': 'Sağlıklı'},
    {'emoji': '🥣', 'name': 'Nestle Fitness', 'barcode': '7613036251471', 'color': 0xFFE53935, 'category': 'Sağlıklı'},
    {'emoji': '🍝', 'name': 'Barilla Spagetti', 'barcode': '8076802085738', 'color': 0xFF1565C0, 'category': 'Sağlıklı'},
    {'emoji': '🧘', 'name': 'Activia Yogurt', 'barcode': '3228857000166', 'color': 0xFF2E7D32, 'category': 'Sağlıklı'},
    {'emoji': '🌱', 'name': 'Alpro Soya', 'barcode': '5411188108085', 'color': 0xFF2E7D32, 'category': 'Sağlıklı'},
  ];

  final Map<String, Map<String, dynamic>> _categories = {
    'İçecek': {'icon': Icons.local_cafe_rounded, 'color': 0xFF0288D1},
    'Süt Ürünleri': {'icon': Icons.water_drop_rounded, 'color': 0xFF00897B},
    'Çikolata': {'icon': Icons.cake_rounded, 'color': 0xFF6D4C41},
    'Bisküvi': {'icon': Icons.cookie_rounded, 'color': 0xFFFF8F00},
    'Atıştırmalık': {'icon': Icons.local_pizza_rounded, 'color': 0xFFE53935},
    'Sağlıklı': {'icon': Icons.eco_rounded, 'color': 0xFF2E7D32},
  };

  @override
  void dispose() {
    _barcodeController.dispose();
    _searchController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var products = _allProducts;
    if (_selectedCategory != null) {
      products = products.where((p) => p['category'] == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      products = products.where((p) =>
        p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return products;
  }

  void _navigateToDetail(String barcode) {
    if (_showCamera) {
      _cameraController?.stop();
      setState(() => _showCamera = false);
    }
    Navigator.pushNamed(context, '/product-detail', arguments: barcode);
  }

  void _submitBarcode() {
    final code = _barcodeController.text.trim();
    if (code.isEmpty) return;
    _navigateToDetail(code);
  }

  void _openCamera() {
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    setState(() {
      _showCamera = true;
      _isScanning = false;
    });
  }

  void _closeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    setState(() => _showCamera = false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    if (_showCamera) {
      return _buildCameraView(primary);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: primary,
            automaticallyImplyLeading: false,
            title: Text('Ürün Tarayıcı',
              style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.w600)),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/history'),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Arama
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8)],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Ürün adı ile ara',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Barkod Sorgula
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code_rounded, color: primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Barkod Sorgula',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 14,
                              color: primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _barcodeController,
                              keyboardType: TextInputType.number,
                              onSubmitted: (_) => _submitBarcode(),
                              decoration: InputDecoration(
                                hintText: 'Barkod numarasını girin',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade400, fontSize: 13),
                                filled: true,
                                fillColor: const Color(0xFFF5F7FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _submitBarcode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text('Bul',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Kamera butonu
                      GestureDetector(
                        onTap: _openCamera,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: primary.withValues(alpha: 0.3),
                              style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_rounded,
                                color: primary, size: 20),
                              const SizedBox(width: 8),
                              Text('Kamerayı Aç',
                                style: GoogleFonts.poppins(
                                  color: primary, fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Kategoriler
                if (_searchQuery.isEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kategoriler',
                        style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B1B1B))),
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategory = null),
                        child: Text('Hepsini Gör',
                          style: GoogleFonts.poppins(
                            fontSize: 13, color: primary,
                            fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: _categories.entries.map((entry) {
                      final isSelected = _selectedCategory == entry.key;
                      final color = Color(entry.value['color'] as int);
                      return GestureDetector(
                        onTap: () => setState(() =>
                          _selectedCategory = isSelected ? null : entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                              ? color.withValues(alpha: 0.08)
                              : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? color : Colors.transparent,
                                width: 4)),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6)],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  entry.value['icon'] as IconData,
                                  color: color, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(entry.key,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF1B1B1B))),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: isSelected ? color : Colors.grey.shade400),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Ürünler
                if (_selectedCategory != null || _searchQuery.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedCategory ?? 'Arama Sonuçları',
                        style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedCategory = null;
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                        child: Text('Temizle',
                          style: GoogleFonts.poppins(
                            color: primary, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._filteredProducts.map((p) => GestureDetector(
                    onTap: () => _navigateToDetail(p['barcode']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Color(p['color']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text(p['emoji'],
                              style: const TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(p['name'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                ],

                // AI Analizi kartı
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Analizi',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 15,
                          color: primary)),
                      const SizedBox(height: 6),
                      Text(
                        'Ürünlerin içindeki gizli şeker ve katkı maddelerini saniyeler içinde öğrenin.',
                        style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade600,
                          height: 1.4)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        ),
                        child: Text('Nasıl Çalışır?',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 13)),
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

  Widget _buildCameraView(Color primary) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Kamera
          MobileScanner(
            controller: _cameraController!,
            onDetect: (capture) {
              if (_isScanning) return;
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first.rawValue;
                if (barcode != null && barcode.isNotEmpty) {
                  setState(() => _isScanning = true);
                  _navigateToDetail(barcode);
                }
              }
            },
          ),

          // Üst bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                      onPressed: _closeCamera,
                    ),
                    Text('Barkod Tara',
                      style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.flash_on_rounded,
                        color: Colors.white),
                      onPressed: () => _cameraController?.toggleTorch(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tarama çerçevesi
          Center(
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Köşe süslemeleri
                  Positioned(top: -2, left: -2,
                    child: Container(width: 30, height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: primary, width: 5),
                          left: BorderSide(color: primary, width: 5)),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16))))),
                  Positioned(top: -2, right: -2,
                    child: Container(width: 30, height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: primary, width: 5),
                          right: BorderSide(color: primary, width: 5)),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16))))),
                  Positioned(bottom: -2, left: -2,
                    child: Container(width: 30, height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: primary, width: 5),
                          left: BorderSide(color: primary, width: 5)),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16))))),
                  Positioned(bottom: -2, right: -2,
                    child: Container(width: 30, height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: primary, width: 5),
                          right: BorderSide(color: primary, width: 5)),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16))))),
                ],
              ),
            ),
          ),

          // Alt bilgi
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text('Barkodu çerçeve içine alın',
                    style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  if (_isScanning)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text('Analiz ediliyor...',
                          style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 14)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}