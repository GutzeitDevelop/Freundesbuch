// Settings Page
// 
// App settings and preferences
// Version 0.7.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../l10n/app_localizations.dart';

/// Settings page for app preferences
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    
    return Scaffold(
      appBar: StandardAppBar(
        title: l10n.settings,
      ),
      body: ListView(
        children: [
          // General Settings Section
          _buildSectionHeader(context, l10n.settings),
          
          // Language Setting
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_getLanguageDisplayName(selectedLanguage, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, ref, l10n),
          ),
          
          // Theme Setting
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.darkMode),
            subtitle: Text(l10n.systemTheme),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, ref, l10n),
          ),
          
          const Divider(),
          
          // App Info Section
          _buildSectionHeader(context, l10n.about),
          
          // Version
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: const Text('0.7.0'),
          ),
          
          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          
          // Terms of Service
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(l10n.termsOfService),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // TODO: Open terms of service
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
  
  String _getLanguageDisplayName(AppLanguage language, AppLocalizations l10n) {
    switch (language) {
      case AppLanguage.system:
        return l10n.systemDefault;
      case AppLanguage.german:
        return l10n.german;
      case AppLanguage.english:
        return l10n.english;
    }
  }
  
  void _showLanguageDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((language) {
            final isSelected = ref.read(selectedLanguageProvider) == language;
            return RadioListTile<AppLanguage>(
              title: Text(_getLanguageDisplayName(language, l10n)),
              subtitle: _getLanguageSubtitle(language, l10n),
              value: language,
              groupValue: ref.read(selectedLanguageProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLanguage(value);
                  Navigator.pop(context);
                }
              },
              selected: isSelected,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
  
  Widget? _getLanguageSubtitle(AppLanguage language, AppLocalizations l10n) {
    switch (language) {
      case AppLanguage.system:
        return Text(
          'Verwendet die Systemsprache / Uses system language',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        );
      case AppLanguage.german:
        return Text(
          'Deutsche Sprache',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        );
      case AppLanguage.english:
        return Text(
          'English language',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        );
    }
  }
  
  void _showThemeDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.darkMode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.lightTheme),
              value: ThemeMode.light,
              groupValue: ThemeMode.system,
              onChanged: (value) {
                // TODO: Implement theme switching
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.darkTheme),
              value: ThemeMode.dark,
              groupValue: ThemeMode.system,
              onChanged: (value) {
                // TODO: Implement theme switching
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemTheme),
              value: ThemeMode.system,
              groupValue: ThemeMode.system,
              onChanged: (value) {
                // TODO: Implement theme switching
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}