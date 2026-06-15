import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/theme_provider.dart';
import '../../widgets/common/app_logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: primaryColor,
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
                    colors: [primaryColor.withValues(alpha: 0.8), primaryColor],
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

                // Bildirimler
                _buildSectionTitle('🔔 Bildirimler'),
                const SizedBox(height: 8),
                _buildCard([
                  _buildSwitchTile(
                    '📱 Uygulama Bildirimleri',
                    'Urun analizi ve oneriler',
                    _notifications,
                    primaryColor,
                    (val) => setState(() => _notifications = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSwitchTile(
                    '📧 Email Bildirimleri',
                    'Haftalik beslenme raporu',
                    _emailNotifications,
                    primaryColor,
                    (val) => setState(() => _emailNotifications = val),
                  ),
                ]),
                const SizedBox(height: 16),

                // Gorunum
                _buildSectionTitle('🎨 Gorunum'),
                const SizedBox(height: 8),
                _buildCard([
                  _buildSwitchTile(
                    '🌙 Karanlik Mod',
                    'Gece modunu aktif et',
                    themeProvider.isDarkMode,
                    primaryColor,
                    (val) => themeProvider.setDarkMode(val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎨 Tema Rengi',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Uygulama rengini secin',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: themeProvider.themeColors.entries.map((entry) {
                            final isSelected = themeProvider.selectedThemeName == entry.key;
                            return GestureDetector(
                              onTap: () {
                                themeProvider.setTheme(entry.key);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${entry.key} tema secildi!'),
                                    backgroundColor: entry.value,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: entry.value,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: entry.value.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ] : [],
                                ),
                                child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Dil
                _buildSectionTitle('🌍 Dil'),
                const SizedBox(height: 8),
                _buildCard([
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Uygulama Dili',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 12),
                        ...['Turkce', 'English', 'Deutsch'].map((lang) {
                          final isSelected = themeProvider.language == lang;
                          return GestureDetector(
                            onTap: () => themeProvider.setLanguage(lang),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                  ? primaryColor.withValues(alpha: 0.1)
                                  : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? primaryColor : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    lang == 'Turkce' ? '🇹🇷' : lang == 'English' ? '🇬🇧' : '🇩🇪',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(lang,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? primaryColor : const Color(0xFF1B1B1B),
                                    )),
                                  const Spacer(),
                                  if (isSelected)
                                    Icon(Icons.check_circle, color: primaryColor, size: 20),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Hakkinda
                _buildSectionTitle('ℹ️ Hakkinda'),
                const SizedBox(height: 8),
                _buildCard([
                  _buildInfoTile('📱 Versiyon', '1.0.0'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile('👨‍💻 Gelistirici', 'Bunyamin ARPACI'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile('🎓 Proje', 'BLG402 Bitirme'),
                ]),
                const SizedBox(height: 16),

                // Cikis
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (mounted) Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cikis Yap',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
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

  Widget _buildSectionTitle(String title) {
    return Text(title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1B)));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Color color, Function(bool) onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: color),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    );
  }
}