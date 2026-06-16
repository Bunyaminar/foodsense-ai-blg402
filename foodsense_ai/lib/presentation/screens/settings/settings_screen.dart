import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/theme_provider.dart';
import '../../widgets/common/app_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
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
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                  ),
                ),
                child: const SafeArea(
                  child: Center(child: AppLogo(size: 40)),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Görünüm
                _buildSectionTitle('🎨 Gorunum'),
                const SizedBox(height: 8),
                _buildCard([
                  // Karanlık Mod
                  SwitchListTile(
                    title: const Text('🌙 Karanlik Mod',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Gece modunu aktif et',
                      style: TextStyle(fontSize: 11)),
                    value: themeProvider.isDarkMode,
                    activeColor: primaryColor,
                    onChanged: (val) => themeProvider.setDarkMode(val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // Tema Rengi
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎨 Tema Rengi',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Uygulama rengini secin',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: themeProvider.themeColors.entries.map((entry) {
                            final isSelected = themeProvider.selectedThemeName == entry.key;
                            return GestureDetector(
                              onTap: () => themeProvider.setTheme(entry.key),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isSelected ? 52 : 44,
                                height: isSelected ? 52 : 44,
                                decoration: BoxDecoration(
                                  color: entry.value,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.black87 : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: entry.value.withValues(alpha: 0.5),
                                      blurRadius: 12, offset: const Offset(0, 4)),
                                  ] : [],
                                ),
                                child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 22)
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



                // Hakkında
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

                // Çıkış
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cikis Yap',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
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
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
        color: Color(0xFF1B1B1B)));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: Text(value,
        style: const TextStyle(fontSize: 13, color: Colors.grey)),
    );
  }
}