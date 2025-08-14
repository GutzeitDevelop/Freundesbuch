// Language/Locale Provider
// 
// Manages app language preferences
// Version 0.7.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages enum
enum AppLanguage {
  system('system', 'System Default'),
  german('de', 'Deutsch'),
  english('en', 'English');

  final String code;
  final String displayName;
  
  const AppLanguage(this.code, this.displayName);
  
  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.system,
    );
  }
}

/// State notifier for locale management
class LocaleNotifier extends StateNotifier<Locale?> {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;
  AppLanguage _selectedLanguage = AppLanguage.system;
  
  LocaleNotifier(this._prefs) : super(null) {
    _loadLocale();
  }
  
  /// Get currently selected language
  AppLanguage get selectedLanguage => _selectedLanguage;
  
  /// Load saved locale from preferences
  void _loadLocale() {
    final savedCode = _prefs.getString(_localeKey);
    if (savedCode != null && savedCode != 'system') {
      _selectedLanguage = AppLanguage.fromCode(savedCode);
      state = Locale(savedCode);
    } else {
      _selectedLanguage = AppLanguage.system;
      state = null; // Use system locale
    }
  }
  
  /// Set new language
  Future<void> setLanguage(AppLanguage language) async {
    _selectedLanguage = language;
    
    if (language == AppLanguage.system) {
      await _prefs.remove(_localeKey);
      state = null; // Use system locale
    } else {
      await _prefs.setString(_localeKey, language.code);
      state = Locale(language.code);
    }
  }
  
  /// Get display name for a language in current locale
  String getDisplayName(AppLanguage language, BuildContext context) {
    // These would ideally come from localization files
    switch (language) {
      case AppLanguage.system:
        return 'Systemstandard';
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.english:
        return 'English';
    }
  }
}

/// Provider for shared preferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// Provider for locale state
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

/// Provider for selected language
final selectedLanguageProvider = Provider<AppLanguage>((ref) {
  final notifier = ref.watch(localeProvider.notifier);
  return notifier.selectedLanguage;
});