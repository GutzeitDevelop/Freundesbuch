// Snackbar Utilities
// 
// Centralized snackbar management - ALL snackbars shown at TOP
// Version 0.5.3

import 'package:flutter/material.dart';

/// Utility class for showing snackbars at the TOP of the screen
class SnackbarUtils {
  /// Show a snackbar at the TOP of the screen
  static void showTopSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _TopSnackbar(
        message: message,
        duration: duration,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  /// Show error snackbar at TOP
  static void showError(BuildContext context, String message) {
    showTopSnackbar(
      context,
      message,
      backgroundColor: Colors.red.shade600,
      textColor: Colors.white,
      icon: Icons.error_outline,
    );
  }

  /// Show success snackbar at TOP
  static void showSuccess(BuildContext context, String message) {
    showTopSnackbar(
      context,
      message,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
      icon: Icons.check_circle_outline,
    );
  }

  /// Show info snackbar at TOP
  static void showInfo(BuildContext context, String message) {
    showTopSnackbar(
      context,
      message,
      backgroundColor: Colors.blue.shade600,
      textColor: Colors.white,
      icon: Icons.info_outline,
    );
  }
}

/// Custom top snackbar widget
class _TopSnackbar extends StatefulWidget {
  final String message;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _TopSnackbar({
    required this.message,
    required this.duration,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<_TopSnackbar> createState() => _TopSnackbarState();
}

class _TopSnackbarState extends State<_TopSnackbar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    
    return Positioned(
      top: safeAreaTop + 56, // Below AppBar
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            color: widget.backgroundColor ?? Colors.grey.shade800,
            child: InkWell(
              onTap: widget.onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.textColor ?? Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor ?? Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: widget.onAction,
                        child: Text(
                          widget.actionLabel!,
                          style: TextStyle(
                            color: widget.textColor ?? Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}