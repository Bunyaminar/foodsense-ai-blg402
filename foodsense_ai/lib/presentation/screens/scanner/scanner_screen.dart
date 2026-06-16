import 'package:flutter/material.dart';
import '../../widgets/common/app_logo.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _navigateToDetail(String code) {
    Navigator.pushNamed(context, '/product-detail', arguments: code);
  }

  void _submitManual() {
    final code = _manualController.text.trim();
    if (code.isEmpty) return;
    _navigateToDetail(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Ikon
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Center(
                  child: Text('📷', style: TextStyle(fontSize: 56)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Urun Tarayici',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Barkod numarasini girin veya ornek urun secin',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Alt panel
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Manuel giris
                        const Text(
                          'Barkod Numarasi Gir',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _manualController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Ornek: 5449000000996',
                                  prefixIcon: const Icon(Icons.qr_code),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                ),
                                onSubmitted: (_) => _submitManual(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _submitManual,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
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
                        const SizedBox(height: 24),

                        // Ornek urunler
                        const Text(
                          'Populer Urunler',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.5,
                          children: [
                            _buildProductChip('🥤', 'Coca Cola', '5449000000996', Colors.red),
                            _buildProductChip('🍫', 'Nutella', '3017620422003', Colors.brown),
                            _buildProductChip('🍟', 'Pringles', '5053990108812', Colors.orange),
                            _buildProductChip('🍬', 'Kit Kat', '7613035518209', Colors.red),
                            _buildProductChip('🍪', 'Oreo', '7622210449283', Colors.black),
                            _buildProductChip('🧃', 'Fanta', '5010477348735', Colors.orange),
                            _buildProductChip('🍭', 'Haribo', '4005500131304', Colors.yellow),
                            _buildProductChip('🍫', 'Kinder', '8000500310427', Colors.brown),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Turk urunleri
                        const Text(
                          'Turk Urunleri',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.5,
                          children: [
                            _buildProductChip('🍪', 'Eti Cin', '8690526790033', const Color(0xFF2E7D32)),
                            _buildProductChip('🥛', 'Sutas Sut', '8690632001015', Colors.blue),
                            _buildProductChip('🍫', 'Ulker', '8690504016427', Colors.purple),
                            _buildProductChip('🧀', 'Pinar Kasar', '8690632078017', Colors.amber),
                          ],
                        ),
                      ],
                    ),
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
