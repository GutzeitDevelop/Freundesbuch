// Friends state management provider
// 
// Manages friend data and operations using Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../../data/repositories/friend_repository_impl.dart';

/// Provider for friend repository
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepositoryImpl();
});

/// State notifier for managing friends list
class FriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  final FriendRepository _repository;
  
  FriendsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFriends();
  }
  
  /// Loads all friends from repository
  Future<void> loadFriends() async {
    state = const AsyncValue.loading();
    try {
      final friends = await _repository.getAllFriends();
      state = AsyncValue.data(friends);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Gets a single friend by ID
  Future<Friend?> getFriendById(String id) async {
    return await _repository.getFriendById(id);
  }
  
  /// Saves a friend (create or update)
  Future<void> saveFriend(Friend friend) async {
    try {
      await _repository.saveFriend(friend);
      await loadFriends(); // Reload list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Deletes a friend
  Future<void> deleteFriend(String friendId) async {
    try {
      await _repository.deleteFriend(friendId);
      await loadFriends(); // Reload list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Searches friends by query
  Future<void> searchFriends(String query) async {
    state = const AsyncValue.loading();
    try {
      final friends = query.isEmpty 
          ? await _repository.getAllFriends()
          : await _repository.searchFriends(query);
      state = AsyncValue.data(friends);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Toggles favorite status
  Future<void> toggleFavorite(String friendId) async {
    try {
      await _repository.toggleFavorite(friendId);
      await loadFriends(); // Reload list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Gets favorite friends
  Future<void> loadFavoriteFriends() async {
    state = const AsyncValue.loading();
    try {
      final friends = await _repository.getFavoriteFriends();
      state = AsyncValue.data(friends);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for friends state
final friendsProvider = StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
  final repository = ref.watch(friendRepositoryProvider);
  return FriendsNotifier(repository);
});