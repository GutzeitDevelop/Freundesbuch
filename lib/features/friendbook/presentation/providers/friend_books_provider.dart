// FriendBooks provider for state management
// 
// Manages the state of friend books using Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/friend_book.dart';
import '../../domain/repositories/friend_book_repository.dart';
import '../../data/repositories/friend_book_repository_impl.dart';

/// Repository provider for FriendBook operations
final friendBookRepositoryProvider = Provider<FriendBookRepository>((ref) {
  return FriendBookRepositoryImpl();
});

/// State notifier for managing friend books
class FriendBooksNotifier extends StateNotifier<AsyncValue<List<FriendBook>>> {
  final FriendBookRepository _repository;
  
  FriendBooksNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFriendBooks();
  }
  
  /// Loads all friend books
  Future<void> loadFriendBooks() async {
    state = const AsyncValue.loading();
    try {
      final friendBooks = await _repository.getAllFriendBooks();
      state = AsyncValue.data(friendBooks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Gets a friend book by ID
  Future<FriendBook?> getFriendBookById(String id) async {
    return await _repository.getFriendBookById(id);
  }
  
  /// Saves or updates a friend book
  Future<void> saveFriendBook(FriendBook friendBook) async {
    try {
      await _repository.saveFriendBook(friendBook);
      await loadFriendBooks(); // Reload list
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Deletes a friend book
  Future<void> deleteFriendBook(String id) async {
    try {
      await _repository.deleteFriendBook(id);
      await loadFriendBooks(); // Reload list
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Searches friend books by name
  Future<void> searchFriendBooks(String query) async {
    state = const AsyncValue.loading();
    try {
      final friendBooks = await _repository.searchFriendBooks(query);
      state = AsyncValue.data(friendBooks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Adds a friend to a friend book
  Future<void> addFriendToBook(String bookId, String friendId) async {
    try {
      await _repository.addFriendToBook(bookId, friendId);
      await loadFriendBooks(); // Reload to update counts
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Removes a friend from a friend book
  Future<void> removeFriendFromBook(String bookId, String friendId) async {
    try {
      await _repository.removeFriendFromBook(bookId, friendId);
      await loadFriendBooks(); // Reload to update counts
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Gets friend books for a specific friend
  Future<List<FriendBook>> getFriendBooksForFriend(String friendId) async {
    return await _repository.getFriendBooksForFriend(friendId);
  }
  
  /// Gets the count of friends in a friend book
  Future<int> getFriendCountInBook(String bookId) async {
    return await _repository.getFriendCountInBook(bookId);
  }
}

/// Provider for FriendBooks state management
final friendBooksProvider = 
    StateNotifierProvider<FriendBooksNotifier, AsyncValue<List<FriendBook>>>((ref) {
  final repository = ref.watch(friendBookRepositoryProvider);
  return FriendBooksNotifier(repository);
});

/// Provider for getting friend books for a specific friend
final friendBooksForFriendProvider = FutureProvider.family<List<FriendBook>, String>((ref, friendId) async {
  final repository = ref.watch(friendBookRepositoryProvider);
  return await repository.getFriendBooksForFriend(friendId);
});

/// Provider for getting friend count in a book
final friendCountInBookProvider = FutureProvider.family<int, String>((ref, bookId) async {
  final repository = ref.watch(friendBookRepositoryProvider);
  return await repository.getFriendCountInBook(bookId);
});