// Notification service for app-wide messages
// 
// Provides centralized notification/toast management
// with consistent positioning and styling

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';
import '../utils/snackbar_utils.dart';

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Notification types for different message styles
enum NotificationType {
  success,
  error,
  warning,
  info,
}

/// Notification message model
class NotificationMessage {
  final String message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback? action;
  final String? actionLabel;
  
  const NotificationMessage({
    required this.message,
    this.type = NotificationType.info,
    this.duration = const Duration(seconds: 3),
    this.action,
    this.actionLabel,
  });
}

/// Centralized notification service
/// 
/// Features:
/// - Consistent positioning AT THE TOP below app bar
/// - Different notification types (success, error, warning, info)
/// - Uses SnackbarUtils for TOP positioning
class NotificationService {
  /// Current context for showing notifications
  BuildContext? _currentContext;
  
  /// Set the current context
  void setContext(BuildContext context) {
    _currentContext = context;
  }
  
  /// Set the scaffold messenger key (deprecated - kept for compatibility)
  void setMessengerKey(GlobalKey<ScaffoldMessengerState> key) {
    // No longer used - kept for compatibility
  }
  
  /// Show a notification at the TOP
  void showNotification({
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) {
    // Get the current context from navigation
    final context = _currentContext ?? WidgetsBinding.instance.rootElement;
    if (context == null) return;
    
    // Use SnackbarUtils to show at TOP
    switch (type) {
      case NotificationType.success:
        SnackbarUtils.showSuccess(context, message);
        break;
      case NotificationType.error:
        SnackbarUtils.showError(context, message);
        break;
      case NotificationType.warning:
        SnackbarUtils.showTopSnackbar(
          context, 
          message,
          backgroundColor: Colors.orange.shade600,
          icon: Icons.warning_amber_outlined,
        );
        break;
      case NotificationType.info:
        SnackbarUtils.showInfo(context, message);
        break;
    }
  }
  
  /// Show success notification at TOP
  void showSuccess(String message, {Duration? duration}) {
    final context = _currentContext ?? WidgetsBinding.instance.rootElement;
    if (context != null) {
      SnackbarUtils.showSuccess(context, message);
    }
  }
  
  /// Show error notification at TOP
  void showError(String message, {Duration? duration}) {
    final context = _currentContext ?? WidgetsBinding.instance.rootElement;
    if (context != null) {
      SnackbarUtils.showError(context, message);
    }
  }
  
  /// Show warning notification at TOP
  void showWarning(String message, {Duration? duration}) {
    final context = _currentContext ?? WidgetsBinding.instance.rootElement;
    if (context != null) {
      SnackbarUtils.showTopSnackbar(
        context,
        message,
        backgroundColor: Colors.orange.shade600,
        icon: Icons.warning_amber_outlined,
        duration: duration ?? const Duration(seconds: 3),
      );
    }
  }
  
  /// Show info notification at TOP
  void showInfo(String message, {Duration? duration}) {
    final context = _currentContext ?? WidgetsBinding.instance.rootElement;
    if (context != null) {
      SnackbarUtils.showInfo(context, message);
    }
  }
  
  /// Clear all notifications (no-op for now)
  void clearAll() {
    // No-op for now since we use overlays
  }
}