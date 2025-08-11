// Friends list page
// 
// Displays list of all friends with search and filtering
// Version 0.3.0 - Enhanced with centralized services

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../domain/entities/friend.dart';
import '../providers/friends_provider.dart';
import '../widgets/friend_list_tile.dart';

/// Page displaying list of friends
class FriendsListPage extends ConsumerStatefulWidget {
  const FriendsListPage({super.key});

  @override
  ConsumerState<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends ConsumerState<FriendsListPage> {
  final _searchController = TextEditingController();
  bool _showFavoritesOnly = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged(String query) {
    ref.read(friendsProvider.notifier).searchFriends(query);
  }
  
  void _toggleFavoritesFilter() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });
    
    if (_showFavoritesOnly) {
      ref.read(friendsProvider.notifier).loadFavoriteFriends();
    } else {
      ref.read(friendsProvider.notifier).loadFriends();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final friendsState = ref.watch(friendsProvider);
    final navigationService = ref.read(navigationServiceProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        navigationService.navigateBack(context);
      },
      child: Scaffold(
        appBar: StandardAppBar(
          title: l10n.myFriends,
          actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : null,
            ),
            onPressed: _toggleFavoritesFilter,
            tooltip: 'Filter favorites',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Friends list
          Expanded(
            child: friendsState.when(
              data: (friends) {
                if (friends.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noFriendsYet,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addYourFirstFriend,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.go(AppRouter.addFriend),
                          icon: const Icon(Icons.person_add),
                          label: Text(l10n.addFriend),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return FriendListTile(
                      friend: friend,
                      onTap: () => navigationService.navigateTo(context, '/friends/${friend.id}'),
                      onFavoriteToggle: () {
                        ref.read(friendsProvider.notifier).toggleFavorite(friend.id);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(friendsProvider.notifier).loadFriends();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigationService.navigateTo(context, AppRouter.addFriend),
        tooltip: l10n.addFriend,
        child: const Icon(Icons.person_add),
      ),
      ),
    );
  }
}