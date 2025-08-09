// MyFriends App - Main Entry Point
// 
// Initializes the application with theme configuration
// Sets up localization and navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/database_service.dart';
import 'core/navigation/app_router.dart';
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
class MyFriendsApp extends ConsumerWidget {
  const MyFriendsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
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
      
      // Router configuration
      routerConfig: router,
    );
  }
}