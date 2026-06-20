import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final primary = Theme.of(context).primaryColor;
    final email = authProvider.user?.email ?? '';
    final displayName = authProvider.user?.displayName;
    final username = displayName ?? email.split('@')[0];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text('Ayarlar',
              style: GoogleFonts.poppins(
                color: primary, fontSize: 20,
                fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(Icons.settings_outlined, color: primary),
                onPressed: () {},
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Profil kartı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: primary.withValues(alpha: 0.15),
                            child: Text(
                              username.isNotEmpty
                                ? username[0].toUpperCase() : 'U',
                              style: GoogleFonts.poppins(
                                color: primary, fontSize: 24,
                                fontWeight: FontWeight.bold)),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white, width: 2)),
                              child: const Icon(Icons.verified_rounded,
                                color: Colors.white, size: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(username,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Premium Üye',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.edit_outlined,
                            color: primary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Görünüm
                _buildSectionTitle('GÖRÜNÜM', primary),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      // Karanlık Mod
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.dark_mode_outlined,
                                size: 20, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Karanlık Mod',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                            ),
                            Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (val) => themeProvider.setDarkMode(val),
                              activeColor: primary,
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 1, color: Colors.grey.shade100,
                        indent: 16, endIndent: 16),

                      // Tema Rengi
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.palette_outlined,
                                    size: 20, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Text('Tema Rengi',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: themeProvider.themeColors.entries
                                .map((entry) {
                                final isSelected =
                                  themeProvider.selectedThemeName == entry.key;
                                return GestureDetector(
                                  onTap: () => themeProvider.setTheme(entry.key),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isSelected ? 48 : 40,
                                    height: isSelected ? 48 : 40,
                                    decoration: BoxDecoration(
                                      color: entry.value,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                          ? Colors.black26 : Colors.transparent,
                                        width: 3),
                                      boxShadow: isSelected ? [BoxShadow(
                                        color: entry.value.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))] : [],
                                    ),
                                    child: isSelected
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 20)
                                      : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Uygulama Hakkında
                _buildSectionTitle('UYGULAMA HAKKINDA', primary),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(Icons.info_outline_rounded,
                        'Hakkında', () {}),
                      Divider(height: 1, color: Colors.grey.shade100,
                        indent: 56),
                      _buildInfoTile(Icons.lock_outline_rounded,
                        'Gizlilik', () {}),
                      Divider(height: 1, color: Colors.grey.shade100,
                        indent: 56),
                      _buildInfoTile(Icons.description_outlined,
                        'Koşullar', () {}),
                      Divider(height: 1, color: Colors.grey.shade100,
                        indent: 56),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_outlined,
                            size: 20, color: Colors.grey),
                        ),
                        title: Text('Versiyon',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                        trailing: Text('v1.0.0',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade400, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Çıkış Yap
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    icon: Icon(Icons.logout_rounded,
                      color: Colors.red.shade400),
                    label: Text('Çıkış Yap',
                      style: GoogleFonts.poppins(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600, fontSize: 15)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(title,
      style: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.bold,
        color: color, letterSpacing: 1));
  }

  Widget _buildInfoTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.grey),
      ),
      title: Text(title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
        size: 14, color: Colors.grey.shade300),
    );
  }
}