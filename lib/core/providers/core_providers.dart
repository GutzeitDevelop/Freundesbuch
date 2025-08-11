// Core providers for runtime injection
// 
// Centralizes all core service providers
// for dependency injection throughout the app

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../services/notification_service.dart';
import '../services/preferences_service.dart';

/// Navigation service provider
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Preferences service provider
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

/// Global scaffold messenger key provider
final scaffoldMessengerKeyProvider = Provider<GlobalKey<ScaffoldMessengerState>>((ref) {
  return GlobalKey<ScaffoldMessengerState>();
});

/// Initialize all core services
Future<void> initializeCoreServices(WidgetRef ref) async {
  // Initialize preferences service
  final preferencesService = ref.read(preferencesServiceProvider);
  await preferencesService.initialize();
  
  // Initialize navigation service with root route
  final navigationService = ref.read(navigationServiceProvider);
  navigationService.initialize('/');
  
  // Setup notification service with scaffold messenger key
  final notificationService = ref.read(notificationServiceProvider);
  final messengerKey = ref.read(scaffoldMessengerKeyProvider);
  notificationService.setMessengerKey(messengerKey);
  
  debugPrint('✅ Core services initialized successfully');
}