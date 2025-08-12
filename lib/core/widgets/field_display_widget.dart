// Shared field display widget
// 
// Provides consistent field display across profile and friend pages
// Version 0.3.3

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Widget for displaying a field with icon, label and value
/// Used consistently across profile and friend detail pages
class FieldDisplayWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool copyable;
  final VoidCallback? onTap;
  final Color? iconColor;
  
  const FieldDisplayWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
    this.onTap,
    this.iconColor,
  });
  
  @override
  Widget build(BuildContext context) {
    // Don't show if value is null or empty
    if (value == null || value!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.primary,
      ),
      title: Text(label),
      subtitle: Text(value!),
      onTap: copyable
          ? () {
              Clipboard.setData(ClipboardData(text: value!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label kopiert'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          : onTap,
      trailing: copyable
          ? Icon(
              Icons.copy,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : null,
    );
  }
}

/// Widget for displaying a field in a compact row format
/// Used in friend detail page
class CompactFieldDisplay extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? iconColor;
  
  const CompactFieldDisplay({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });
  
  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a date field
class DateFieldDisplay extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? date;
  final bool copyable;
  final Color? iconColor;
  
  const DateFieldDisplay({
    super.key,
    required this.icon,
    required this.label,
    required this.date,
    this.copyable = false,
    this.iconColor,
  });
  
  @override
  Widget build(BuildContext context) {
    if (date == null) {
      return const SizedBox.shrink();
    }
    
    final formattedDate = DateFormat('dd.MM.yyyy').format(date!);
    
    return FieldDisplayWidget(
      icon: icon,
      label: label,
      value: formattedDate,
      copyable: copyable,
      iconColor: iconColor,
    );
  }
}

/// Section header widget for grouping fields
class FieldSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;
  
  const FieldSectionHeader({
    super.key,
    required this.title,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}