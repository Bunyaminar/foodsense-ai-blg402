import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('lib/core/l10n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
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
  String get preferences => translate('preferences');
  String get logout => translate('logout');
  String get quickAccess => translate('quickAccess');
  String get dailySummary => translate('dailySummary');
  String get features => translate('features');
  String get scan => translate('scan');
  String get diet => translate('diet');
  String get list => translate('list');
  String get ai => translate('ai');
  String get calories => translate('calories');
  String get water => translate('water');
  String get product => translate('product');
  String get active => translate('active');
  String get comingSoon => translate('comingSoon');
  String get notifications => translate('notifications');
  String get appNotifications => translate('appNotifications');
  String get emailNotifications => translate('emailNotifications');
  String get darkMode => translate('darkMode');
  String get themeColor => translate('themeColor');
  String get language => translate('language');
  String get about => translate('about');
  String get version => translate('version');
  String get developer => translate('developer');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get hello => translate('hello');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}