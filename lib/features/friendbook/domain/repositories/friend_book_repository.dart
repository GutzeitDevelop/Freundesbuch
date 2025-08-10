// FriendBook repository interface
// 
// Defines the contract for FriendBook data operations

import '../entities/friend_book.dart';

/// Abstract repository for FriendBook operations
/// 
/// This interface defines all data operations for FriendBooks
/// Implementation details are hidden from the domain layer
abstract class FriendBookRepository {
  /// Gets all friend books
  Future<List<FriendBook>> getAllFriendBooks();
  
  /// Gets a specific friend book by ID
  Future<FriendBook?> getFriendBookById(String id);
  
  /// Saves or updates a friend book
  Future<void> saveFriendBook(FriendBook friendBook);
  
  /// Deletes a friend book
  Future<void> deleteFriendBook(String id);
  
  /// Gets friend books that contain a specific friend
  Future<List<FriendBook>> getFriendBooksForFriend(String friendId);
  
  /// Adds a friend to a friend book
  Future<void> addFriendToBook(String bookId, String friendId);
  
  /// Removes a friend from a friend book
  Future<void> removeFriendFromBook(String bookId, String friendId);
  
  /// Gets the count of friends in a friend book
  Future<int> getFriendCountInBook(String bookId);
  
  /// Searches friend books by name
  Future<List<FriendBook>> searchFriendBooks(String query);
}