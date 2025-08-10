// Basic Friend Repository Tests
//
// Simplified version to test core functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/features/friend/data/repositories/friend_repository_impl.dart';
import 'helpers/test_setup.dart';

void main() {
  group('Friend Repository Basic Tests', () {
    late FriendRepositoryImpl repository;
    
    setUp(() async {
      await setupHiveForTesting();
      repository = FriendRepositoryImpl();
    });
    
    tearDown(() async {
      await clearHiveBox('friends');
      await cleanupHive();
    });
    
    test('should save and retrieve a friend', () async {
      // Arrange
      final friend = createTestFriend(name: 'John Doe');
      
      // Act
      final savedFriend = await repository.saveFriend(friend);
      final retrievedFriend = await repository.getFriendById(friend.id);
      
      // Assert
      expect(savedFriend.id, equals(friend.id));
      expect(retrievedFriend, isNotNull);
      expect(retrievedFriend!.name, equals('John Doe'));
    });
    
    test('should get all friends', () async {
      // Arrange
      final friends = [
        createTestFriend(name: 'Friend 1'),
        createTestFriend(name: 'Friend 2'),
        createTestFriend(name: 'Friend 3'),
      ];
      
      for (final friend in friends) {
        await repository.saveFriend(friend);
      }
      
      // Act
      final allFriends = await repository.getAllFriends();
      
      // Assert
      expect(allFriends.length, equals(3));
      expect(allFriends.map((f) => f.name).toSet(), equals({'Friend 1', 'Friend 2', 'Friend 3'}));
    });
    
    test('should search friends', () async {
      // Arrange
      final friends = [
        createTestFriend(name: 'John Doe', nickname: 'Johnny'),
        createTestFriend(name: 'Jane Smith', nickname: 'Janey'),
        createTestFriend(name: 'Bob Johnson'),
      ];
      
      for (final friend in friends) {
        await repository.saveFriend(friend);
      }
      
      // Act
      final results = await repository.searchFriends('John');
      
      // Assert
      expect(results.length, equals(2)); // John Doe and Bob Johnson
    });
    
    test('should delete a friend', () async {
      // Arrange
      final friend = createTestFriend(name: 'To Delete');
      await repository.saveFriend(friend);
      
      // Act
      final deleted = await repository.deleteFriend(friend.id);
      final retrievedFriend = await repository.getFriendById(friend.id);
      
      // Assert
      expect(deleted, isTrue);
      expect(retrievedFriend, isNull);
    });
  });
}