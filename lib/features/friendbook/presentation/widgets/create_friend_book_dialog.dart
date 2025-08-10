// Create/Edit FriendBook dialog
// 
// Dialog for creating or editing a friend book

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/friend_book.dart';
import '../providers/friend_books_provider.dart';

/// Dialog for creating or editing a friend book
class CreateFriendBookDialog extends ConsumerStatefulWidget {
  final FriendBook? friendBook;
  
  const CreateFriendBookDialog({super.key, this.friendBook});

  @override
  ConsumerState<CreateFriendBookDialog> createState() => _CreateFriendBookDialogState();
}

class _CreateFriendBookDialogState extends ConsumerState<CreateFriendBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedColor = '#2196F3'; // Default blue
  String _selectedIcon = 'group'; // Default group icon
  
  bool get isEditing => widget.friendBook != null;
  
  // Available colors
  final List<String> _colors = [
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];
  
  // Available icons with names
  final List<Map<String, dynamic>> _icons = [
    {'name': 'group', 'icon': Icons.group},
    {'name': 'family', 'icon': Icons.family_restroom},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'sports', 'icon': Icons.sports_soccer},
    {'name': 'music', 'icon': Icons.music_note},
    {'name': 'travel', 'icon': Icons.flight},
    {'name': 'gaming', 'icon': Icons.sports_esports},
    {'name': 'food', 'icon': Icons.restaurant},
    {'name': 'party', 'icon': Icons.celebration},
    {'name': 'heart', 'icon': Icons.favorite},
  ];
  
  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.friendBook!.name;
      _descriptionController.text = widget.friendBook!.description ?? '';
      _selectedColor = widget.friendBook!.colorHex;
      _selectedIcon = widget.friendBook!.iconName;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
  
  void _saveFriendBook() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final friendBook = FriendBook(
        id: widget.friendBook?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null : _descriptionController.text.trim(),
        colorHex: _selectedColor,
        iconName: _selectedIcon,
        friendIds: widget.friendBook?.friendIds ?? [],
        createdAt: widget.friendBook?.createdAt ?? now,
        updatedAt: now,
      );
      
      ref.read(friendBooksProvider.notifier).saveFriendBook(friendBook);
      
      Navigator.pop(context);
      
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Freundebuch aktualisiert' : 'Freundebuch erstellt'
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.book,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Freundebuch bearbeiten' : l10n.createFriendBook,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.friendBookName,
                          prefixIcon: const Icon(Icons.book),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.requiredField;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Beschreibung',
                          prefixIcon: const Icon(Icons.description),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      
                      // Icon selector
                      Text(
                        'Symbol auswählen',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _icons.length,
                          itemBuilder: (context, index) {
                            final iconData = _icons[index];
                            final isSelected = _selectedIcon == iconData['name'];
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedIcon = iconData['name'];
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.outline,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    iconData['icon'],
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Color selector
                      Text(
                        'Farbe auswählen',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _colors.map((colorHex) {
                          final color = _getColorFromHex(colorHex);
                          final isSelected = _selectedColor == colorHex;
                          
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedColor = colorHex;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveFriendBook,
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}