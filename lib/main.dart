// MyFriends App - Main Entry Point
// 
// Initializes the application with theme configuration
// Sets up localization and navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/database_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService.initialize();
  
  // Run the app with Riverpod provider scope
  runApp(
    const ProviderScope(
      child: MyFriendsApp(),
    ),
  );
}

/// Main application widget
class MyFriendsApp extends StatelessWidget {
  const MyFriendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFriends',
      debugShowCheckedModeBanner: false,
      
      // Apply custom theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme
      
      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'), // German - Primary
        Locale('en'), // English
      ],
      locale: const Locale('de'), // Default to German
      
      // Start with home page
      home: const HomePage(),
    );
  }
}

/// Home page of the application
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo placeholder
            Icon(
              Icons.people_outline,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            
            // Welcome text
            Text(
              l10n.welcomeTitle,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              l10n.welcomeSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Action buttons
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add friend page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.addFriend} - ${l10n.comingSoon}'),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: Text(l10n.addFriend),
            ),
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Navigate to friends list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.myFriends} - ${l10n.comingSoon}'),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: Text(l10n.myFriends),
            ),
          ],
        ),
      ),
      
      // Floating action button for quick add
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Quick add friend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.quickAdd} - ${l10n.comingSoon}'),
            ),
          );
        },
        tooltip: l10n.quickAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}