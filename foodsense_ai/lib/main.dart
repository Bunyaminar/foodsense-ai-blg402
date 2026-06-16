import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'domain/providers/auth_provider.dart';
import 'domain/providers/profile_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/dashboard_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/profile/preferences_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/scanner/scanner_screen.dart';
import 'presentation/screens/product/product_detail_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'domain/providers/theme_provider.dart';
import 'core/l10n/app_localizations.dart';
import 'presentation/screens/profile/preferences_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/scanner/scanner_screen.dart';
import 'presentation/screens/product/product_detail_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'domain/providers/theme_provider.dart';
import 'core/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        title: 'FoodsenseAI',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.registerRoute: (context) => const RegisterScreen(),
          AppConstants.dashboardRoute: (context) => const DashboardScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/preferences': (context) => const PreferencesScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/history': (context) => const HistoryScreen(),
          '/scanner': (context) => const ScannerScreen(),
          '/product-detail': (context) => const ProductDetailScreen(),
          '/preferences': (context) => const PreferencesScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/history': (context) => const HistoryScreen(),
          '/scanner': (context) => const ScannerScreen(),
          '/product-detail': (context) => const ProductDetailScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        return const DashboardScreen();
      },
    );
  }
}
