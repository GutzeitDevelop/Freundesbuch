// FriendBook repository implementation
// 
// Concrete implementation of FriendBookRepository using Hive

import 'package:hive/hive.dart';
import '../../domain/entities/friend_book.dart';
import '../../domain/repositories/friend_book_repository.dart';
import '../models/friend_book_model.dart';
import '../../../friend/data/models/friend_model.dart';

/// Concrete implementation of FriendBookRepository using Hive
/// 
/// Handles all FriendBook data operations with local storage
class FriendBookRepositoryImpl implements FriendBookRepository {
  static const String _boxName = 'friendbooks';
  
  /// Opens the Hive box for FriendBooks
  Future<Box<FriendBookModel>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<FriendBookModel>(_boxName);
    }
    return Hive.box<FriendBookModel>(_boxName);
  }
  
  @override
  Future<List<FriendBook>> getAllFriendBooks() async {
    final box = await _openBox();
    return box.values.map((model) => model.toEntity()).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  
  @override
  Future<FriendBook?> getFriendBookById(String id) async {
    final box = await _openBox();
    final model = box.get(id);
    return model?.toEntity();
  }
  
  @override
  Future<void> saveFriendBook(FriendBook friendBook) async {
    final box = await _openBox();
    final model = FriendBookModel.fromEntity(friendBook);
    await box.put(friendBook.id, model);
    
    // Update friend entities to reflect the friendbook association
    await _updateFriendAssociations(friendBook);
  }
  
  @override
  Future<void> deleteFriendBook(String id) async {
    final box = await _openBox();
    final friendBook = box.get(id)?.toEntity();
    
    if (friendBook != null) {
      // Remove friendbook ID from all associated friends
      await _removeFriendBookFromFriends(id, friendBook.friendIds);
    }
    
    await box.delete(id);
  }
  
  @override
  Future<List<FriendBook>> getFriendBooksForFriend(String friendId) async {
    final box = await _openBox();
    return box.values
        .where((model) => model.friendIds.contains(friendId))
        .map((model) => model.toEntity())
        .toList();
  }
  
  @override
  Future<void> addFriendToBook(String bookId, String friendId) async {
    final box = await _openBox();
    final model = box.get(bookId);
    
    if (model != null && !model.friendIds.contains(friendId)) {
      final updatedFriendIds = List<String>.from(model.friendIds)..add(friendId);
      final updatedModel = model.copyWith(
        friendIds: updatedFriendIds,
        updatedAt: DateTime.now(),
      );
      await box.put(bookId, updatedModel);
      
      // Update the friend's friendBookIds list
      await _addFriendBookToFriend(friendId, bookId);
    }
  }
  
  @override
  Future<void> removeFriendFromBook(String bookId, String friendId) async {
    final box = await _openBox();
    final model = box.get(bookId);
    
    if (model != null && model.friendIds.contains(friendId)) {
      final updatedFriendIds = List<String>.from(model.friendIds)..remove(friendId);
      final updatedModel = model.copyWith(
        friendIds: updatedFriendIds,
        updatedAt: DateTime.now(),
      );
      await box.put(bookId, updatedModel);
      
      // Update the friend's friendBookIds list
      await _removeFriendBookFromFriend(friendId, bookId);
    }
  }
  
  @override
  Future<int> getFriendCountInBook(String bookId) async {
    final box = await _openBox();
    final model = box.get(bookId);
    if (model == null) return 0;
    
    // Count only friends that actually exist
    if (!Hive.isBoxOpen('friends')) {
      await Hive.openBox<FriendModel>('friends');
    }
    final friendsBox = Hive.box<FriendModel>('friends');
    
    int count = 0;
    for (final friendId in model.friendIds) {
      if (friendsBox.containsKey(friendId)) {
        count++;
      }
    }
    
    // Clean up the friendIds list if there are orphaned IDs
    if (count != model.friendIds.length) {
      final existingFriendIds = model.friendIds.where((id) => friendsBox.containsKey(id)).toList();
      final updatedModel = model.copyWith(
        friendIds: existingFriendIds,
        updatedAt: DateTime.now(),
      );
      await box.put(bookId, updatedModel);
    }
    
    return count;
  }
  
  @override
  Future<List<FriendBook>> searchFriendBooks(String query) async {
    if (query.isEmpty) return getAllFriendBooks();
    
    final box = await _openBox();
    final lowerQuery = query.toLowerCase();
    
    return box.values
        .where((model) =>
            model.name.toLowerCase().contains(lowerQuery) ||
            (model.description?.toLowerCase().contains(lowerQuery) ?? false))
        .map((model) => model.toEntity())
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  
  /// Updates friend associations when a friendbook is saved
  Future<void> _updateFriendAssociations(FriendBook friendBook) async {
    if (!Hive.isBoxOpen('friends')) {
      await Hive.openBox<FriendModel>('friends');
    }
    final friendsBox = Hive.box<FriendModel>('friends');
    
    // Add friendbook to all friends in the list
    for (final friendId in friendBook.friendIds) {
      final friend = friendsBox.get(friendId);
      if (friend != null && !friend.friendBookIds.contains(friendBook.id)) {
        final updatedFriend = friend.copyWith(
          friendBookIds: List<String>.from(friend.friendBookIds)..add(friendBook.id),
          updatedAt: DateTime.now(),
        );
        await friendsBox.put(friendId, updatedFriend);
      }
    }
  }
  
  /// Adds a friendbook ID to a friend's list
  Future<void> _addFriendBookToFriend(String friendId, String bookId) async {
    if (!Hive.isBoxOpen('friends')) {
      await Hive.openBox<FriendModel>('friends');
    }
    final friendsBox = Hive.box<FriendModel>('friends');
    
    final friend = friendsBox.get(friendId);
    if (friend != null && !friend.friendBookIds.contains(bookId)) {
      final updatedFriend = friend.copyWith(
        friendBookIds: List<String>.from(friend.friendBookIds)..add(bookId),
        updatedAt: DateTime.now(),
      );
      await friendsBox.put(friendId, updatedFriend);
    }
  }
  
  /// Removes a friendbook ID from a friend's list
  Future<void> _removeFriendBookFromFriend(String friendId, String bookId) async {
    if (!Hive.isBoxOpen('friends')) {
      await Hive.openBox<FriendModel>('friends');
    }
    final friendsBox = Hive.box<FriendModel>('friends');
    
    final friend = friendsBox.get(friendId);
    if (friend != null && friend.friendBookIds.contains(bookId)) {
      final updatedFriend = friend.copyWith(
        friendBookIds: List<String>.from(friend.friendBookIds)..remove(bookId),
        updatedAt: DateTime.now(),
      );
      await friendsBox.put(friendId, updatedFriend);
    }
  }
  
  /// Removes friendbook from all friends when the book is deleted
  Future<void> _removeFriendBookFromFriends(String bookId, List<String> friendIds) async {
    if (!Hive.isBoxOpen('friends')) {
      await Hive.openBox<FriendModel>('friends');
    }
    final friendsBox = Hive.box<FriendModel>('friends');
    
    for (final friendId in friendIds) {
      final friend = friendsBox.get(friendId);
      if (friend != null && friend.friendBookIds.contains(bookId)) {
        final updatedFriend = friend.copyWith(
          friendBookIds: List<String>.from(friend.friendBookIds)..remove(bookId),
          updatedAt: DateTime.now(),
        );
        await friendsBox.put(friendId, updatedFriend);
      }
    }
  }
}