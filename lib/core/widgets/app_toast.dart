// Custom toast notification widget
// 
// Provides consistent toast/snackbar appearance
// positioned below the app bar

import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Custom toast widget for notifications
class AppToast extends StatelessWidget {
  /// The message to display
  final String message;
  
  /// The type of notification
  final NotificationType type;
  
  /// Optional action callback
  final VoidCallback? onAction;
  
  /// Optional action label
  final String? actionLabel;
  
  const AppToast({
    super.key,
    required this.message,
    this.type = NotificationType.info,
    this.onAction,
    this.actionLabel,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: colors.iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: colors.actionColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(0, 0),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Get icon for the notification type
  IconData _getIcon() {
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
  
  /// Get colors for the notification type
  _ToastColors _getColors(ThemeData theme) {
    switch (type) {
      case NotificationType.success:
        return _ToastColors(
          backgroundColor: Colors.green.shade50,
          textColor: Colors.green.shade900,
          iconColor: Colors.green.shade700,
          actionColor: Colors.green.shade700,
        );
      case NotificationType.error:
        return _ToastColors(
          backgroundColor: Colors.red.shade50,
          textColor: Colors.red.shade900,
          iconColor: Colors.red.shade700,
          actionColor: Colors.red.shade700,
        );
      case NotificationType.warning:
        return _ToastColors(
          backgroundColor: Colors.orange.shade50,
          textColor: Colors.orange.shade900,
          iconColor: Colors.orange.shade700,
          actionColor: Colors.orange.shade700,
        );
      case NotificationType.info:
        return _ToastColors(
          backgroundColor: Colors.blue.shade50,
          textColor: Colors.blue.shade900,
          iconColor: Colors.blue.shade700,
          actionColor: Colors.blue.shade700,
        );
    }
  }
}

/// Toast color scheme
class _ToastColors {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color actionColor;
  
  const _ToastColors({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.actionColor,
  });
}