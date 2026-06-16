import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/services/favorites_service.dart';
import '../../../data/services/history_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  List<AnalysisHistoryItem> _recentHistory = [];
  int _favoriteCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final history = await HistoryService.getHistory();
    final favorites = await FavoritesService.getFavorites();
    if (mounted) {
      setState(() {
        _recentHistory = history.take(3).toList();
        _favoriteCount = favorites.length;
        _isLoadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 65) return const Color(0xFF2E7D32);
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.user?.email ?? 'Kullanici';
    final displayName = authProvider.user?.displayName;
    final username = displayName ?? email.split('@')[0];
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary,
                        primary.withValues(alpha: 0.8),
                        Colors.teal.shade700,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/profile'),
                                child: Container(
                                  width: 46, height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                                      style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Merhaba, $username! 👋',
                                      style: const TextStyle(
                                        color: Colors.white, fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                    Text(email,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.75),
                                        fontSize: 12)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/settings'),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.settings_rounded,
                                    color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // İstatistik kartları
                          Row(
                            children: [
                              _buildStatCard('📊', '${_recentHistory.length}', 'Analiz', primary),
                              const SizedBox(width: 10),
                              _buildStatCard('❤️', '$_favoriteCount', 'Favori', Colors.pink),
                              const SizedBox(width: 10),
                              _buildStatCard('🏆', _recentHistory.isEmpty ? '-' :
                                '${_recentHistory.first.healthScore}', 'Son Skor', Colors.amber),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Ana Eylem Butonu
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/scanner'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, Colors.teal.shade600]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.4),
                            blurRadius: 15, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text('📷', style: TextStyle(fontSize: 32)),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Urun Tara',
                                  style: TextStyle(color: Colors.white,
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Barkod okut, AI ile analiz et',
                                  style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hızlı Erişim
                  const Text('Hizli Erisim',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B))),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction('❤️', 'Favoriler',
                        Colors.pink, '/favorites'),
                      _buildQuickAction('📊', 'Gecmis',
                        Colors.purple, '/history'),
                      _buildQuickAction('🥗', 'Diyetim',
                        primary, '/preferences'),
                      _buildQuickAction('👤', 'Profil',
                        Colors.blue, '/profile'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Son Analizler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Son Analizler',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1B1B))),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/history'),
                        child: Text('Tumunu Gor',
                          style: TextStyle(color: primary, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_isLoadingStats)
                    const Center(child: CircularProgressIndicator())
                  else if (_recentHistory.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          const Text('Henuz analiz yok',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Urun tarayarak baslayabilirsiniz',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    ..._recentHistory.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context, '/product-detail', arguments: item.barcode),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: _getScoreColor(item.healthScore)
                                  .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: item.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(item.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) =>
                                        const Center(child: Text('🛒',
                                          style: TextStyle(fontSize: 22)))))
                                : const Center(child: Text('🛒',
                                    style: TextStyle(fontSize: 22))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('${item.analyzedAt.day}/${item.analyzedAt.month}/${item.analyzedAt.year}',
                                    style: TextStyle(
                                      color: Colors.grey.shade400, fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getScoreColor(item.healthScore)
                                  .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('${item.healthScore}',
                                style: TextStyle(
                                  color: _getScoreColor(item.healthScore),
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ],
                        ),
                      ),
                    )),
                  const SizedBox(height: 24),

                  // Ozellikler
                  const Text('Ozellikler',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B))),
                  const SizedBox(height: 12),
                  _buildFeatureRow('🔍', 'Urun Tarayici',
                    'Barkod ile aninda analiz', primary, true),
                  const SizedBox(height: 10),
                  _buildFeatureRow('🧠', 'AI Alerjen Tespiti',
                    'ML model ile E-kodu analizi', Colors.purple, true),
                  const SizedBox(height: 10),
                  _buildFeatureRow('📊', 'Besin Analizi',
                    'Detayli besin degerleri', Colors.blue, true),
                  const SizedBox(height: 10),
                  _buildFeatureRow('💬', 'AI Chatbot',
                    'Kisisel beslenme asistani', Colors.orange, false),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String emoji, String label, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route).then((_) => _loadStats()),
      child: Column(
        children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Center(child: Text(emoji,
              style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String emoji, String title, String subtitle,
      Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(emoji,
              style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14,
                  color: Color(0xFF1B1B1B))),
                Text(subtitle, style: const TextStyle(
                  fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                ? color.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(isActive ? 'Aktif' : 'Yakinda',
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold,
                color: isActive ? color : Colors.orange)),
          ),
        ],
      ),
    );
  }
}