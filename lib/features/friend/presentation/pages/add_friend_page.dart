// Add/Edit Friend page
// 
// Form for creating or editing friend entries

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_template.dart';
import '../providers/friends_provider.dart';
import '../../../friendbook/presentation/providers/friend_books_provider.dart';
import '../../../friendbook/domain/entities/friend_book.dart';

/// Page for adding or editing a friend
class AddFriendPage extends ConsumerStatefulWidget {
  final String? friendId;
  
  const AddFriendPage({super.key, this.friendId});

  @override
  ConsumerState<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends ConsumerState<AddFriendPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _homeLocationController = TextEditingController();
  final _workController = TextEditingController();
  final _likesController = TextEditingController();
  final _dislikesController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _favoriteColorController = TextEditingController();
  final _socialMediaController = TextEditingController();
  final _notesController = TextEditingController();
  final _firstMetLocationController = TextEditingController();
  
  DateTime _firstMetDate = DateTime.now();
  DateTime? _birthday;
  String? _photoPath;
  double? _latitude;
  double? _longitude;
  bool _isFavorite = false;
  String _selectedTemplate = 'classic';
  List<String> _selectedFriendBookIds = [];
  Friend? _existingFriend;
  
  bool get isEditing => widget.friendId != null;
  
  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadFriend();
    }
  }
  
  void _loadFriend() async {
    final friend = await ref.read(friendsProvider.notifier).getFriendById(widget.friendId!);
    if (friend != null && mounted) {
      setState(() {
        _existingFriend = friend;
        _nameController.text = friend.name;
        _nicknameController.text = friend.nickname ?? '';
        _phoneController.text = friend.phone ?? '';
        _emailController.text = friend.email ?? '';
        _homeLocationController.text = friend.homeLocation ?? '';
        _workController.text = friend.work ?? '';
        _likesController.text = friend.likes ?? '';
        _dislikesController.text = friend.dislikes ?? '';
        _hobbiesController.text = friend.hobbies ?? '';
        _favoriteColorController.text = friend.favoriteColor ?? '';
        _socialMediaController.text = friend.socialMedia ?? '';
        _notesController.text = friend.notes ?? '';
        _firstMetLocationController.text = friend.firstMetLocation ?? '';
        _firstMetDate = friend.firstMetDate;
        _birthday = friend.birthday;
        _photoPath = friend.photoPath;
        _latitude = friend.firstMetLatitude;
        _longitude = friend.firstMetLongitude;
        _isFavorite = friend.isFavorite;
        _selectedTemplate = friend.templateType;
        _selectedFriendBookIds = List<String>.from(friend.friendBookIds);
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _homeLocationController.dispose();
    _workController.dispose();
    _likesController.dispose();
    _dislikesController.dispose();
    _hobbiesController.dispose();
    _favoriteColorController.dispose();
    _socialMediaController.dispose();
    _notesController.dispose();
    _firstMetLocationController.dispose();
    super.dispose();
  }
  
  Future<void> _saveFriend() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final friend = Friend(
        id: widget.friendId ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
        photoPath: _photoPath,
        firstMetLocation: _firstMetLocationController.text.trim().isEmpty 
            ? null : _firstMetLocationController.text.trim(),
        firstMetLatitude: _latitude,
        firstMetLongitude: _longitude,
        firstMetDate: _firstMetDate,
        birthday: _birthday,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        homeLocation: _homeLocationController.text.trim().isEmpty 
            ? null : _homeLocationController.text.trim(),
        work: _workController.text.trim().isEmpty ? null : _workController.text.trim(),
        likes: _likesController.text.trim().isEmpty ? null : _likesController.text.trim(),
        dislikes: _dislikesController.text.trim().isEmpty ? null : _dislikesController.text.trim(),
        hobbies: _hobbiesController.text.trim().isEmpty ? null : _hobbiesController.text.trim(),
        favoriteColor: _favoriteColorController.text.trim().isEmpty 
            ? null : _favoriteColorController.text.trim(),
        socialMedia: _socialMediaController.text.trim().isEmpty 
            ? null : _socialMediaController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        templateType: _selectedTemplate,
        friendBookIds: _selectedFriendBookIds,
        isFavorite: _isFavorite,
        createdAt: _existingFriend?.createdAt ?? now,
        updatedAt: now,
      );
      
      await ref.read(friendsProvider.notifier).saveFriend(friend);
      
      // Update the friend books to include this friend
      for (final bookId in _selectedFriendBookIds) {
        await ref.read(friendBooksProvider.notifier).addFriendToBook(bookId, friend.id);
      }
      
      // If editing, remove friend from books that were deselected
      if (_existingFriend != null) {
        final previousBookIds = _existingFriend!.friendBookIds;
        for (final bookId in previousBookIds) {
          if (!_selectedFriendBookIds.contains(bookId)) {
            await ref.read(friendBooksProvider.notifier).removeFriendFromBook(bookId, friend.id);
          }
        }
      }
      
      // Invalidate the friendBooks provider to refresh data
      ref.invalidate(friendBooksForFriendProvider(friend.id));
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.friendSaved)),
        );
        
        // If editing, go back to detail page, otherwise go to list
        if (isEditing) {
          context.go('/friends/${friend.id}');
        } else {
          context.go(AppRouter.friendsList);
        }
      }
    }
  }
  
  Widget _buildTemplateSelector() {
    final l10n = AppLocalizations.of(context)!;
    
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: 'classic',
          label: Text(l10n.classicTemplate),
          icon: const Icon(Icons.book),
        ),
        ButtonSegment(
          value: 'modern',
          label: Text(l10n.modernTemplate),
          icon: const Icon(Icons.smartphone),
        ),
      ],
      selected: {_selectedTemplate},
      onSelectionChanged: (Set<String> selection) {
        setState(() {
          _selectedTemplate = selection.first;
        });
      },
    );
  }
  
  Widget _buildFriendBooksSection() {
    final l10n = AppLocalizations.of(context)!;
    final friendBooksAsync = ref.watch(friendBooksProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.friendBooks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        friendBooksAsync.when(
          data: (friendBooks) {
            if (friendBooks.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Noch keine Freundebücher erstellt', // l10n.noFriendBooksYet,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: friendBooks.map((book) {
                final isSelected = _selectedFriendBookIds.contains(book.id);
                final bookColor = _getColorFromHex(book.colorHex);
                
                return FilterChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFriendBookIds.add(book.id);
                      } else {
                        _selectedFriendBookIds.remove(book.id);
                      }
                    });
                  },
                  avatar: Icon(
                    _getIconFromName(book.iconName),
                    size: 18,
                    color: isSelected ? Colors.white : bookColor,
                  ),
                  label: Text(book.name),
                  backgroundColor: bookColor.withOpacity(0.1),
                  selectedColor: bookColor,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
  
  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
  
  IconData _getIconFromName(String iconName) {
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
  
  List<Widget> _buildFormFields() {
    final l10n = AppLocalizations.of(context)!;
    final template = _selectedTemplate == 'modern' 
        ? FriendTemplate.modern() 
        : FriendTemplate.classic();
    
    final widgets = <Widget>[];
    
    // Always show name field (required)
    widgets.add(
      TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: l10n.name,
          prefixIcon: const Icon(Icons.person),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.requiredField;
          }
          return null;
        },
      ),
    );
    widgets.add(const SizedBox(height: 16));
    
    // Add fields based on template
    if (template.visibleFields.contains('nickname')) {
      widgets.add(
        TextFormField(
          controller: _nicknameController,
          decoration: InputDecoration(
            labelText: l10n.nickname,
            prefixIcon: const Icon(Icons.tag),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('phone')) {
      widgets.add(
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: l10n.phone,
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('email')) {
      widgets.add(
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: l10n.email,
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('homeLocation')) {
      widgets.add(
        TextFormField(
          controller: _homeLocationController,
          decoration: InputDecoration(
            labelText: l10n.homeLocation,
            prefixIcon: const Icon(Icons.home),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('work')) {
      widgets.add(
        TextFormField(
          controller: _workController,
          decoration: InputDecoration(
            labelText: l10n.work,
            prefixIcon: const Icon(Icons.work),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('hobbies')) {
      widgets.add(
        TextFormField(
          controller: _hobbiesController,
          decoration: InputDecoration(
            labelText: l10n.hobbies,
            prefixIcon: const Icon(Icons.sports_soccer),
          ),
          maxLines: 2,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('likes')) {
      widgets.add(
        TextFormField(
          controller: _likesController,
          decoration: InputDecoration(
            labelText: l10n.iLike,
            prefixIcon: const Icon(Icons.thumb_up),
          ),
          maxLines: 2,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('dislikes')) {
      widgets.add(
        TextFormField(
          controller: _dislikesController,
          decoration: InputDecoration(
            labelText: l10n.iDontLike,
            prefixIcon: const Icon(Icons.thumb_down),
          ),
          maxLines: 2,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('favoriteColor')) {
      widgets.add(
        TextFormField(
          controller: _favoriteColorController,
          decoration: InputDecoration(
            labelText: l10n.favoriteColor,
            prefixIcon: const Icon(Icons.palette),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('socialMedia')) {
      widgets.add(
        TextFormField(
          controller: _socialMediaController,
          decoration: InputDecoration(
            labelText: l10n.socialMedia,
            prefixIcon: const Icon(Icons.share),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    // First met location
    widgets.add(
      TextFormField(
        controller: _firstMetLocationController,
        decoration: InputDecoration(
          labelText: l10n.firstMet,
          prefixIcon: const Icon(Icons.location_on),
          suffixIcon: IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // TODO: Get current location
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.comingSoon)),
              );
            },
          ),
        ),
      ),
    );
    widgets.add(const SizedBox(height: 16));
    
    // Always show notes field
    widgets.add(
      TextFormField(
        controller: _notesController,
        decoration: InputDecoration(
          labelText: l10n.notes,
          prefixIcon: const Icon(Icons.note),
        ),
        maxLines: 3,
      ),
    );
    widgets.add(const SizedBox(height: 16));
    
    // FriendBooks selection
    widgets.add(_buildFriendBooksSection());
    
    return widgets;
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.edit : l10n.addFriend),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // If editing, go back to friend detail
            // Otherwise go back to where we came from (home or friends list)
            if (isEditing) {
              context.go('/friends/${widget.friendId}');
            } else {
              // Check if we can pop, otherwise go home
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go(AppRouter.home);
              }
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    backgroundImage: _photoPath != null 
                        ? AssetImage(_photoPath!) as ImageProvider
                        : null,
                    child: _photoPath == null 
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        color: Theme.of(context).colorScheme.onPrimary,
                        onPressed: () {
                          // TODO: Implement photo capture
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.comingSoon)),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Template selector
            _buildTemplateSelector(),
            const SizedBox(height: 24),
            
            // Form fields
            ..._buildFormFields(),
            const SizedBox(height: 24),
            
            // Save button
            ElevatedButton.icon(
              onPressed: _saveFriend,
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            
            // Cancel button
            OutlinedButton(
              onPressed: () {
                // Same logic as back button
                if (isEditing) {
                  context.go('/friends/${widget.friendId}');
                } else {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    context.go(AppRouter.home);
                  }
                }
              },
              child: Text(l10n.cancel),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}