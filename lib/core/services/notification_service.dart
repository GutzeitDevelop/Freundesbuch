// Notification service for app-wide messages
// 
// Provides centralized notification/toast management
// with consistent positioning and styling

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';

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
/// - Consistent positioning below app bar
/// - Different notification types (success, error, warning, info)
/// - Queue management for multiple notifications
/// - Action support for interactive notifications
class NotificationService {
  /// Notification queue
  final Queue<NotificationMessage> _notificationQueue = Queue<NotificationMessage>();
  
  /// Current scaffold messenger key
  GlobalKey<ScaffoldMessengerState>? _messengerKey;
  
  /// Is currently showing a notification
  bool _isShowingNotification = false;
  
  /// Set the scaffold messenger key
  void setMessengerKey(GlobalKey<ScaffoldMessengerState> key) {
    _messengerKey = key;
  }
  
  /// Show a notification
  void showNotification({
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) {
    final notification = NotificationMessage(
      message: message,
      type: type,
      duration: duration,
      action: action,
      actionLabel: actionLabel,
    );
    
    _notificationQueue.add(notification);
    _processQueue();
  }
  
  /// Show success notification
  void showSuccess(String message, {Duration? duration}) {
    showNotification(
      message: message,
      type: NotificationType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
  
  /// Show error notification
  void showError(String message, {Duration? duration}) {
    showNotification(
      message: message,
      type: NotificationType.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }
  
  /// Show warning notification
  void showWarning(String message, {Duration? duration}) {
    showNotification(
      message: message,
      type: NotificationType.warning,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
  
  /// Show info notification
  void showInfo(String message, {Duration? duration}) {
    showNotification(
      message: message,
      type: NotificationType.info,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
  
  /// Process the notification queue
  void _processQueue() {
    if (_isShowingNotification || _notificationQueue.isEmpty) {
      return;
    }
    
    _isShowingNotification = true;
    final notification = _notificationQueue.removeFirst();
    
    _showSnackBar(notification);
  }
  
  /// Show snackbar with consistent styling
  void _showSnackBar(NotificationMessage notification) {
    if (_messengerKey?.currentState == null) {
      // Fallback: Try to find scaffold messenger in current context
      _isShowingNotification = false;
      _processQueue();
      return;
    }
    
    final messenger = _messengerKey!.currentState!;
    
    // Clear any existing snackbar
    messenger.clearSnackBars();
    
    // Get color based on notification type
    final colors = _getNotificationColors(notification.type);
    
    // Create snackbar with consistent styling
    // Positioned under the app bar at the top
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getNotificationIcon(notification.type),
            color: colors.iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notification.message,
              style: TextStyle(
                color: colors.textColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: colors.backgroundColor,
      duration: notification.duration,
      behavior: SnackBarBehavior.floating,
      // Position at top, under the app bar (typically 56px + status bar)
      margin: const EdgeInsets.fromLTRB(16, 80, 16, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      action: notification.action != null && notification.actionLabel != null
          ? SnackBarAction(
              label: notification.actionLabel!,
              textColor: colors.actionColor,
              onPressed: notification.action!,
            )
          : null,
      onVisible: () {
        // Schedule next notification after this one is done
        Future.delayed(notification.duration + const Duration(milliseconds: 300), () {
          _isShowingNotification = false;
          _processQueue();
        });
      },
    );
    
    messenger.showSnackBar(snackBar);
  }
  
  /// Get colors for notification type
  _NotificationColors _getNotificationColors(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return _NotificationColors(
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          actionColor: Colors.white,
        );
      case NotificationType.error:
        return _NotificationColors(
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          actionColor: Colors.white,
        );
      case NotificationType.warning:
        return _NotificationColors(
          backgroundColor: Colors.orange.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          actionColor: Colors.white,
        );
      case NotificationType.info:
        return _NotificationColors(
          backgroundColor: Colors.blueGrey.shade700,
          textColor: Colors.white,
          iconColor: Colors.white,
          actionColor: Colors.white,
        );
    }
  }
  
  /// Get icon for notification type
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }
  
  /// Clear all notifications
  void clearAll() {
    _notificationQueue.clear();
    _messengerKey?.currentState?.clearSnackBars();
    _isShowingNotification = false;
  }
}

/// Notification color scheme
class _NotificationColors {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color actionColor;
  
  const _NotificationColors({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.actionColor,
  });
}