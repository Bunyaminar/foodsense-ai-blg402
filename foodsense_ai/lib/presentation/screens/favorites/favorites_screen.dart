import 'package:flutter/material.dart';
import 'dart:async';
import '../../../data/services/favorites_service.dart';
import '../../widgets/common/app_logo.dart';

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
          content: Text('${item.name} favorilerden kaldirildi'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Geri Al',
            textColor: Colors.white,
            onPressed: () async {
              // Geri al
            },
          ),
        ),
      );
    }
  }

  Color _getScoreColor(int? score) {
    if (score == null) return Colors.grey;
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppLogo(size: 36),
                      SizedBox(height: 8),
                      Text('Favorilerim',
                        style: TextStyle(color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
            )
          else if (_favorites.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    const Text('Henuz favori yok',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Urunleri analiz edip favorilere ekleyebilirsiniz',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/scanner'),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Urun Tara'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
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
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _favorites[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (index * 80)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeFavorite(item),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context, '/product-detail', arguments: item.barcode),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              // Resim
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: item.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(item.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) =>
                                          const Center(child: Text('🛒',
                                            style: TextStyle(fontSize: 28)))))
                                  : const Center(child: Text('🛒',
                                      style: TextStyle(fontSize: 28))),
                              ),
                              const SizedBox(width: 14),
                              // Bilgi
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                    if (item.brand != null)
                                      Text(item.brand!,
                                        style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.addedAt.day}/${item.addedAt.month}/${item.addedAt.year}',
                                      style: TextStyle(
                                        color: Colors.grey.shade400, fontSize: 11)),
                                  ],
                                ),
                              ),
                              // Skor
                              if (item.healthScore != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(item.healthScore)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${item.healthScore}',
                                    style: TextStyle(
                                      color: _getScoreColor(item.healthScore),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios,
                                size: 14, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      ),
                    ),
                    );
                  },
                  childCount: _favorites.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _favorites.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/scanner'),
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: const Text('Tara', style: TextStyle(color: Colors.white)),
          )
        : null,
    );
  }
}