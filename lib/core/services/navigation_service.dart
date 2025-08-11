// Navigation service with history management
// 
// Provides centralized navigation with back button handling
// and maintains navigation history for proper Android back behavior

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';

/// Provider for the navigation service
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

/// Navigation service for managing app navigation
/// 
/// Features:
/// - Maintains navigation history stack
/// - Handles Android back button properly
/// - Provides consistent navigation methods
/// - Manages deep linking and route restoration
class NavigationService {
  /// Maximum history size to prevent memory issues
  static const int maxHistorySize = 20;
  
  /// Navigation history stack
  final ListQueue<String> _navigationHistory = ListQueue<String>();
  
  /// Current route
  String? _currentRoute;
  
  /// Get current route
  String? get currentRoute => _currentRoute;
  
  /// Get navigation history (read-only)
  List<String> get history => _navigationHistory.toList();
  
  /// Add route to history
  void _addToHistory(String route) {
    // Don't add duplicate consecutive routes
    if (_navigationHistory.isEmpty || _navigationHistory.last != route) {
      _navigationHistory.add(route);
      
      // Limit history size
      while (_navigationHistory.length > maxHistorySize) {
        _navigationHistory.removeFirst();
      }
    }
    _currentRoute = route;
  }
  
  /// Remove last route from history
  String? _removeFromHistory() {
    if (_navigationHistory.isNotEmpty) {
      return _navigationHistory.removeLast();
    }
    return null;
  }
  
  /// Navigate to a new route (pushes to stack)
  /// 
  /// Use this for normal navigation that should add to history
  void navigateTo(BuildContext context, String route, {Object? extra}) {
    _addToHistory(GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString());
    context.push(route, extra: extra);
  }
  
  /// Replace current route (doesn't add to history)
  /// 
  /// Use this for replacing the current page without affecting history
  void replaceWith(BuildContext context, String route, {Object? extra}) {
    // Remove current route from history if it exists
    if (_navigationHistory.isNotEmpty && _navigationHistory.last == _currentRoute) {
      _removeFromHistory();
    }
    context.go(route, extra: extra);
    _addToHistory(route);
  }
  
  /// Navigate back
  /// 
  /// Returns true if navigation was successful, false if at root
  bool navigateBack(BuildContext context) {
    if (canGoBack()) {
      // Remove current route from history
      _removeFromHistory();
      
      // Get previous route
      if (_navigationHistory.isNotEmpty) {
        final previousRoute = _navigationHistory.last;
        _currentRoute = previousRoute;
        
        // Use pop if possible, otherwise go to previous route
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(previousRoute);
        }
        return true;
      }
    }
    
    // If we can't go back, navigate to home
    navigateToHome(context);
    return false;
  }
  
  /// Navigate to home (clears history)
  void navigateToHome(BuildContext context) {
    _navigationHistory.clear();
    _currentRoute = '/';
    context.go('/');
  }
  
  /// Check if can navigate back
  bool canGoBack() {
    return _navigationHistory.length > 1;
  }
  
  /// Handle Android back button
  /// 
  /// Returns false to prevent app from closing
  Future<bool> handleBackButton(BuildContext context) async {
    if (canGoBack()) {
      navigateBack(context);
      return false; // Don't exit app
    }
    
    // If at home screen, return true to allow app exit
    if (_currentRoute == '/' || _navigationHistory.isEmpty) {
      return true; // Allow app exit
    }
    
    // Otherwise navigate to home
    navigateToHome(context);
    return false; // Don't exit app
  }
  
  /// Clear navigation history
  void clearHistory() {
    _navigationHistory.clear();
    _currentRoute = null;
  }
  
  /// Initialize service with current route
  void initialize(String initialRoute) {
    clearHistory();
    _addToHistory(initialRoute);
  }
  
  /// Debug: Print navigation history
  void printHistory() {
    debugPrint('Navigation History:');
    for (var i = 0; i < _navigationHistory.length; i++) {
      debugPrint('  $i: ${_navigationHistory.elementAt(i)}');
    }
    debugPrint('Current Route: $_currentRoute');
  }
}