// Comprehensive tests for Friend Repository
//
// Tests all friend repository functionality including edge cases

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:myfriends/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:myfriends/features/friend/domain/entities/friend.dart';
import '../../../../helpers/test_setup.dart';

void main() {
  group('FriendRepository Comprehensive Tests', () {
    late FriendRepositoryImpl repository;
    
    setUp(() async {
      await setupHiveForTesting();
      repository = FriendRepositoryImpl();
    });
    
    tearDown(() async {
      await clearHiveBox('friends');
      await cleanupHive();
    });
    
    group('Basic CRUD Operations', () {
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
      
      test('should update an existing friend', () async {
        // Arrange
        final originalFriend = createTestFriend(name: 'John Doe');
        await repository.saveFriend(originalFriend);
        
        final updatedFriend = originalFriend.copyWith(
          name: 'Jane Doe',
          nickname: 'Janey',
        );
        
        // Act
        await repository.saveFriend(updatedFriend);
        final retrievedFriend = await repository.getFriendById(originalFriend.id);
        
        // Assert
        expect(retrievedFriend!.name, equals('Jane Doe'));
        expect(retrievedFriend.nickname, equals('Janey'));
        expect(retrievedFriend.id, equals(originalFriend.id));
      });
      
      test('should delete a friend', () async {
        // Arrange
        final friend = createTestFriend();
        await repository.saveFriend(friend);
        
        // Act
        final deleted = await repository.deleteFriend(friend.id);
        final retrievedFriend = await repository.getFriendById(friend.id);
        
        // Assert
        expect(deleted, isTrue);
        expect(retrievedFriend, isNull);
      });
      
      test('should return false when deleting non-existent friend', () async {
        // Act
        final deleted = await repository.deleteFriend('non-existent-id');
        
        // Assert
        expect(deleted, isFalse);
      });
    });
    
    group('Bulk Operations', () {
      test('should retrieve all friends', () async {
        // Arrange
        final friends = createTestFriends(5);
        for (final friend in friends) {
          await repository.saveFriend(friend);
        }
        
        // Act
        final allFriends = await repository.getAllFriends();
        
        // Assert
        expect(allFriends.length, equals(5));
        expect(allFriends.map((f) => f.name).toSet(), 
               equals(friends.map((f) => f.name).toSet()));
      });
      
      test('should return empty list when no friends exist', () async {
        // Act
        final allFriends = await repository.getAllFriends();
        
        // Assert
        expect(allFriends, isEmpty);
      });
    });
    
    group('Search Functionality', () {
      setUp(() async {
        // Setup test data
        final friends = [
          createTestFriend(name: 'John Doe', nickname: 'Johnny'),
          createTestFriend(name: 'Jane Smith', nickname: 'Janey'),
          createTestFriend(name: 'Bob Johnson', nickname: 'Bobby'),
          createTestFriend(name: 'Alice Brown'),
        ];
        
        for (final friend in friends) {
          await repository.saveFriend(friend);
        }
      });
      
      test('should search friends by name', () async {
        // Act
        final results = await repository.searchFriends('John');
        
        // Assert
        expect(results.length, equals(2)); // John Doe and Bob Johnson
        expect(results.any((f) => f.name == 'John Doe'), isTrue);
        expect(results.any((f) => f.name == 'Bob Johnson'), isTrue);
      });
      
      test('should search friends by nickname', () async {
        // Act
        final results = await repository.searchFriends('Johnny');
        
        // Assert
        expect(results.length, equals(1));
        expect(results.first.name, equals('John Doe'));
      });
      
      test('should be case insensitive', () async {
        // Act
        final results = await repository.searchFriends('JANE');
        
        // Assert
        expect(results.length, equals(1));
        expect(results.first.name, equals('Jane Smith'));
      });
      
      test('should return empty list for no matches', () async {
        // Act
        final results = await repository.searchFriends('NonExistent');
        
        // Assert
        expect(results, isEmpty);
      });
      
      test('should return empty list for empty query', () async {
        // Act
        final results = await repository.searchFriends('');
        
        // Assert
        expect(results, isEmpty);
      });
    });
    
    group('FriendBook Integration', () {
      test('should get friends by book ID', () async {
        // Arrange
        const bookId = 'test-book-id';
        final friendsInBook = [
          createTestFriend(name: 'Friend 1', friendBookIds: [bookId]),
          createTestFriend(name: 'Friend 2', friendBookIds: [bookId]),
        ];
        final friendNotInBook = createTestFriend(name: 'Friend 3', friendBookIds: []);
        
        for (final friend in [...friendsInBook, friendNotInBook]) {
          await repository.saveFriend(friend);
        }
        
        // Act
        final results = await repository.getFriendsByBookId(bookId);
        
        // Assert
        expect(results.length, equals(2));
        expect(results.every((f) => f.friendBookIds.contains(bookId)), isTrue);
      });
      
      test('should return empty list for book with no friends', () async {
        // Arrange
        final friend = createTestFriend(friendBookIds: ['other-book']);
        await repository.saveFriend(friend);
        
        // Act
        final results = await repository.getFriendsByBookId('empty-book');
        
        // Assert
        expect(results, isEmpty);
      });
    });
    
    group('Favorite Friends', () {
      test('should get only favorite friends', () async {
        // Arrange
        final friends = [
          createTestFriend(name: 'Favorite 1', isFavorite: true),
          createTestFriend(name: 'Regular 1', isFavorite: false),
          createTestFriend(name: 'Favorite 2', isFavorite: true),
        ];
        
        for (final friend in friends) {
          await repository.saveFriend(friend);
        }
        
        // Act
        final favorites = await repository.getFavoriteFriends();
        
        // Assert
        expect(favorites.length, equals(2));
        expect(favorites.every((f) => f.isFavorite), isTrue);
        expect(favorites.any((f) => f.name == 'Favorite 1'), isTrue);
        expect(favorites.any((f) => f.name == 'Favorite 2'), isTrue);
      });
      
      test('should return empty list when no favorites exist', () async {
        // Arrange
        final friend = createTestFriend(isFavorite: false);
        await repository.saveFriend(friend);
        
        // Act
        final favorites = await repository.getFavoriteFriends();
        
        // Assert
        expect(favorites, isEmpty);
      });
    });
    
    group('Template Integration', () {
      test('should save friend with custom template', () async {
        // Arrange
        final friend = createTestFriend(
          name: 'Template User',
          templateType: 'custom-template-id',
        );
        
        // Act
        await repository.saveFriend(friend);
        final retrieved = await repository.getFriendById(friend.id);
        
        // Assert
        expect(retrieved!.templateType, equals('custom-template-id'));
      });
    });
    
    group('Edge Cases and Error Handling', () {
      test('should handle friend with all optional fields null', () async {
        // Arrange
        final friend = createTestFriend(
          name: 'Minimal Friend',
          nickname: null,
        );
        
        // Act
        await repository.saveFriend(friend);
        final retrieved = await repository.getFriendById(friend.id);
        
        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Minimal Friend'));
        expect(retrieved.nickname, isNull);
      });
      
      test('should handle very long names', () async {
        // Arrange
        final longName = 'A' * 1000;
        final friend = createTestFriend(name: longName);
        
        // Act
        await repository.saveFriend(friend);
        final retrieved = await repository.getFriendById(friend.id);
        
        // Assert
        expect(retrieved!.name, equals(longName));
      });
      
      test('should handle special characters in search', () async {
        // Arrange
        final friend = createTestFriend(name: 'João São-Paulo', nickname: 'J@ão');
        await repository.saveFriend(friend);
        
        // Act
        final results1 = await repository.searchFriends('João');
        final results2 = await repository.searchFriends('J@ão');
        
        // Assert
        expect(results1.length, equals(1));
        expect(results2.length, equals(1));
      });
    });
    
    group('Concurrent Operations', () {
      test('should handle concurrent saves', () async {
        // Arrange
        final friends = createTestFriends(10);
        
        // Act
        final futures = friends.map((f) => repository.saveFriend(f)).toList();
        await Future.wait(futures);
        
        final allFriends = await repository.getAllFriends();
        
        // Assert
        expect(allFriends.length, equals(10));
      });
      
      test('should handle concurrent searches', () async {
        // Arrange
        final friends = createTestFriends(20);
        for (final friend in friends) {
          await repository.saveFriend(friend);
        }
        
        // Act
        final searchFutures = List.generate(
          5, 
          (index) => repository.searchFriends('Friend $index')
        );
        final results = await Future.wait(searchFutures);
        
        // Assert
        for (int i = 0; i < results.length; i++) {
          expect(results[i].length, equals(1));
          expect(results[i].first.name, equals('Test Friend $i'));
        }
      });
    });
  });
}