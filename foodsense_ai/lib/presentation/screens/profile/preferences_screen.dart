import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../widgets/common/app_logo.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final List<String> _selectedAllergies = [];
  String? _selectedDiet;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final doc = await FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('profile').doc('preferences')
        .get();
      if (doc.exists && mounted) {
        setState(() {
          final data = doc.data()!;
          _selectedAllergies.clear();
          _selectedAllergies.addAll(
            List<String>.from(data['allergies'] ?? []));
          _selectedDiet = data['dietType'];
        });
      }
    } catch (e) {}
  }

  final List<Map<String, String>> _allergies = [
    {'emoji': '🌾', 'name': 'Gluten'},
    {'emoji': '🥛', 'name': 'Laktoz'},
    {'emoji': '🥜', 'name': 'Fistik'},
    {'emoji': '🥚', 'name': 'Yumurta'},
    {'emoji': '🐟', 'name': 'Balik'},
    {'emoji': '🦐', 'name': 'Kabuklu Deniz'},
    {'emoji': '🫘', 'name': 'Soya'},
    {'emoji': '🌰', 'name': 'Findik'},
  ];

  final List<Map<String, String>> _diets = [
    {'emoji': '🥩', 'name': 'Normal'},
    {'emoji': '🥗', 'name': 'Vejetaryen'},
    {'emoji': '🌱', 'name': 'Vegan'},
    {'emoji': '🥑', 'name': 'Keto'},
    {'emoji': '🫙', 'name': 'Glutensiz'},
    {'emoji': '🏃', 'name': 'Sporcu'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor, Color(0xFF388E3C)],
                  ),
                ),
                child: const SafeArea(
                  child: Center(child: AppLogo(size: 40)),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Baslik
                const Text(
                  'Tercihlerinizi Belirleyin',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Size ozel onerileri kisisellestirelim',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Alerjenler
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('⚠️', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('Alerjilerim',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Sahip oldugunuz alerjileri secin',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allergies.map((allergy) {
                          final isSelected = _selectedAllergies.contains(allergy['name']);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedAllergies.remove(allergy['name']);
                                } else {
                                  _selectedAllergies.add(allergy['name']!);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).primaryColor : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(allergy['emoji']!, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    allergy['name']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFF1B1B1B),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.check, color: Colors.white, size: 14),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Diyet Tercihi
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🥗', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text('Diyet Tercihim',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Beslenme tardinizi secin',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.3,
                        children: _diets.map((diet) {
                          final isSelected = _selectedDiet == diet['name'];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDiet = diet['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).primaryColor : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(diet['emoji']!, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 4),
                                  Text(
                                    diet['name']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFF1B1B1B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Kaydet
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () async {
                      setState(() => _isSaving = true);
                      try {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          await FirebaseFirestore.instance
                            .collection('users').doc(uid)
                            .collection('profile').doc('preferences')
                            .set({
                              'allergies': _selectedAllergies,
                              'dietType': _selectedDiet,
                              'updatedAt': FieldValue.serverTimestamp(),
                            });
                        }
                        if (mounted) {
                          setState(() => _isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Tercihler kaydedildi!'),
                              ]),
                              backgroundColor: Theme.of(context).primaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSaving
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Tercihleri Kaydet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}