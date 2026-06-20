import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteItem> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await FavoritesService.getFavorites();
    if (mounted) setState(() { _favorites = favorites; _isLoading = false; });
  }

  Future<void> _removeFavorite(FavoriteItem item) async {
    await FavoritesService.removeFavorite(item.barcode);
    _loadFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} favorilerden kaldırıldı',
            style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Color _getScoreColor(int? score) {
    if (score == null) return Colors.grey;
    if (score >= 65) return const Color(0xFF2E7D32);
    if (score >= 40) return const Color(0xFFFF8F00);
    return const Color(0xFFE53935);
  }

  IconData _getScoreIcon(int? score) {
    if (score == null) return Icons.help_outline_rounded;
    if (score >= 65) return Icons.eco_rounded;
    if (score >= 40) return Icons.info_outline_rounded;
    return Icons.warning_amber_rounded;
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
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FoodsenseAI',
                  style: GoogleFonts.poppins(
                    color: primary, fontSize: 12,
                    fontWeight: FontWeight.w500)),
                Text('Favorilerim',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1B1B1B), fontSize: 18,
                    fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.tune_rounded, color: Colors.grey.shade600),
                onPressed: () {},
              ),
            ],
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()))
          else if (_favorites.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.pink.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                        size: 48, color: Colors.pink),
                    ),
                    const SizedBox(height: 16),
                    Text('Henüz favori yok',
                      style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Ürünleri analiz edip favorilere ekleyin',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500, fontSize: 13)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/scanner'),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: Text('Ürün Tara',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Ürün sayısı
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text('${_favorites.length} Kayıtlı Ürün',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500, fontSize: 13)),
                  ),

                  // Ürün listesi
                  ..._favorites.asMap().entries.map((entry) {
                    final item = entry.value;
                    final color = _getScoreColor(item.healthScore);
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 200 + (entry.key * 60)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child),
                      ),
                      child: Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeFavorite(item),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.delete_rounded,
                            color: Colors.white, size: 26),
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context, '/product-detail',
                            arguments: item.barcode),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border(
                                left: BorderSide(color: color, width: 4)),
                              boxShadow: [BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Resim
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 60, height: 60,
                                      color: color.withValues(alpha: 0.08),
                                      child: item.imageUrl != null
                                        ? Image.network(item.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                              Center(child: Text('🛒',
                                                style: TextStyle(fontSize: 28))))
                                        : Center(child: Text('🛒',
                                            style: TextStyle(fontSize: 28))),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Bilgi
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Eklendi: ${item.addedAt.day} ${_monthName(item.addedAt.month)} ${item.addedAt.year}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade400,
                                            fontSize: 11)),
                                        const SizedBox(height: 6),
                                        // Etiket
                                        if (item.healthScore != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: color.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item.healthScore! >= 65
                                                ? 'SAĞLIKLI'
                                                : item.healthScore! >= 40
                                                  ? 'ORTA'
                                                  : 'DİKKAT',
                                              style: GoogleFonts.poppins(
                                                color: color,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Skor
                                  if (item.healthScore != null)
                                    Column(
                                      children: [
                                        Text('${item.healthScore}',
                                          style: GoogleFonts.poppins(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22)),
                                        Icon(_getScoreIcon(item.healthScore),
                                          color: color, size: 18),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Akıllı Tavsiye kartı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lightbulb_rounded,
                            color: Colors.teal, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Akıllı Tavsiye',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                  fontSize: 14)),
                              Text(
                                'Favorilerindeki ürünlere benzer daha sağlıklı alternatifler bulundu.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.teal.shade600,
                                  height: 1.4)),
                              const SizedBox(height: 6),
                              GestureDetector(
                                child: Row(
                                  children: [
                                    Text('Alternatifleri Gör',
                                      style: GoogleFonts.poppins(
                                        color: Colors.teal.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_rounded,
                                      color: Colors.teal.shade700, size: 14),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  String _monthName(int month) {
    const months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return months[month - 1];
  }
}