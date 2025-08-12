// FriendBook Selector Widget
// 
// Dropdown selector for choosing which friendbook to display on map
// Version 0.4.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../friendbook/domain/entities/friend_book.dart';
import '../../../friendbook/presentation/providers/friend_books_provider.dart';

/// Dropdown selector for friendbooks
class FriendBookSelector extends ConsumerWidget {
  final String? selectedFriendBookId;
  final Function(String?) onChanged;
  
  const FriendBookSelector({
    super.key,
    required this.selectedFriendBookId,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final friendBooksAsync = ref.watch(friendBooksProvider);
    
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: friendBooksAsync.when(
          data: (friendBooks) {
            // Add "All friends" option
            final allOption = FriendBook(
              id: 'all',
              name: 'Alle Freunde',
              colorHex: theme.colorScheme.primary.value.toRadixString(16),
              iconName: 'groups',
              friendIds: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            final options = [allOption, ...friendBooks];
            
            return DropdownButton<String?>(
              value: selectedFriendBookId,
              hint: Row(
                children: [
                  Icon(
                    Icons.book,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text('Freundesbuch wählen'),
                ],
              ),
              isExpanded: true,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(12),
              items: options.map((book) {
                final color = book.id == 'all'
                    ? theme.colorScheme.primary
                    : _parseColor(book.colorHex, theme.colorScheme.primary);
                
                return DropdownMenuItem<String?>(
                  value: book.id == 'all' ? null : book.id,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getIconData(book.iconName),
                          size: 16,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              book.name,
                              style: TextStyle(
                                fontWeight: selectedFriendBookId == book.id
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (book.id != 'all')
                              Text(
                                '${book.friendIds.length} Freunde',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (selectedFriendBookId == book.id ||
                          (selectedFriendBookId == null && book.id == 'all'))
                        Icon(
                          Icons.check,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              selectedItemBuilder: (context) {
                return options.map((book) {
                  final color = book.id == 'all'
                      ? theme.colorScheme.primary
                      : _parseColor(book.colorHex, theme.colorScheme.primary);
                  
                  return Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getIconData(book.iconName),
                          size: 16,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        book.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            );
          },
          loading: () => const SizedBox(
            width: 150,
            child: LinearProgressIndicator(),
          ),
          error: (error, stack) => Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              const Text('Fehler beim Laden'),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Parse color from hex string safely
  Color _parseColor(String colorHex, Color fallback) {
    try {
      // Remove any leading hash if present
      String hex = colorHex.replaceAll('#', '');
      
      // Check if it already has 0xFF prefix
      if (hex.startsWith('0xFF') || hex.startsWith('0xff')) {
        return Color(int.parse(hex));
      }
      
      // Add alpha if not present
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      
      // Parse the color
      return Color(int.parse('0x$hex'));
    } catch (e) {
      // Return fallback color if parsing fails
      return fallback;
    }
  }
  
  /// Get icon data from icon name
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'family':
        return Icons.family_restroom;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'sports':
        return Icons.sports_soccer;
      case 'music':
        return Icons.music_note;
      case 'travel':
        return Icons.flight;
      case 'food':
        return Icons.restaurant;
      case 'games':
        return Icons.games;
      case 'groups':
        return Icons.groups;
      default:
        return Icons.book;
    }
  }
}