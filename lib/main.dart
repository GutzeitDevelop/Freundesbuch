// MyFriends App - Main Entry Point
// 
// Initializes the application with theme configuration
// Sets up localization and navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFriends'),
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
              'Willkommen bei MyFriends',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Behalte alle besonderen Menschen im Blick',
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
                  const SnackBar(
                    content: Text('Freund hinzufügen - Coming Soon'),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Neuen Freund hinzufügen'),
            ),
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Navigate to friends list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Freundesliste - Coming Soon'),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('Meine Freunde'),
            ),
          ],
        ),
      ),
      
      // Floating action button for quick add
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Quick add friend
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quick Add - Coming Soon'),
            ),
          );
        },
        tooltip: 'Freund hinzufügen',
        child: const Icon(Icons.add),
      ),
    );
  }
}