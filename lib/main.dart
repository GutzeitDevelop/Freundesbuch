// MyFriends App - Main Entry Point
// 
// Initializes the application with theme configuration
// Sets up localization, navigation, and core services
// Version: 0.3.0 - Refactored with centralized services

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/database_service.dart';
import 'core/navigation/app_router.dart';
import 'core/providers/core_providers.dart';
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

/// Main application widget with enhanced services
class MyFriendsApp extends ConsumerStatefulWidget {
  const MyFriendsApp({super.key});

  @override
  ConsumerState<MyFriendsApp> createState() => _MyFriendsAppState();
}

class _MyFriendsAppState extends ConsumerState<MyFriendsApp> {
  @override
  void initState() {
    super.initState();
    // Initialize core services after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeCoreServices(ref);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final scaffoldMessengerKey = ref.watch(scaffoldMessengerKeyProvider);
    
    return MaterialApp.router(
      title: 'MyFriends',
      debugShowCheckedModeBanner: false,
      
      // Global scaffold messenger key for notifications
      scaffoldMessengerKey: scaffoldMessengerKey,
      
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