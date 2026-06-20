import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/services/favorites_service.dart';
import '../../../data/services/history_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<AnalysisHistoryItem> _recentHistory = [];
  int _favoriteCount = 0;
  int _totalAnalysis = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final history = await HistoryService.getHistory();
    final favorites = await FavoritesService.getFavorites();
    if (mounted) {
      setState(() {
        _recentHistory = history.take(3).toList();
        _favoriteCount = favorites.length;
        _totalAnalysis = history.length;
        _isLoading = false;
      });
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 65) return const Color(0xFF2E7D32);
    if (score >= 40) return const Color(0xFFFF8F00);
    return const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.user?.email ?? '';
    final displayName = authProvider.user?.displayName;
    final username = displayName ?? email.split('@')[0];
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: primary.withValues(alpha: 0.15),
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        style: GoogleFonts.poppins(
                          color: primary, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Merhaba $username!',
                          style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey.shade500)),
                        Text('FoodsenseAI',
                          style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.settings_outlined,
                          color: Colors.grey.shade600, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stat kartlari
              Row(
                children: [
                  _statCard('$_totalAnalysis', 'Analiz', const Color(0xFF2E7D32)),
                  const SizedBox(width: 10),
                  _statCard('$_favoriteCount', 'Favori', const Color(0xFFFF8F00)),
                  const SizedBox(width: 10),
                  _statCard(
                    _recentHistory.isEmpty ? '-' : '${_recentHistory.first.healthScore}',
                    'Puan', const Color(0xFF1565C0)),
                ],
              ),
              const SizedBox(height: 16),

              // Urun Tara
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/scanner'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, const Color(0xFF1B5E20)]),
                    borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.qr_code_scanner_rounded,
                          color: Colors.white, size: 28)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ürünü Tara',
                            style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.bold)),
                          Text('İçerikleri anında analiz edin',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.qr_code_2_rounded,
                        color: Colors.white.withValues(alpha: 0.2), size: 60),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hizli Erisim
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _quickAction(Icons.favorite_rounded, 'Favoriler',
                    const Color(0xFFE91E63),
                    () => Navigator.pushNamed(context, '/favorites')),
                  _quickAction(Icons.history_rounded, 'Geçmiş',
                    const Color(0xFF7B1FA2),
                    () => Navigator.pushNamed(context, '/history')),
                  _quickAction(Icons.restaurant_menu_rounded, 'Diyet',
                    primary,
                    () => Navigator.pushNamed(context, '/preferences')),
                  _quickAction(Icons.person_rounded, 'Profil',
                    const Color(0xFF1565C0),
                    () => Navigator.pushNamed(context, '/profile')),
                ],
              ),
              const SizedBox(height: 24),

              // Kesfet
              Text('Keşfet',
                style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Hizli Oneriler
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/recommendations'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8)]),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.flash_on_rounded, color: primary, size: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hızlı Öneriler',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Öğünlerinizi optimize edin.',
                              style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                          ])),
                      const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Beslenme Danismani
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/chat'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.psychology_rounded, color: primary, size: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Beslenme Danışmanı',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
                            Text('AI destekli kişisel koçunuz.',
                              style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade600)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('Sohbete Başla',
                                  style: GoogleFonts.poppins(
                                    color: primary, fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, color: primary, size: 14),
                              ],
                            ),
                          ])),
                      Icon(Icons.psychology_alt_rounded,
                        color: primary.withValues(alpha: 0.2), size: 50),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Son Analizler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Son Analizler',
                    style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/history'),
                    child: Text('Tümünü Gör',
                      style: GoogleFonts.poppins(
                        fontSize: 13, color: primary, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_recentHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Icon(Icons.search_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Henüz analiz yok',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Ürün tarayarak başlayın',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                )
              else
                ..._recentHistory.map((item) {
                  final color = _getScoreColor(item.healthScore);
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/product-detail',
                      arguments: item.barcode),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border(left: BorderSide(color: color, width: 4))),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 52, height: 52,
                                color: color.withValues(alpha: 0.1),
                                child: item.imageUrl != null
                                  ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) =>
                                        const Center(child: Text('🛒',
                                          style: TextStyle(fontSize: 24))))
                                  : const Center(child: Text('🛒',
                                      style: TextStyle(fontSize: 24))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600, fontSize: 14),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(
                                    '${item.analyzedAt.day}/${item.analyzedAt.month}/${item.analyzedAt.year}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade400, fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20)),
                              child: Text('${item.healthScore}/100',
                                style: GoogleFonts.poppins(
                                  color: color, fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 3))),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.poppins(
              fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}