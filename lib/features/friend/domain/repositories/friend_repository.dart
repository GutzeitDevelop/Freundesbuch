// Friend repository interface
// 
// Defines the contract for friend data operations

import '../entities/friend.dart';

/// Abstract repository interface for friend operations
abstract class FriendRepository {
  /// Gets all friends from storage
  Future<List<Friend>> getAllFriends();
  
  /// Gets a single friend by ID
  Future<Friend?> getFriendById(String id);
  
  /// Saves a new friend or updates existing one
  Future<Friend> saveFriend(Friend friend);
  
  /// Deletes a friend by ID
  Future<bool> deleteFriend(String id);
  
  /// Searches friends by name or nickname
  Future<List<Friend>> searchFriends(String query);
  
  /// Gets friends by friend book ID
  Future<List<Friend>> getFriendsByBookId(String bookId);
  
  /// Gets favorite friends
  Future<List<Friend>> getFavoriteFriends();
  
  /// Toggles favorite status for a friend
  Future<Friend> toggleFavorite(String friendId);
  
  /// Gets friends sorted by most recently added
  Future<List<Friend>> getRecentFriends({int limit = 10});
}