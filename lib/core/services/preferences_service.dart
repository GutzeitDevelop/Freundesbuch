// User preferences service
// 
// Manages persistent user preferences and settings
// using Hive for local storage

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider for the preferences service
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

/// Service for managing user preferences
/// 
/// Features:
/// - Last used template persistence
/// - User settings management
/// - Theme preferences
/// - Language preferences
class PreferencesService {
  static const String _preferencesBoxName = 'user_preferences';
  static const String _lastTemplateKey = 'last_used_template';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _firstLaunchKey = 'first_launch';
  static const String _photoQualityKey = 'photo_quality';
  static const String _autoSaveKey = 'auto_save';
  static const String _lastBackupKey = 'last_backup_date';
  
  late Box _preferencesBox;
  
  /// Initialize the preferences service
  Future<void> initialize() async {
    _preferencesBox = await Hive.openBox(_preferencesBoxName);
  }
  
  /// Get last used template ID
  String? getLastUsedTemplate() {
    return _preferencesBox.get(_lastTemplateKey, defaultValue: 'classic');
  }
  
  /// Set last used template ID
  Future<void> setLastUsedTemplate(String templateId) async {
    await _preferencesBox.put(_lastTemplateKey, templateId);
  }
  
  /// Get theme mode (light, dark, system)
  String getThemeMode() {
    return _preferencesBox.get(_themeKey, defaultValue: 'system');
  }
  
  /// Set theme mode
  Future<void> setThemeMode(String themeMode) async {
    await _preferencesBox.put(_themeKey, themeMode);
  }
  
  /// Get language code
  String getLanguageCode() {
    return _preferencesBox.get(_languageKey, defaultValue: 'de');
  }
  
  /// Set language code
  Future<void> setLanguageCode(String languageCode) async {
    await _preferencesBox.put(_languageKey, languageCode);
  }
  
  /// Check if this is the first launch
  bool isFirstLaunch() {
    final isFirst = _preferencesBox.get(_firstLaunchKey, defaultValue: true);
    if (isFirst) {
      _preferencesBox.put(_firstLaunchKey, false);
    }
    return isFirst;
  }
  
  /// Get photo quality setting (low, medium, high)
  String getPhotoQuality() {
    return _preferencesBox.get(_photoQualityKey, defaultValue: 'medium');
  }
  
  /// Set photo quality
  Future<void> setPhotoQuality(String quality) async {
    await _preferencesBox.put(_photoQualityKey, quality);
  }
  
  /// Get auto-save setting
  bool getAutoSave() {
    return _preferencesBox.get(_autoSaveKey, defaultValue: true);
  }
  
  /// Set auto-save setting
  Future<void> setAutoSave(bool autoSave) async {
    await _preferencesBox.put(_autoSaveKey, autoSave);
  }
  
  /// Get last backup date
  DateTime? getLastBackupDate() {
    final dateString = _preferencesBox.get(_lastBackupKey);
    if (dateString != null) {
      return DateTime.tryParse(dateString);
    }
    return null;
  }
  
  /// Set last backup date
  Future<void> setLastBackupDate(DateTime date) async {
    await _preferencesBox.put(_lastBackupKey, date.toIso8601String());
  }
  
  /// Clear all preferences
  Future<void> clearAll() async {
    await _preferencesBox.clear();
  }
  
  /// Get a custom preference
  T? getCustomPreference<T>(String key, {T? defaultValue}) {
    return _preferencesBox.get(key, defaultValue: defaultValue) as T?;
  }
  
  /// Set a custom preference
  Future<void> setCustomPreference<T>(String key, T value) async {
    await _preferencesBox.put(key, value);
  }
  
  /// Remove a custom preference
  Future<void> removeCustomPreference(String key) async {
    await _preferencesBox.delete(key);
  }
  
  /// Check if a preference exists
  bool hasPreference(String key) {
    return _preferencesBox.containsKey(key);
  }
  
  /// Get all preference keys
  Iterable<dynamic> getAllKeys() {
    return _preferencesBox.keys;
  }
  
  /// Export preferences as JSON
  Map<String, dynamic> exportPreferences() {
    final Map<String, dynamic> preferences = {};
    for (var key in _preferencesBox.keys) {
      preferences[key as String] = _preferencesBox.get(key);
    }
    return preferences;
  }
  
  /// Import preferences from JSON
  Future<void> importPreferences(Map<String, dynamic> preferences) async {
    for (var entry in preferences.entries) {
      await _preferencesBox.put(entry.key, entry.value);
    }
  }
  
  /// Close the preferences box
  Future<void> close() async {
    await _preferencesBox.close();
  }
}