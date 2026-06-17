import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/history_service.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Geçmişi Temizle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Tüm analiz geçmişi silinecek. Emin misiniz?',
          style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal',
              style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HistoryService.clearHistory();
              _loadHistory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            child: Text('Temizle',
              style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 65) return const Color(0xFF2E7D32);
    if (score >= 40) return const Color(0xFFFF8F00);
    return const Color(0xFFE53935);
  }

  String _getScoreEmoji(int score) {
    if (score >= 65) return '😊';
    if (score >= 40) return '😐';
    return '😟';
  }

  // Geçmişi tarihe göre grupla
  Map<String, List<AnalysisHistoryItem>> _groupByDate() {
    final Map<String, List<AnalysisHistoryItem>> groups = {};
    final now = DateTime.now();
    
    for (final item in _history) {
      final diff = now.difference(item.analyzedAt).inDays;
      String key;
      if (diff == 0) {
        key = 'Bugün';
      } else if (diff == 1) {
        key = 'Dün';
      } else {
        key = '${item.analyzedAt.day} ${_monthName(item.analyzedAt.month)} ${item.analyzedAt.year}';
      }
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(item);
    }
    return groups;
  }

  String _monthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final grouped = _groupByDate();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text('Analiz Geçmişi',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1B1B1B), fontSize: 18,
                fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFF5F7FA),
                  child: Icon(Icons.settings_outlined,
                    size: 18, color: Colors.grey)),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
              if (_history.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade300),
                  onPressed: _clearHistory,
                ),
            ],
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()))
          else if (_history.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                      child: const Icon(Icons.history_rounded,
                        size: 48, color: Colors.purple),
                    ),
                    const SizedBox(height: 16),
                    Text('Henüz analiz yok',
                      style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Ürün tarayarak başlayın',
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // Toplam analiz kartı
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, const Color(0xFF1B5E20)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOPLAM ANALİZ',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${_history.length}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 36,
                                      fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text('Ürün',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 16)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded,
                                      color: Colors.white, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Bu ay ${_history.where((h) => h.healthScore >= 65).length} sağlıklı tercih yaptınız',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.history_rounded,
                          color: Colors.white.withValues(alpha: 0.15),
                          size: 80),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tarih grupları
                  ...grouped.entries.map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarih başlığı
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Text(entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B1B1B))),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade200, thickness: 1)),
                            const SizedBox(width: 8),
                            Text('${entry.value.length} Analiz',
                              style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade400)),
                          ],
                        ),
                      ),

                      // Ürünler
                      ...entry.value.map((item) {
                        final color = _getScoreColor(item.healthScore);
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context, '/product-detail',
                            arguments: item.barcode),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6)],
                            ),
                            child: Row(
                              children: [
                                // Resim
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 54, height: 54,
                                    color: color.withValues(alpha: 0.08),
                                    child: item.imageUrl != null
                                      ? Image.network(item.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) =>
                                            Center(child: Text('🛒',
                                              style: TextStyle(fontSize: 24))))
                                      : Center(child: Text('🛒',
                                          style: TextStyle(fontSize: 24))),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Bilgi
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${item.analyzedAt.hour}:${item.analyzedAt.minute.toString().padLeft(2, '0')}',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade400,
                                              fontSize: 11)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(item.productName,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      // Kategori etiketi
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.healthScore >= 65
                                            ? 'SAĞLIKLI'
                                            : item.healthScore >= 40
                                              ? 'ORTA'
                                              : 'YÜKSEK ŞEKER',
                                          style: GoogleFonts.poppins(
                                            color: color, fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),

                                // Skor
                                Column(
                                  children: [
                                    Text(_getScoreEmoji(item.healthScore),
                                      style: const TextStyle(fontSize: 24)),
                                    Text('${item.healthScore}/100',
                                      style: GoogleFonts.poppins(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  )),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}