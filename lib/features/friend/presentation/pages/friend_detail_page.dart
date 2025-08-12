// Friend detail page
// 
// Displays detailed information about a friend

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/photo_service.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_template.dart';
import '../providers/friends_provider.dart';
import '../../../friendbook/presentation/providers/friend_books_provider.dart';
import '../../../template/presentation/providers/template_provider.dart';

/// Page displaying friend details
class FriendDetailPage extends ConsumerStatefulWidget {
  final String friendId;
  
  const FriendDetailPage({super.key, required this.friendId});

  @override
  ConsumerState<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends ConsumerState<FriendDetailPage> {
  String? _resolvedPhotoPath;
  
  @override
  void initState() {
    super.initState();
    // Load friend initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFriend();
    });
  }
  
  Future<void> _loadFriend() async {
    // Refresh the friends provider to get latest data
    await ref.read(friendsProvider.notifier).loadFriends();
    // Invalidate the friend books provider to refresh
    ref.invalidate(friendBooksForFriendProvider(widget.friendId));
    
    // Resolve photo path
    final friendsAsync = ref.read(friendsProvider);
    if (friendsAsync.hasValue) {
      final friend = friendsAsync.value?.firstWhere(
        (f) => f.id == widget.friendId,
        orElse: () => Friend(
          id: '',
          name: '',
          firstMetDate: DateTime.now(),
          templateType: 'classic',
          friendBookIds: [],
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (friend != null && friend.id.isNotEmpty && friend.photoPath != null) {
        final resolvedPath = await PhotoService.resolvePhotoPath(friend.photoPath);
        if (mounted) {
          setState(() {
            _resolvedPhotoPath = resolvedPath;
          });
        }
      }
    }
  }
  
  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.yes,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      // Delete friend and get the friend data
      final deletedFriend = await ref.read(friendsProvider.notifier).deleteFriend(widget.friendId);
      
      // Update all friend books that contained this friend
      if (deletedFriend != null) {
        for (final bookId in deletedFriend.friendBookIds) {
          await ref.read(friendBooksProvider.notifier).removeFriendFromBook(bookId, widget.friendId);
          // Invalidate the friend count for this book
          ref.invalidate(friendCountInBookProvider(bookId));
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.friendDeleted)),
        );
        context.go(AppRouter.friendsList);
      }
    }
  }
  
  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCustomFieldDisplay(CustomField field, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    
    String displayValue;
    IconData icon;
    
    switch (field.type) {
      case CustomFieldType.boolean:
        displayValue = value == true ? 'Ja' : 'Nein';
        icon = value == true ? Icons.check_circle : Icons.cancel;
        break;
      case CustomFieldType.date:
        if (value is DateTime) {
          final dateFormat = DateFormat.yMMMMd(Localizations.localeOf(context).languageCode);
          displayValue = dateFormat.format(value);
        } else {
          displayValue = value.toString();
        }
        icon = Icons.calendar_today;
        break;
      case CustomFieldType.multiSelect:
        if (value is List) {
          displayValue = value.join(', ');
        } else {
          displayValue = value.toString();
        }
        icon = Icons.checklist;
        break;
      case CustomFieldType.email:
        displayValue = value.toString();
        icon = Icons.email;
        break;
      case CustomFieldType.url:
        displayValue = value.toString();
        icon = Icons.link;
        break;
      case CustomFieldType.number:
        displayValue = value.toString();
        icon = Icons.numbers;
        break;
      case CustomFieldType.select:
        displayValue = value.toString();
        icon = Icons.list;
        break;
      case CustomFieldType.text:
      default:
        displayValue = value.toString();
        icon = Icons.edit;
        break;
    }
    
    return _buildInfoRow(icon, field.label, displayValue);
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Watch the friends provider to get real-time updates
    final friendsAsync = ref.watch(friendsProvider);
    final friend = friendsAsync.value?.firstWhere(
      (f) => f.id == widget.friendId,
      orElse: () => Friend(
        id: '',
        name: '',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    if (friend == null || friend.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final _friend = friend;
    
    final dateFormat = DateFormat.yMMMMd(Localizations.localeOf(context).languageCode);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_friend!.name),
        actions: [
          IconButton(
            icon: Icon(
              _friend!.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _friend!.isFavorite ? Colors.red : null,
            ),
            onPressed: () async {
              await ref.read(friendsProvider.notifier).toggleFavorite(_friend!.id);
              _loadFriend(); // Reload to update UI
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  context.go('/friends/${_friend.id}/edit');
                  break;
                case 'delete':
                  _confirmDelete();
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Photo section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: _resolvedPhotoPath != null && _resolvedPhotoPath!.isNotEmpty
                        ? FileImage(File(_resolvedPhotoPath!)) as ImageProvider
                        : null,
                    child: _resolvedPhotoPath == null || _resolvedPhotoPath!.isEmpty
                        ? Text(
                            _friend!.name.isNotEmpty ? _friend!.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _friend!.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (_friend!.nickname != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '"${_friend!.nickname}"',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Information section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First met section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.celebration,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.firstMet,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            dateFormat.format(_friend!.firstMetDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (_friend!.firstMetLocation != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _friend!.firstMetLocation!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Get template to know which fields to display
                  Consumer(
                    builder: (context, ref, child) {
                      final templatesAsync = ref.watch(templateProvider);
                      return templatesAsync.when(
                        data: (templates) {
                          // Find the template for this friend
                          final template = templates.firstWhere(
                            (t) => t.id == _friend.templateType,
                            orElse: () => FriendTemplate.classic(),
                          );
                          
                          final widgets = <Widget>[];
                          
                          // Contact information (if in template)
                          final hasContact = template.visibleFields.contains('phone') || 
                                           template.visibleFields.contains('email');
                          if (hasContact && (_friend.phone != null || _friend.email != null)) {
                            widgets.add(Text(
                              'Kontakt',
                              style: Theme.of(context).textTheme.titleMedium,
                            ));
                            widgets.add(const SizedBox(height: 8));
                            if (template.visibleFields.contains('phone')) {
                              widgets.add(_buildInfoRow(Icons.phone, l10n.phone, _friend.phone));
                            }
                            if (template.visibleFields.contains('email')) {
                              widgets.add(_buildInfoRow(Icons.email, l10n.email, _friend.email));
                            }
                            widgets.add(const Divider(height: 32));
                          }
                          
                          // Personal information (if in template)
                          final hasPersonal = template.visibleFields.contains('birthday') ||
                                            template.visibleFields.contains('homeLocation') ||
                                            template.visibleFields.contains('work');
                          if (hasPersonal && (_friend.birthday != null || _friend.homeLocation != null || _friend.work != null)) {
                            widgets.add(Text(
                              'Persönliches',
                              style: Theme.of(context).textTheme.titleMedium,
                            ));
                            widgets.add(const SizedBox(height: 8));
                            if (template.visibleFields.contains('birthday') && _friend.birthday != null) {
                              widgets.add(_buildInfoRow(
                                Icons.cake,
                                l10n.birthday,
                                dateFormat.format(_friend.birthday!),
                              ));
                            }
                            if (template.visibleFields.contains('homeLocation')) {
                              widgets.add(_buildInfoRow(Icons.home, l10n.homeLocation, _friend.homeLocation));
                            }
                            if (template.visibleFields.contains('work')) {
                              widgets.add(_buildInfoRow(Icons.work, l10n.work, _friend.work));
                            }
                            widgets.add(const Divider(height: 32));
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widgets,
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                  
                  // Friend books
                  Consumer(
                    builder: (context, ref, child) {
                      final friendBooksAsync = ref.watch(friendBooksForFriendProvider(_friend.id));
                      return friendBooksAsync.when(
                        data: (friendBooks) {
                          if (friendBooks.isEmpty) return const SizedBox.shrink();
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.friendBooks,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: friendBooks.map((book) {
                                  final bookColor = Color(int.parse(book.colorHex.replaceFirst('#', '0xFF')));
                                  return ActionChip(
                                    avatar: Icon(
                                      Icons.book,
                                      size: 18,
                                      color: bookColor,
                                    ),
                                    label: Text(book.name),
                                    backgroundColor: bookColor.withValues(alpha: 0.1),
                                    onPressed: () {
                                      context.go('/friendbooks/${book.id}');
                                    },
                                  );
                                }).toList(),
                              ),
                              const Divider(height: 32),
                            ],
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                  
                  // Preferences and other fields based on template
                  Consumer(
                    builder: (context, ref, child) {
                      final templatesAsync = ref.watch(templateProvider);
                      return templatesAsync.when(
                        data: (templates) {
                          final template = templates.firstWhere(
                            (t) => t.id == _friend.templateType,
                            orElse: () => FriendTemplate.classic(),
                          );
                          
                          final widgets = <Widget>[];
                          
                          // Preferences (if in template)
                          final hasPreferences = template.visibleFields.contains('likes') ||
                                               template.visibleFields.contains('dislikes') ||
                                               template.visibleFields.contains('hobbies') ||
                                               template.visibleFields.contains('favoriteColor');
                          if (hasPreferences && (_friend.likes != null || _friend.dislikes != null || 
                              _friend.hobbies != null || _friend.favoriteColor != null)) {
                            widgets.add(Text(
                              'Vorlieben',
                              style: Theme.of(context).textTheme.titleMedium,
                            ));
                            widgets.add(const SizedBox(height: 8));
                            if (template.visibleFields.contains('likes')) {
                              widgets.add(_buildInfoRow(Icons.thumb_up, l10n.iLike, _friend.likes));
                            }
                            if (template.visibleFields.contains('dislikes')) {
                              widgets.add(_buildInfoRow(Icons.thumb_down, l10n.iDontLike, _friend.dislikes));
                            }
                            if (template.visibleFields.contains('hobbies')) {
                              widgets.add(_buildInfoRow(Icons.sports_soccer, l10n.hobbies, _friend.hobbies));
                            }
                            if (template.visibleFields.contains('favoriteColor')) {
                              widgets.add(_buildInfoRow(Icons.palette, l10n.favoriteColor, _friend.favoriteColor));
                            }
                            widgets.add(const Divider(height: 32));
                          }
                          
                          // Social media (if in template)
                          if (template.visibleFields.contains('socialMedia') && _friend.socialMedia != null) {
                            widgets.add(_buildInfoRow(Icons.share, l10n.socialMedia, _friend.socialMedia));
                            widgets.add(const Divider(height: 32));
                          }
                          
                          // Custom fields
                          if (template.customFields.isNotEmpty && _friend.customFieldValues != null) {
                            widgets.add(Text(
                              'Benutzerdefinierte Felder',
                              style: Theme.of(context).textTheme.titleMedium,
                            ));
                            widgets.add(const SizedBox(height: 8));
                            for (final field in template.customFields) {
                              final value = _friend.customFieldValues![field.name];
                              widgets.add(_buildCustomFieldDisplay(field, value));
                            }
                            widgets.add(const Divider(height: 32));
                          }
                          
                          // Notes (if in template) - always show at the end
                          if (template.visibleFields.contains('notes') && _friend.notes != null) {
                            widgets.add(Text(
                              l10n.notes,
                              style: Theme.of(context).textTheme.titleMedium,
                            ));
                            widgets.add(const SizedBox(height: 8));
                            widgets.add(Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_friend.notes!),
                            ));
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widgets,
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
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