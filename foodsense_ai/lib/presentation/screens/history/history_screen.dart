import 'package:flutter/material.dart';
import '../../../data/services/history_service.dart';
import '../../widgets/common/app_logo.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AnalysisHistoryItem> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await HistoryService.getHistory();
    if (mounted) setState(() { _history = history; _isLoading = false; });
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gecmisi Temizle'),
        content: const Text('Tum analiz gecmisi silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HistoryService.clearHistory();
              _loadHistory();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Temizle', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 65) return const Color(0xFF2E7D32);
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreEmoji(int score) {
    if (score >= 65) return '✅';
    if (score >= 40) return '⚠️';
    return '❌';
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
            actions: [
              if (_history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _clearHistory,
                ),
            ],
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
                      Text('Analiz Gecmisi',
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
          else if (_history.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    const Text('Henuz analiz yok',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Urunleri analiz ettikce burada gorunecek',
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
                    final item = _history[index];
                    return GestureDetector(
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
                              width: 56, height: 56,
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
                                          style: TextStyle(fontSize: 24)))))
                                : const Center(child: Text('🛒',
                                    style: TextStyle(fontSize: 24))),
                            ),
                            const SizedBox(width: 12),

                            // Bilgi
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                  if (item.brand != null)
                                    Text(item.brand!,
                                      style: const TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                        size: 12, color: Colors.grey.shade400),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.analyzedAt.day}/${item.analyzedAt.month}/${item.analyzedAt.year} '
                                        '${item.analyzedAt.hour}:${item.analyzedAt.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.grey.shade400, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Skor
                            Column(
                              children: [
                                Text(_getScoreEmoji(item.healthScore),
                                  style: const TextStyle(fontSize: 20)),
                                Text('${item.healthScore}',
                                  style: TextStyle(
                                    color: _getScoreColor(item.healthScore),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                                Text('/100',
                                  style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 10)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _history.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}