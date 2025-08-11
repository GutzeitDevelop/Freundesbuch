// Consistent action button widget
// 
// Provides standardized button styling and placement
// across all pages for a smooth user experience

import 'package:flutter/material.dart';

/// Button style types
enum ActionButtonStyle {
  primary,    // Main action button (filled)
  secondary,  // Secondary action (outlined)
  danger,     // Dangerous action (red)
  text,       // Text only button
}

/// Button size types
enum ActionButtonSize {
  small,
  medium,
  large,
  fullWidth,
}

/// Consistent action button for standardized UI
class ConsistentActionButton extends StatelessWidget {
  /// Button label
  final String label;
  
  /// Button icon (optional)
  final IconData? icon;
  
  /// Callback when pressed
  final VoidCallback? onPressed;
  
  /// Button style
  final ActionButtonStyle style;
  
  /// Button size
  final ActionButtonSize size;
  
  /// Whether the button is loading
  final bool isLoading;
  
  /// Custom width (overrides size)
  final double? width;
  
  /// Custom height (overrides size)
  final double? height;
  
  /// Tooltip text
  final String? tooltip;
  
  const ConsistentActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.style = ActionButtonStyle.primary,
    this.size = ActionButtonSize.medium,
    this.isLoading = false,
    this.width,
    this.height,
    this.tooltip,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get button dimensions
    final dimensions = _getButtonDimensions(context);
    
    // Get button styling
    final buttonStyle = _getButtonStyle(context, theme);
    
    // Build button child
    Widget buttonChild = _buildButtonChild(theme);
    
    // Wrap with loading indicator if needed
    if (isLoading) {
      buttonChild = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            style == ActionButtonStyle.primary
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
        ),
      );
    }
    
    // Build the button
    Widget button;
    
    switch (style) {
      case ActionButtonStyle.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
        
      case ActionButtonStyle.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
        
      case ActionButtonStyle.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
        
      case ActionButtonStyle.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
    }
    
    // Apply size constraints
    if (width != null || height != null || size == ActionButtonSize.fullWidth) {
      button = SizedBox(
        width: width ?? dimensions.width,
        height: height ?? dimensions.height,
        child: button,
      );
    }
    
    // Add tooltip if provided
    if (tooltip != null && !isLoading) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
  
  /// Build button child widget
  Widget _buildButtonChild(ThemeData theme) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: _getTextStyle(theme),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    
    return Text(
      label,
      style: _getTextStyle(theme),
      overflow: TextOverflow.ellipsis,
    );
  }
  
  /// Get button dimensions based on size
  ({double? width, double? height}) _getButtonDimensions(BuildContext context) {
    switch (size) {
      case ActionButtonSize.small:
        return (width: null, height: 36.0);
      case ActionButtonSize.medium:
        return (width: null, height: 44.0);
      case ActionButtonSize.large:
        return (width: null, height: 52.0);
      case ActionButtonSize.fullWidth:
        return (width: double.infinity, height: 48.0);
    }
  }
  
  /// Get icon size based on button size
  double _getIconSize() {
    switch (size) {
      case ActionButtonSize.small:
        return 18;
      case ActionButtonSize.medium:
        return 20;
      case ActionButtonSize.large:
        return 24;
      case ActionButtonSize.fullWidth:
        return 20;
    }
  }
  
  /// Get text style based on button size
  TextStyle? _getTextStyle(ThemeData theme) {
    switch (size) {
      case ActionButtonSize.small:
        return theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case ActionButtonSize.medium:
        return theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case ActionButtonSize.large:
        return theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case ActionButtonSize.fullWidth:
        return theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }
  
  /// Get button style based on style type
  ButtonStyle _getButtonStyle(BuildContext context, ThemeData theme) {
    switch (style) {
      case ActionButtonStyle.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
        
      case ActionButtonStyle.secondary:
        return OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
        
      case ActionButtonStyle.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
        
      case ActionButtonStyle.text:
        return TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
    }
  }
}