import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'domain/providers/auth_provider.dart';
import 'domain/providers/profile_provider.dart';
import 'domain/providers/theme_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/home/dashboard_screen.dart';
import 'presentation/screens/home/main_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';
import 'presentation/screens/recommendations/recommendations_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/profile/preferences_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/scanner/scanner_screen.dart';
import 'presentation/screens/product/product_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'FoodsenseAI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(themeProvider.primaryColor),
            darkTheme: AppTheme.buildTheme(themeProvider.primaryColor, isDark: true),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(themeProvider.language == 'English' ? 'en' : 'tr'),
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  final routes = {
                    '/login': const LoginScreen(),
                    '/register': const RegisterScreen(),
                    '/dashboard': const MainScreen(),
                    '/profile': const ProfileScreen(),
                    '/preferences': const PreferencesScreen(),
                    '/onboarding': const OnboardingScreen(),
                    '/forgot-password': const ForgotPasswordScreen(),
                    '/settings': const SettingsScreen(),
                    '/favorites': const FavoritesScreen(),
                    '/history': const HistoryScreen(),
                    '/scanner': const ScannerScreen(),
                    '/product-detail': const ProductDetailScreen(),
                  };
                  return routes[settings.name] ?? const SplashScreen();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;
                  var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                  var fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
                    .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(
                      opacity: animation.drive(fadeAnim),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              );
            },
            routes: {
              AppConstants.loginRoute: (context) => const LoginScreen(),
              AppConstants.registerRoute: (context) => const RegisterScreen(),
              AppConstants.dashboardRoute: (context) => const MainScreen(),
                '/chat': (context) => const ChatScreen(),
                '/recommendations': (context) => const RecommendationsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/preferences': (context) => const PreferencesScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/history': (context) => const HistoryScreen(),
              '/scanner': (context) => const ScannerScreen(),
              '/product-detail': (context) => const ProductDetailScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) return const LoginScreen();
        return const DashboardScreen();
      },
    );
  }
}
