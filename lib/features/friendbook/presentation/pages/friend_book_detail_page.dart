// FriendBook detail page
// 
// Shows details of a friend book and its members
// Version 0.3.0 - Enhanced with centralized services

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../core/widgets/consistent_action_button.dart';
import '../../domain/entities/friend_book.dart';
import '../providers/friend_books_provider.dart';
import '../../../friend/domain/entities/friend.dart';
import '../../../friend/presentation/providers/friends_provider.dart';
import '../../../friend/presentation/widgets/friend_list_tile.dart';
import '../widgets/create_friend_book_dialog.dart';

/// Page showing friend book details and members
class FriendBookDetailPage extends ConsumerStatefulWidget {
  final String friendBookId;
  
  const FriendBookDetailPage({super.key, required this.friendBookId});

  @override
  ConsumerState<FriendBookDetailPage> createState() => _FriendBookDetailPageState();
}

class _FriendBookDetailPageState extends ConsumerState<FriendBookDetailPage> {
  FriendBook? _friendBook;
  List<Friend> _friendsInBook = [];
  List<Friend> _availableFriends = [];
  bool _isAddingFriends = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFriendBook();
    });
  }
  
  Future<void> _loadFriendBook() async {
    final book = await ref.read(friendBooksProvider.notifier).getFriendBookById(widget.friendBookId);
    if (book != null && mounted) {
      setState(() {
        _friendBook = book;
      });
      _loadFriends();
    }
  }
  
  Future<void> _loadFriends() async {
    if (_friendBook == null) return;
    
    // Ensure friends are loaded first
    await ref.read(friendsProvider.notifier).loadFriends();
    
    // Now get the friends
    final allFriendsAsync = ref.read(friendsProvider);
    if (allFriendsAsync.hasValue) {
      final allFriends = allFriendsAsync.value ?? [];
      final friendsInBook = allFriends.where((f) => _friendBook!.friendIds.contains(f.id)).toList();
      final availableFriends = allFriends.where((f) => !_friendBook!.friendIds.contains(f.id)).toList();
      
      if (mounted) {
        setState(() {
          _friendsInBook = friendsInBook;
          _availableFriends = availableFriends;
        });
      }
    }
  }
  
  Future<void> _addFriendToBook(String friendId) async {
    await ref.read(friendBooksProvider.notifier).addFriendToBook(widget.friendBookId, friendId);
    
    // Also update the friend's friendBookIds
    final friend = _availableFriends.firstWhere((f) => f.id == friendId);
    final updatedFriend = friend.copyWith(
      friendBookIds: [...friend.friendBookIds, widget.friendBookId],
    );
    await ref.read(friendsProvider.notifier).saveFriend(updatedFriend);
    
    // Invalidate the friend count provider to update the display
    ref.invalidate(friendCountInBookProvider(widget.friendBookId));
    
    await _loadFriendBook();
  }
  
  Future<void> _removeFriendFromBook(String friendId) async {
    await ref.read(friendBooksProvider.notifier).removeFriendFromBook(widget.friendBookId, friendId);
    
    // Also update the friend's friendBookIds
    final friend = _friendsInBook.firstWhere((f) => f.id == friendId);
    final updatedFriend = friend.copyWith(
      friendBookIds: friend.friendBookIds.where((id) => id != widget.friendBookId).toList(),
    );
    await ref.read(friendsProvider.notifier).saveFriend(updatedFriend);
    
    // Invalidate the friend count provider to update the display
    ref.invalidate(friendCountInBookProvider(widget.friendBookId));
    
    await _loadFriendBook();
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
  
  void _showAddFriendsDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Freunde hinzufügen'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _availableFriends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, size: 48),
                      const SizedBox(height: 16),
                      Text('Alle Freunde sind bereits im Buch'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _availableFriends.length,
                  itemBuilder: (context, index) {
                    final friend = _availableFriends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: friend.photoPath != null 
                            ? FileImage(File(friend.photoPath!)) as ImageProvider
                            : null,
                        child: friend.photoPath == null
                            ? Text(friend.name[0].toUpperCase())
                            : null,
                      ),
                      title: Text(friend.name),
                      subtitle: friend.nickname != null 
                          ? Text('"${friend.nickname}"')
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () async {
                          await _addFriendToBook(friend.id);
                          Navigator.pop(context);
                          SnackbarUtils.showSuccess(this.context, 'Freund hinzugefügt');
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Schließen'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navigationService = ref.read(navigationServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    if (_friendBook == null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          navigationService.navigateBack(context);
        },
        child: Scaffold(
          appBar: StandardAppBar(
            title: 'Freundebuch',
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    final bookColor = _getColorFromHex(_friendBook!.colorHex);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        navigationService.navigateBack(context);
      },
      child: Scaffold(
        appBar: StandardAppBar(
          title: _friendBook!.name,
          backgroundColor: bookColor.withAlpha(26),
          actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Show edit dialog
              showDialog(
                context: context,
                builder: (context) => CreateFriendBookDialog(friendBook: _friendBook),
              ).then((_) {
                // Reload after editing
                _loadFriendBook();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with book info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bookColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: bookColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _getIconFromName(_friendBook!.iconName),
                  size: 64,
                  color: bookColor,
                ),
                const SizedBox(height: 8),
                if (_friendBook!.description != null) ...[
                  Text(
                    _friendBook!.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '${_friendsInBook.length} Freunde',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: bookColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Friends list
          Expanded(
            child: _friendsInBook.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Noch keine Freunde im Buch',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Füge Freunde hinzu um loszulegen',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showAddFriendsDialog,
                          icon: const Icon(Icons.person_add),
                          label: Text('Freunde hinzufügen'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _friendsInBook.length,
                    itemBuilder: (context, index) {
                      final friend = _friendsInBook[index];
                      return Dismissible(
                        key: Key(friend.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Aus Buch entfernen'),
                              content: Text('Möchten Sie ${friend.name} aus diesem Freundebuch entfernen?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: Text('Entfernen'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          await _removeFriendFromBook(friend.id);
                          SnackbarUtils.showInfo(context, 'Freund aus Buch entfernt');
                        },
                        child: FriendListTile(
                          friend: friend,
                          onTap: () => navigationService.navigateTo(context, '/friends/${friend.id}'),
                          onFavoriteToggle: () {
                            ref.read(friendsProvider.notifier).toggleFavorite(friend.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendsDialog,
        tooltip: 'Freunde hinzufügen',
        child: const Icon(Icons.person_add),
      ),
      ),
    );
  }
}