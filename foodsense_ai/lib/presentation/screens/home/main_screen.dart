import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import '../scanner/scanner_screen.dart';
import '../favorites/favorites_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ScannerScreen(),
    const FavoritesScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(Icons.home_rounded, Icons.home_outlined, 'Ana Sayfa'),
    _NavItem(Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_outlined, 'Tara'),
    _NavItem(Icons.favorite_rounded, Icons.favorite_outline_rounded, 'Favoriler'),
    _NavItem(Icons.history_rounded, Icons.history_outlined, 'Geçmiş'),
    _NavItem(Icons.settings_rounded, Icons.settings_outlined, 'Ayarlar'),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      // Mobil: Bottom Navigation
      return Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: _buildBottomNav(primary),
      );
    } else {
      // Web/Tablet: Top Navigation Bar
      return Scaffold(
        body: Column(
          children: [
            _buildTopNav(primary),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTopNav(Color primary) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.eco_rounded,
                      color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('FoodsenseAI',
                    style: GoogleFonts.poppins(
                      color: primary, fontSize: 16,
                      fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 40),

              // Nav items
              ...List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = _currentIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                        ? primary.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.inactiveIcon,
                          color: isActive ? primary : Colors.grey.shade400,
                          size: 18),
                        const SizedBox(width: 6),
                        Text(item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isActive
                              ? FontWeight.w600 : FontWeight.w400,
                            color: isActive
                              ? primary : Colors.grey.shade500)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = _currentIndex == index;
              final isScan = index == 1;

              if (isScan) {
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: primary.withValues(alpha: 0.4),
                        blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Icon(item.activeIcon, color: Colors.white, size: 24),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.inactiveIcon,
                      color: isActive ? primary : Colors.grey.shade400,
                      size: 22),
                    const SizedBox(height: 2),
                    Text(item.label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: isActive
                          ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? primary : Colors.grey.shade400)),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
}
