// FriendBooks list page
// 
// Displays all friend books with management options
// Version 0.3.0 - Enhanced with centralized services

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../core/widgets/consistent_action_button.dart';
import '../../domain/entities/friend_book.dart';
import '../providers/friend_books_provider.dart';
import '../widgets/friend_book_list_tile.dart';
import '../widgets/create_friend_book_dialog.dart';

/// Page displaying list of friend books
class FriendBooksListPage extends ConsumerStatefulWidget {
  const FriendBooksListPage({super.key});

  @override
  ConsumerState<FriendBooksListPage> createState() => _FriendBooksListPageState();
}

class _FriendBooksListPageState extends ConsumerState<FriendBooksListPage> {
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged(String query) {
    ref.read(friendBooksProvider.notifier).searchFriendBooks(query);
  }
  
  void _showCreateDialog() {
    print('Showing create dialog'); // Debug
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const CreateFriendBookDialog(),
    ).then((value) {
      print('Dialog closed');
    });
  }
  
  void _showEditDialog(FriendBook friendBook) {
    showDialog(
      context: context,
      builder: (context) => CreateFriendBookDialog(friendBook: friendBook),
    );
  }
  
  void _confirmDelete(FriendBook friendBook) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text('Möchten Sie das Freundebuch "${friendBook.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(friendBooksProvider.notifier).deleteFriendBook(friendBook.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text('Freundebuch gelöscht')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final friendBooksAsync = ref.watch(friendBooksProvider);
    final navigationService = ref.read(navigationServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        navigationService.navigateBack(context);
      },
      child: Scaffold(
        appBar: StandardAppBar(
          title: 'Meine Freundebücher',
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showCreateDialog,
              tooltip: l10n.createFriendBook,
            ),
          ],
        ),
        body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Freundebücher durchsuchen...',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Friend books list
          Expanded(
            child: friendBooksAsync.when(
              data: (friendBooks) {
                if (friendBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Noch keine Freundebücher',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Erstelle dein erstes Freundebuch!',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showCreateDialog,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createFriendBook),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: friendBooks.length,
                  itemBuilder: (context, index) {
                    final friendBook = friendBooks[index];
                    return FriendBookListTile(
                      friendBook: friendBook,
                      onTap: () => navigationService.navigateTo(context, '/friendbooks/${friendBook.id}'),
                      onEdit: () => _showEditDialog(friendBook),
                      onDelete: () => _confirmDelete(friendBook),
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
                        ref.read(friendBooksProvider.notifier).loadFriendBooks();
                      },
                      child: Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        tooltip: l10n.createFriendBook,
        child: const Icon(Icons.add),
      ),
      ),
    );
  }
}