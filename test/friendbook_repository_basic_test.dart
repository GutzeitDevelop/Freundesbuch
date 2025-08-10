// Basic FriendBook Repository Tests
//
// Simplified version to test core functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/features/friendbook/data/repositories/friend_book_repository_impl.dart';
import 'package:myfriends/features/friend/data/repositories/friend_repository_impl.dart';
import 'helpers/test_setup.dart';

void main() {
  group('FriendBook Repository Basic Tests', () {
    late FriendBookRepositoryImpl friendBookRepository;
    late FriendRepositoryImpl friendRepository;
    
    setUp(() async {
      await setupHiveForTesting();
      friendBookRepository = FriendBookRepositoryImpl();
      friendRepository = FriendRepositoryImpl();
    });
    
    tearDown(() async {
      await clearHiveBox('friends');
      await clearHiveBox('friendbooks');
      await cleanupHive();
    });
    
    test('should save and retrieve a friendbook', () async {
      // Arrange
      final book = createTestFriendBook(name: 'Work Colleagues');
      
      // Act
      await friendBookRepository.saveFriendBook(book);
      final retrieved = await friendBookRepository.getFriendBookById(book.id);
      
      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Work Colleagues'));
      expect(retrieved.colorHex, equals('#2196F3'));
    });
    
    test('should add friend to book and maintain bidirectional association', () async {
      // Arrange
      final friend = createTestFriend(name: 'John Doe');
      await friendRepository.saveFriend(friend);
      
      final book = createTestFriendBook(name: 'Test Book');
      await friendBookRepository.saveFriendBook(book);
      
      // Act
      await friendBookRepository.addFriendToBook(book.id, friend.id);
      
      // Assert
      final updatedBook = await friendBookRepository.getFriendBookById(book.id);
      expect(updatedBook!.friendIds, contains(friend.id));
      
      final updatedFriend = await friendRepository.getFriendById(friend.id);
      expect(updatedFriend!.friendBookIds, contains(book.id));
    });
    
    test('should count friends in book accurately', () async {
      // Arrange
      final friends = [
        createTestFriend(name: 'Friend 1'),
        createTestFriend(name: 'Friend 2'),
        createTestFriend(name: 'Friend 3'),
      ];
      for (final friend in friends) {
        await friendRepository.saveFriend(friend);
      }
      
      final book = createTestFriendBook(name: 'Test Book');
      await friendBookRepository.saveFriendBook(book);
      
      // Add friends to book
      for (final friend in friends) {
        await friendBookRepository.addFriendToBook(book.id, friend.id);
      }
      
      // Act
      final count = await friendBookRepository.getFriendCountInBook(book.id);
      
      // Assert
      expect(count, equals(3));
    });
    
    test('should search friendbooks', () async {
      // Arrange
      final books = [
        createTestFriendBook(name: 'Work Colleagues', description: 'People from office'),
        createTestFriendBook(name: 'School Friends', description: 'Old classmates'),
        createTestFriendBook(name: 'Family', description: 'Extended family'),
      ];
      
      for (final book in books) {
        await friendBookRepository.saveFriendBook(book);
      }
      
      // Act
      final results = await friendBookRepository.searchFriendBooks('Work');
      
      // Assert
      expect(results.length, equals(1));
      expect(results.first.name, equals('Work Colleagues'));
    });
  });
}