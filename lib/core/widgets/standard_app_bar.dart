// Standardized app bar widget
// 
// Provides consistent app bar styling and behavior
// across all pages with back button handling

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';

/// Standardized app bar for consistent UI
class StandardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  /// Title of the app bar
  final String title;
  
  /// Optional subtitle
  final String? subtitle;
  
  /// Actions to display in the app bar
  final List<Widget>? actions;
  
  /// Whether to show the back button
  final bool showBackButton;
  
  /// Custom leading widget
  final Widget? leading;
  
  /// Whether the title should be centered
  final bool centerTitle;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Elevation
  final double elevation;
  
  /// Custom back button callback
  final VoidCallback? onBack;
  
  const StandardAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = true,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 2,
    this.onBack,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationService = ref.read(navigationServiceProvider);
    final theme = Theme.of(context);
    
    // Determine if we should show back button
    final shouldShowBack = showBackButton && 
        (navigationService.canGoBack() || Navigator.of(context).canPop());
    
    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      elevation: elevation,
      leading: leading ?? (shouldShowBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack ?? () {
                navigationService.navigateBack(context);
              },
              tooltip: 'Zurück',
            )
          : null),
      actions: actions,
      // Add visual separator below app bar
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: theme.dividerColor.withAlpha(26),
        ),
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}