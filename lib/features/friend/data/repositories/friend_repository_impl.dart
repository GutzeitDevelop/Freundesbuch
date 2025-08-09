// Friend repository implementation
// 
// Concrete implementation of the friend repository using Hive

import 'package:hive/hive.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../models/friend_model.dart';

/// Implementation of FriendRepository using Hive
class FriendRepositoryImpl implements FriendRepository {
  static const String _boxName = 'friends';
  
  /// Gets the Hive box for friends
  Future<Box<FriendModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<FriendModel>(_boxName);
    }
    return Hive.box<FriendModel>(_boxName);
  }
  
  @override
  Future<List<Friend>> getAllFriends() async {
    final box = await _getBox();
    return box.values.map((model) => model.toEntity()).toList();
  }
  
  @override
  Future<Friend?> getFriendById(String id) async {
    final box = await _getBox();
    final model = box.get(id);
    return model?.toEntity();
  }
  
  @override
  Future<Friend> saveFriend(Friend friend) async {
    final box = await _getBox();
    final model = FriendModel.fromEntity(friend);
    await box.put(friend.id, model);
    return friend;
  }
  
  @override
  Future<bool> deleteFriend(String id) async {
    final box = await _getBox();
    if (box.containsKey(id)) {
      await box.delete(id);
      return true;
    }
    return false;
  }
  
  @override
  Future<List<Friend>> searchFriends(String query) async {
    final box = await _getBox();
    final lowercaseQuery = query.toLowerCase();
    
    return box.values
        .where((model) =>
            model.name.toLowerCase().contains(lowercaseQuery) ||
            (model.nickname?.toLowerCase().contains(lowercaseQuery) ?? false))
        .map((model) => model.toEntity())
        .toList();
  }
  
  @override
  Future<List<Friend>> getFriendsByBookId(String bookId) async {
    final box = await _getBox();
    return box.values
        .where((model) => model.friendBookIds.contains(bookId))
        .map((model) => model.toEntity())
        .toList();
  }
  
  @override
  Future<List<Friend>> getFavoriteFriends() async {
    final box = await _getBox();
    return box.values
        .where((model) => model.isFavorite)
        .map((model) => model.toEntity())
        .toList();
  }
  
  @override
  Future<Friend> toggleFavorite(String friendId) async {
    final box = await _getBox();
    final model = box.get(friendId);
    
    if (model != null) {
      final friend = model.toEntity();
      final updatedFriend = friend.copyWith(
        isFavorite: !friend.isFavorite,
        updatedAt: DateTime.now(),
      );
      await saveFriend(updatedFriend);
      return updatedFriend;
    }
    
    throw Exception('Friend not found');
  }
  
  @override
  Future<List<Friend>> getRecentFriends({int limit = 10}) async {
    final box = await _getBox();
    final friends = box.values.map((model) => model.toEntity()).toList();
    
    // Sort by createdAt in descending order
    friends.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Return limited number of friends
    return friends.take(limit).toList();
  }
}