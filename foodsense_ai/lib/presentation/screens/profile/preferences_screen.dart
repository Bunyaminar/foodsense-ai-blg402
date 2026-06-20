import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  String? _selectedDiet;
  final List<String> _selectedAllergies = [];
  final List<String> _selectedGoals = [];
  bool _isSaving = false;

  final List<Map<String, String>> _dietOptions = [
    {'emoji': '🥗', 'name': 'Omnivore', 'desc': 'Dengeli ve çeşitli beslenme'},
    {'emoji': '🌱', 'name': 'Vegan', 'desc': 'Hayvansal ürün içermez'},
    {'emoji': '🥚', 'name': 'Vejetaryen', 'desc': 'Et içermez, süt/yumurta içerebilir'},
    {'emoji': '🌾', 'name': 'Glutensiz', 'desc': 'Buğday ve gluten içermez'},
    {'emoji': '🥩', 'name': 'Keto', 'desc': 'Düşük karbonhidrat, yüksek yağ'},
    {'emoji': '💪', 'name': 'Sporcu', 'desc': 'Yüksek protein odaklı'},
    {'emoji': '🩺', 'name': 'Diyabet', 'desc': 'Düşük şeker ve karbonhidrat'},
    {'emoji': '❤️', 'name': 'Kalp Sagligi', 'desc': 'Düşük tuz ve doymuş yağ'},
    {'emoji': '🔥', 'name': 'Dusuk Kalori', 'desc': 'Kalori kısıtlı diyet'},
  ];

  final List<Map<String, String>> _allergyOptions = [
    {'emoji': '🌾', 'name': 'Gluten'},
    {'emoji': '🥛', 'name': 'Sut'},
    {'emoji': '🥜', 'name': 'Fistik'},
    {'emoji': '🥚', 'name': 'Yumurta'},
    {'emoji': '🐟', 'name': 'Balik'},
    {'emoji': '🦐', 'name': 'Karides'},
    {'emoji': '🌰', 'name': 'Findik'},
    {'emoji': '🫘', 'name': 'Soya'},
    {'emoji': '🌿', 'name': 'Susam'},
  ];

  final List<String> _goalOptions = [
    'Kilo Ver', 'Kilo Al', 'Kas Kazan',
    'Saglikli Kal', 'Enerji Artir',
  ];

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
          _selectedAllergies.addAll(List<String>.from(data['allergies'] ?? []));
          _selectedDiet = data['dietType'];
          _selectedGoals.clear();
          _selectedGoals.addAll(List<String>.from(data['goals'] ?? []));
        });
      }
    } catch (e) {}
  }

  Future<void> _savePreferences() async {
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
            'goals': _selectedGoals,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      }
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Tercihler kaydedildi!',
                style: GoogleFonts.poppins()),
            ]),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Kaydedildi - MainScreen icinde calisiyoruz
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
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
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                color: Color(0xFF2E7D32)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Diyet Tercihleri',
              style: GoogleFonts.poppins(
                color: primary, fontSize: 18,
                fontWeight: FontWeight.bold)),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                Text('Tercihlerinize göre kişiselleştirilmiş analiz yapılır',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500, fontSize: 13)),
                const SizedBox(height: 24),

                // Diyet Tipi
                _sectionTitle('DİYET TİPİ', primary),
                const SizedBox(height: 12),
                ..._dietOptions.map((diet) {
                  final isSelected = _selectedDiet == diet['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDiet = diet['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                          ? primary.withValues(alpha: 0.06)
                          : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? primary : Colors.transparent,
                            width: 4)),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Text(diet['emoji']!,
                            style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(diet['name']!,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                                Text(diet['desc']!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade500,
                                    fontSize: 12)),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded,
                              color: primary, size: 22),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Alerjiler
                _sectionTitle('ALERJİLER', primary),
                const SizedBox(height: 12),
                Column(
                  children: _allergyOptions.map((allergy) {
                    final isSelected = _selectedAllergies.contains(allergy['name']);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (isSelected) {
                          _selectedAllergies.remove(allergy['name']);
                        } else {
                          _selectedAllergies.add(allergy['name']!);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                            ? primary.withValues(alpha: 0.06)
                            : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(
                              color: isSelected ? primary : Colors.transparent,
                              width: 4)),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6)],
                        ),
                        child: Row(
                          children: [
                            Text(allergy['emoji']!,
                              style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(allergy['name']!,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isSelected
                                    ? primary : Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1B1B1B))),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded,
                                color: primary, size: 22)
                            else
                              Icon(Icons.radio_button_unchecked_rounded,
                                color: Colors.grey.shade300, size: 22),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Sağlık Hedefleri
                _sectionTitle('SAĞLIK HEDEFLERİ', primary),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _goalOptions.map((goal) {
                    final isSelected = _selectedGoals.contains(goal);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (isSelected) {
                          _selectedGoals.remove(goal);
                        } else {
                          _selectedGoals.add(goal);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? primary : Colors.grey.shade300),
                        ),
                        child: Text(goal,
                          style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: isSelected
                              ? Colors.white : Colors.grey.shade600)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Kaydet butonu
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, const Color(0xFF1B5E20)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: primary.withValues(alpha: 0.4),
                      blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _savePreferences,
                    icon: _isSaving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_rounded, color: Colors.white),
                    label: Text('Tercihleri Kaydet',
                      style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    ),
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

  Widget _sectionTitle(String title, Color color) {
    return Text(title,
      style: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.bold,
        color: color, letterSpacing: 1.5));
  }
}