import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<String> _goals = [];
  String? _dietType;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _allTips = [
    {
      'title': 'Yeterli Protein Alin',
      'desc': 'Her ogunde protein kaynagi bulundurun. Yumurta, tavuk, balik veya baklagil tercih edin.',
      'emoji': '💪',
      'color': 0xFF2E7D32,
      'tags': ['Sporcu', 'Kas Kazan'],
    },
    {
      'title': 'Su Iceyin',
      'desc': 'Gunde en az 8 bardak su icin. Susuzluk aclikla karistiriilabilir.',
      'emoji': '💧',
      'color': 0xFF0288D1,
      'tags': ['Saglikli Kal', 'Dusuk Kalori'],
    },
    {
      'title': 'Lifli Besinler',
      'desc': 'Sebze, meyve ve tam tahillar sindirim sagliginizi iyilestirir.',
      'emoji': '🥦',
      'color': 0xFF2E7D32,
      'tags': ['Saglikli Kal', 'Kalp Sagligi'],
    },
    {
      'title': 'Seker Tuketimini Azaltin',
      'desc': 'Islenmis seker yerine dogal tatlandiricilari tercih edin.',
      'emoji': '🍯',
      'color': 0xFFFF8F00,
      'tags': ['Diyabet', 'Dusuk Kalori'],
    },
    {
      'title': 'Omega-3 Alin',
      'desc': 'Haftada 2-3 kez balik yiyin veya ceviz, keten tohumu ekleyin.',
      'emoji': '🐟',
      'color': 0xFF0288D1,
      'tags': ['Kalp Sagligi', 'Saglikli Kal'],
    },
    {
      'title': 'Karbonhidrat Kontrolu',
      'desc': 'Kompleks karbonhidratlar tercih edin: tam bugday, kinoa, yulaf.',
      'emoji': '🌾',
      'color': 0xFF795548,
      'tags': ['Keto', 'Diyabet'],
    },
    {
      'title': 'Vegan Protein Kaynaklari',
      'desc': 'Mercimek, nohut, tofu ve kinoa ile protein ihtiyacinizi karsilayin.',
      'emoji': '🌱',
      'color': 0xFF2E7D32,
      'tags': ['Vegan', 'Vejetaryen'],
    },
    {
      'title': 'Saglikli Yag Tuketin',
      'desc': 'Avokado, zeytinyagi ve findik saglikli yag kaynaklaridir.',
      'emoji': '🥑',
      'color': 0xFF558B2F,
      'tags': ['Keto', 'Kalp Sagligi'],
    },
    {
      'title': 'Ogün Atlamamayin',
      'desc': 'Duzenli ogünler kan sekerinizi dengede tutar ve metabolizmayi hizlandirir.',
      'emoji': '⏰',
      'color': 0xFF7B1FA2,
      'tags': ['Diyabet', 'Dusuk Kalori', 'Saglikli Kal'],
    },
    {
      'title': 'Demir Eksikligine Dikkat',
      'desc': 'Ispanak, mercimek ve kuru meyvelerle demir ihtiyacinizi karsilayin.',
      'emoji': '🫀',
      'color': 0xFFE53935,
      'tags': ['Vegan', 'Vejetaryen'],
    },
    {
      'title': 'Pre-Workout Beslenme',
      'desc': 'Egzersizden 1-2 saat once karbonhidrat + protein kombinasyonu alin.',
      'emoji': '🏋️',
      'color': 0xFF2E7D32,
      'tags': ['Sporcu', 'Kas Kazan', 'Enerji Artir'],
    },
    {
      'title': 'Tuz Tuketimini Azaltin',
      'desc': 'Gunluk tuz tuketiminizi 5g altinda tutun. Hazir gidalardan uzak durun.',
      'emoji': '🧂',
      'color': 0xFF1565C0,
      'tags': ['Kalp Sagligi', 'Saglikli Kal'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('profile').doc('preferences')
          .get();
        if (doc.exists && mounted) {
          setState(() {
            final data = doc.data()!;
            _dietType = data['dietType'];
            _goals = List<String>.from(data['goals'] ?? []);
          });
        }
      }
    } catch (e) {}
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredTips {
    if (_dietType == null && _goals.isEmpty) return _allTips;
    return _allTips.where((tip) {
      final tags = List<String>.from(tip['tags']);
      if (_dietType != null && tags.contains(_dietType)) return true;
      for (final goal in _goals) {
        if (tags.contains(goal)) return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final tips = _filteredTips.isEmpty ? _allTips : _filteredTips;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B1B1B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hizli Oneriler',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1B1B1B), fontSize: 18,
            fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // Kisisellestirilmis bilgi karti
                    if (_dietType != null || _goals.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.2))),
                        child: Row(children: [
                          Icon(Icons.person_rounded, color: primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tercihlerinize gore kisisellestirilmis oneriler: ${_dietType ?? ""} ${_goals.join(", ")}',
                              style: GoogleFonts.poppins(
                                color: primary, fontSize: 12,
                                fontWeight: FontWeight.w500))),
                        ]),
                      ),

                    // Oneriler
                    ...tips.asMap().entries.map((entry) {
                      final tip = entry.value;
                      final color = Color(tip['color'] as int);
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 200 + (entry.key * 80)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child)),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border(
                              left: BorderSide(color: color, width: 4)),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8)]),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text(tip['emoji'],
                                  style: const TextStyle(fontSize: 24)))),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tip['title'],
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: const Color(0xFF1B1B1B))),
                                    const SizedBox(height: 4),
                                    Text(tip['desc'],
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade600,
                                        fontSize: 12, height: 1.4)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      children: (tip['tags'] as List<String>)
                                        .map((tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10)),
                                          child: Text(tag,
                                            style: GoogleFonts.poppins(
                                              color: color, fontSize: 10,
                                              fontWeight: FontWeight.w600))))
                                        .toList()),
                                  ])),
                            ])),
                      );
                    }),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
    );
  }
}
