// FriendBook list tile widget
// 
// Displays a single friend book in the list

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/friend_book.dart';
import '../providers/friend_books_provider.dart';

/// List tile widget for displaying a friend book
class FriendBookListTile extends ConsumerWidget {
  final FriendBook friendBook;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const FriendBookListTile({
    super.key,
    required this.friendBook,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  
  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // Default color if parsing fails
    }
  }
  
  IconData _getIconFromName(String iconName) {
    // Map icon names to actual icons
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
      case 'gaming':
        return Icons.sports_esports;
      case 'food':
        return Icons.restaurant;
      case 'party':
        return Icons.celebration;
      case 'heart':
        return Icons.favorite;
      default:
        return Icons.group;
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final friendCountAsync = ref.watch(friendCountInBookProvider(friendBook.id));
    final bookColor = _getColorFromHex(friendBook.colorHex);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon with color background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: bookColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconFromName(friendBook.iconName),
                  color: bookColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friendBook.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (friendBook.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        friendBook.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    friendCountAsync.when(
                      data: (count) => Text(
                        '$count Freunde',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      loading: () => Text(
                        'Wird geladen...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              
              // Actions menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}