import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedStrings = {
    'tr': {
      'appName': 'FoodsenseAI',
      'login': 'Giris Yap',
      'register': 'Kayit Ol',
      'email': 'E-posta',
      'password': 'Sifre',
      'confirmPassword': 'Sifre Tekrar',
      'fullName': 'Ad Soyad',
      'forgotPassword': 'Sifremi Unuttum?',
      'noAccount': 'Hesabiniz yok mu?',
      'haveAccount': 'Zaten hesabiniz var mi?',
      'welcome': 'Hos Geldiniz',
      'loginSubtitle': 'Hesabiniza giris yapin',
      'dashboard': 'Ana Sayfa',
      'profile': 'Profil',
      'settings': 'Ayarlar',
      'logout': 'Cikis Yap',
      'quickAccess': 'Hizli Erisim',
      'features': 'Ozellikler',
      'scan': 'Tara',
      'favorites': 'Favoriler',
      'history': 'Gecmis',
      'diet': 'Diyetim',
      'comingSoon': 'Yakinda',
      'active': 'Aktif',
      'save': 'Kaydet',
      'cancel': 'Iptal',
      'hello': 'Merhaba',
      'darkMode': 'Karanlik Mod',
      'themeColor': 'Tema Rengi',
      'language': 'Dil',
      'about': 'Hakkinda',
      'version': 'Versiyon',
      'developer': 'Gelistirici',
      'scanProduct': 'Urun Tara',
      'scanSubtitle': 'Barkod okut, AI ile analiz et',
      'recentAnalysis': 'Son Analizler',
      'noAnalysis': 'Henuz analiz yok',
      'viewAll': 'Tumunu Gor',
    },
    'en': {
      'appName': 'FoodsenseAI',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'fullName': 'Full Name',
      'forgotPassword': 'Forgot Password?',
      'noAccount': "Don't have an account?",
      'haveAccount': 'Already have an account?',
      'welcome': 'Welcome',
      'loginSubtitle': 'Sign in to your account',
      'dashboard': 'Dashboard',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'quickAccess': 'Quick Access',
      'features': 'Features',
      'scan': 'Scan',
      'favorites': 'Favorites',
      'history': 'History',
      'diet': 'My Diet',
      'comingSoon': 'Coming Soon',
      'active': 'Active',
      'save': 'Save',
      'cancel': 'Cancel',
      'hello': 'Hello',
      'darkMode': 'Dark Mode',
      'themeColor': 'Theme Color',
      'language': 'Language',
      'about': 'About',
      'version': 'Version',
      'developer': 'Developer',
      'scanProduct': 'Scan Product',
      'scanSubtitle': 'Scan barcode, analyze with AI',
      'recentAnalysis': 'Recent Analysis',
      'noAnalysis': 'No analysis yet',
      'viewAll': 'View All',
    },
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    return _localizedStrings[langCode]?[key] ??
        _localizedStrings['tr']?[key] ?? key;
  }

  String get appName => translate('appName');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get fullName => translate('fullName');
  String get forgotPassword => translate('forgotPassword');
  String get noAccount => translate('noAccount');
  String get haveAccount => translate('haveAccount');
  String get welcome => translate('welcome');
  String get loginSubtitle => translate('loginSubtitle');
  String get dashboard => translate('dashboard');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get logout => translate('logout');
  String get quickAccess => translate('quickAccess');
  String get features => translate('features');
  String get scan => translate('scan');
  String get favorites => translate('favorites');
  String get history => translate('history');
  String get diet => translate('diet');
  String get comingSoon => translate('comingSoon');
  String get active => translate('active');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get hello => translate('hello');
  String get darkMode => translate('darkMode');
  String get themeColor => translate('themeColor');
  String get language => translate('language');
  String get about => translate('about');
  String get version => translate('version');
  String get developer => translate('developer');
  String get scanProduct => translate('scanProduct');
  String get scanSubtitle => translate('scanSubtitle');
  String get recentAnalysis => translate('recentAnalysis');
  String get noAnalysis => translate('noAnalysis');
  String get viewAll => translate('viewAll');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
