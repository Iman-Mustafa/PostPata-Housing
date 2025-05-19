// lib/data/services/localization_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _localeKey = 'selected_locale';
  final SharedPreferences _prefs;

  LocalizationService(this._prefs);

  Locale getLocale() {
    final localeCode = _prefs.getString(_localeKey);
    return localeCode != null 
        ? Locale(localeCode) 
        : const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  static List<Locale> supportedLocales = const [
    Locale('en'), // English
    Locale('sw'), // Swahili
  ];
}