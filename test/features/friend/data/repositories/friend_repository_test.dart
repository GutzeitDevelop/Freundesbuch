// Unit tests for Friend Repository Implementation
// 
// Tests the repository's data operations

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:myfriends/features/friend/domain/entities/friend.dart';
import 'package:myfriends/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:myfriends/features/friend/data/models/friend_model.dart';
import 'package:uuid/uuid.dart';
import '../../../../helpers/test_setup.dart';

void main() {
  group('FriendRepository Tests', () {
    late FriendRepositoryImpl repository;
    
    setUpAll(() async {
      await setupHiveForTesting();
    });
    
    setUp(() async {
      // Create a test box
      repository = FriendRepositoryImpl();
      // Clear any existing data
      if (Hive.isBoxOpen('friends')) {
        final box = Hive.box<FriendModel>('friends');
        await box.clear();
      }
    });
    
    tearDown(() async {
      // Clean up after each test
      if (Hive.isBoxOpen('friends')) {
        await Hive.box<FriendModel>('friends').clear();
      }
    });
    
    test('should save and retrieve a friend', () async {
      // Arrange
      final friend = Friend(
        id: const Uuid().v4(),
        name: 'Test Friend',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await repository.saveFriend(friend);
      final retrieved = await repository.getFriendById(friend.id);
      
      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved?.name, 'Test Friend');
      expect(retrieved?.id, friend.id);
    });
    
    test('should get all friends', () async {
      // Arrange
      final friend1 = Friend(
        id: const Uuid().v4(),
        name: 'Friend 1',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final friend2 = Friend(
        id: const Uuid().v4(),
        name: 'Friend 2',
        firstMetDate: DateTime.now(),
        templateType: 'modern',
        friendBookIds: [],
        isFavorite: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await repository.saveFriend(friend1);
      await repository.saveFriend(friend2);
      final friends = await repository.getAllFriends();
      
      // Assert
      expect(friends.length, 2);
      expect(friends.any((f) => f.name == 'Friend 1'), true);
      expect(friends.any((f) => f.name == 'Friend 2'), true);
    });
    
    test('should delete a friend', () async {
      // Arrange
      final friend = Friend(
        id: const Uuid().v4(),
        name: 'To Delete',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await repository.saveFriend(friend);
      final savedFriend = await repository.getFriendById(friend.id);
      expect(savedFriend, isNotNull);
      
      final deleted = await repository.deleteFriend(friend.id);
      final afterDelete = await repository.getFriendById(friend.id);
      
      // Assert
      expect(deleted, true);
      expect(afterDelete, isNull);
    });
    
    test('should search friends by name', () async {
      // Arrange
      final friend1 = Friend(
        id: const Uuid().v4(),
        name: 'Max Mustermann',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final friend2 = Friend(
        id: const Uuid().v4(),
        name: 'Erika Schmidt',
        nickname: 'Max',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final friend3 = Friend(
        id: const Uuid().v4(),
        name: 'Hans Meyer',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await repository.saveFriend(friend1);
      await repository.saveFriend(friend2);
      await repository.saveFriend(friend3);
      
      final searchResults = await repository.searchFriends('max');
      
      // Assert
      expect(searchResults.length, 2);
      expect(searchResults.any((f) => f.name == 'Max Mustermann'), true);
      expect(searchResults.any((f) => f.nickname == 'Max'), true);
      expect(searchResults.any((f) => f.name == 'Hans Meyer'), false);
    });
    
    test('should get favorite friends only', () async {
      // Arrange
      final favoriteFriend = Friend(
        id: const Uuid().v4(),
        name: 'Favorite Friend',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final normalFriend = Friend(
        id: const Uuid().v4(),
        name: 'Normal Friend',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await repository.saveFriend(favoriteFriend);
      await repository.saveFriend(normalFriend);
      final favorites = await repository.getFavoriteFriends();
      
      // Assert
      expect(favorites.length, 1);
      expect(favorites.first.name, 'Favorite Friend');
      expect(favorites.first.isFavorite, true);
    });
    
    test('should toggle favorite status', () async {
      // Arrange
      final friend = Friend(
        id: const Uuid().v4(),
        name: 'Toggle Favorite',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await repository.saveFriend(friend);
      expect(friend.isFavorite, false);
      
      final toggled = await repository.toggleFavorite(friend.id);
      
      // Assert
      expect(toggled.isFavorite, true);
      
      // Toggle again
      final toggledAgain = await repository.toggleFavorite(friend.id);
      expect(toggledAgain.isFavorite, false);
    });
    
    test('should get recent friends sorted by creation date', () async {
      // Arrange
      final now = DateTime.now();
      final friend1 = Friend(
        id: '1',
        name: 'Oldest',
        firstMetDate: now,
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      );
      
      final friend2 = Friend(
        id: '2',
        name: 'Middle',
        firstMetDate: now,
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      );
      
      final friend3 = Friend(
        id: '3',
        name: 'Newest',
        firstMetDate: now,
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );
      
      // Act
      await repository.saveFriend(friend1);
      await repository.saveFriend(friend2);
      await repository.saveFriend(friend3);
      
      final recent = await repository.getRecentFriends(limit: 2);
      
      // Assert
      expect(recent.length, 2);
      expect(recent[0].name, 'Newest');
      expect(recent[1].name, 'Middle');
    });
  });
}