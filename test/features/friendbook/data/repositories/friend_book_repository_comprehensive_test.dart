// Comprehensive tests for FriendBook Repository
//
// Tests all friendbook repository functionality including edge cases

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:myfriends/features/friendbook/data/repositories/friend_book_repository_impl.dart';
import 'package:myfriends/features/friendbook/domain/entities/friend_book.dart';
import 'package:myfriends/features/friend/data/repositories/friend_repository_impl.dart';
import '../../../../helpers/test_setup.dart';

void main() {
  group('FriendBookRepository Comprehensive Tests', () {
    late FriendBookRepositoryImpl repository;
    late FriendRepositoryImpl friendRepository;
    
    setUp(() async {
      await setupHiveForTesting();
      repository = FriendBookRepositoryImpl();
      friendRepository = FriendRepositoryImpl();
    });
    
    tearDown(() async {
      await clearHiveBox('friendbooks');
      await clearHiveBox('friends');
      await cleanupHive();
    });
    
    group('Basic CRUD Operations', () {
      test('should save and retrieve a friendbook', () async {
        // Arrange
        final friendBook = createTestFriendBook(name: 'Work Colleagues');
        
        // Act
        await repository.saveFriendBook(friendBook);
        final retrieved = await repository.getFriendBookById(friendBook.id);
        
        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(friendBook.id));
        expect(retrieved.name, equals('Work Colleagues'));
        expect(retrieved.colorHex, equals('#2196F3'));
        expect(retrieved.iconName, equals('group'));
      });
      
      test('should update an existing friendbook', () async {
        // Arrange
        final originalBook = createTestFriendBook(name: 'Original Name');
        await repository.saveFriendBook(originalBook);
        
        final updatedBook = originalBook.copyWith(
          name: 'Updated Name',
          description: 'Updated Description',
          colorHex: '#FF5722',
          iconName: 'work',
        );
        
        // Act
        await repository.saveFriendBook(updatedBook);
        final retrieved = await repository.getFriendBookById(originalBook.id);
        
        // Assert
        expect(retrieved!.name, equals('Updated Name'));
        expect(retrieved.description, equals('Updated Description'));
        expect(retrieved.colorHex, equals('#FF5722'));
        expect(retrieved.iconName, equals('work'));
        expect(retrieved.id, equals(originalBook.id));
      });
      
      test('should delete a friendbook and clean up friend associations', () async {
        // Arrange
        final friend = createTestFriend(name: 'Test Friend');
        await friendRepository.saveFriend(friend);
        
        final friendBook = createTestFriendBook(friendIds: [friend.id]);
        await repository.saveFriendBook(friendBook);
        
        // Verify initial association
        final friendWithBook = await friendRepository.getFriendById(friend.id);
        expect(friendWithBook!.friendBookIds, contains(friendBook.id));
        
        // Act
        await repository.deleteFriendBook(friendBook.id);
        
        // Assert
        final deletedBook = await repository.getFriendBookById(friendBook.id);
        expect(deletedBook, isNull);
        
        // Verify friend association was removed
        final friendAfterBookDeletion = await friendRepository.getFriendById(friend.id);
        expect(friendAfterBookDeletion!.friendBookIds, isNot(contains(friendBook.id)));
      });
      
      test('should return null when getting non-existent friendbook', () async {
        // Act
        final result = await repository.getFriendBookById('non-existent-id');
        
        // Assert
        expect(result, isNull);
      });
    });
    
    group('Bulk Operations', () {
      test('should retrieve all friendbooks sorted by update time', () async {
        // Arrange - create books with different timestamps
        final now = DateTime.now();
        final books = [
          createTestFriendBook(name: 'Book 1', createdAt: now.subtract(const Duration(hours: 2))),
          createTestFriendBook(name: 'Book 2', createdAt: now.subtract(const Duration(hours: 1))),
          createTestFriendBook(name: 'Book 3', createdAt: now),
        ];
        
        // Save in random order
        await repository.saveFriendBook(books[1]);
        await repository.saveFriendBook(books[2]);
        await repository.saveFriendBook(books[0]);
        
        // Act
        final allBooks = await repository.getAllFriendBooks();
        
        // Assert - should be sorted by updatedAt descending
        expect(allBooks.length, equals(3));
        expect(allBooks.map((b) => b.name).toList(), equals(['Book 3', 'Book 2', 'Book 1']));
      });
      
      test('should return empty list when no friendbooks exist', () async {
        // Act
        final allBooks = await repository.getAllFriendBooks();
        
        // Assert
        expect(allBooks, isEmpty);
      });
    });
    
    group('Search Functionality', () {
      setUp(() async {
        // Setup test data
        final books = [
          createTestFriendBook(name: 'Work Colleagues', description: 'People from office'),
          createTestFriendBook(name: 'School Friends', description: 'Old classmates'),
          createTestFriendBook(name: 'Family', description: 'Extended family members'),
          createTestFriendBook(name: 'Gym Buddies', description: 'Workout partners'),
        ];
        
        for (final book in books) {
          await repository.saveFriendBook(book);
        }
      });
      
      test('should search friendbooks by name', () async {
        // Act
        final results = await repository.searchFriendBooks('Work');
        
        // Assert
        expect(results.length, equals(1));
        expect(results.first.name, equals('Work Colleagues'));
      });
      
      test('should search friendbooks by description', () async {
        // Act
        final results = await repository.searchFriendBooks('office');
        
        // Assert
        expect(results.length, equals(1));
        expect(results.first.name, equals('Work Colleagues'));
      });
      
      test('should be case insensitive', () async {
        // Act
        final results = await repository.searchFriendBooks('FAMILY');
        
        // Assert
        expect(results.length, equals(1));
        expect(results.first.name, equals('Family'));
      });
      
      test('should return all books for empty query', () async {
        // Act
        final results = await repository.searchFriendBooks('');
        
        // Assert
        expect(results.length, equals(4));
      });
      
      test('should return empty list for no matches', () async {
        // Act
        final results = await repository.searchFriendBooks('NonExistent');
        
        // Assert
        expect(results, isEmpty);
      });
    });
    
    group('Friend Management in Books', () {
      test('should add friend to book and create bidirectional association', () async {
        // Arrange
        final friend = createTestFriend(name: 'John Doe');
        await friendRepository.saveFriend(friend);
        
        final book = createTestFriendBook(name: 'Test Book');
        await repository.saveFriendBook(book);
        
        // Act
        await repository.addFriendToBook(book.id, friend.id);
        
        // Assert
        final updatedBook = await repository.getFriendBookById(book.id);
        expect(updatedBook!.friendIds, contains(friend.id));
        
        final updatedFriend = await friendRepository.getFriendById(friend.id);
        expect(updatedFriend!.friendBookIds, contains(book.id));
      });
      
      test('should remove friend from book and clean up association', () async {
        // Arrange
        final friend = createTestFriend(name: 'John Doe');
        await friendRepository.saveFriend(friend);
        
        final book = createTestFriendBook(name: 'Test Book', friendIds: [friend.id]);
        await repository.saveFriendBook(book);
        
        // Act
        await repository.removeFriendFromBook(book.id, friend.id);
        
        // Assert
        final updatedBook = await repository.getFriendBookById(book.id);
        expect(updatedBook!.friendIds, isNot(contains(friend.id)));
        
        final updatedFriend = await friendRepository.getFriendById(friend.id);
        expect(updatedFriend!.friendBookIds, isNot(contains(book.id)));
      });
      
      test('should not add duplicate friends to book', () async {
        // Arrange
        final friend = createTestFriend(name: 'John Doe');
        await friendRepository.saveFriend(friend);
        
        final book = createTestFriendBook(name: 'Test Book', friendIds: [friend.id]);
        await repository.saveFriendBook(book);
        
        // Act - try to add the same friend again
        await repository.addFriendToBook(book.id, friend.id);
        
        // Assert - should still have only one instance
        final updatedBook = await repository.getFriendBookById(book.id);
        expect(updatedBook!.friendIds.where((id) => id == friend.id).length, equals(1));
      });
      
      test('should handle adding friend to non-existent book gracefully', () async {
        // Arrange
        final friend = createTestFriend();
        await friendRepository.saveFriend(friend);
        
        // Act & Assert - should not throw
        await repository.addFriendToBook('non-existent-book', friend.id);
      });
    });
    
    group('Friend Count Operations', () {
      test('should count friends accurately', () async {
        // Arrange
        final friends = createTestFriends(3);
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        final book = createTestFriendBook(
          name: 'Test Book',
          friendIds: friends.map((f) => f.id).toList(),
        );
        await repository.saveFriendBook(book);
        
        // Act
        final count = await repository.getFriendCountInBook(book.id);
        
        // Assert
        expect(count, equals(3));
      });
      
      test('should clean up orphaned friend IDs and return accurate count', () async {
        // Arrange
        final existingFriend = createTestFriend(name: 'Existing Friend');
        await friendRepository.saveFriend(existingFriend);
        
        const orphanedFriendId = 'deleted-friend-id';
        
        final book = createTestFriendBook(
          name: 'Test Book',
          friendIds: [existingFriend.id, orphanedFriendId],
        );
        await repository.saveFriendBook(book);
        
        // Act
        final count = await repository.getFriendCountInBook(book.id);
        
        // Assert - should return 1 and clean up the orphaned ID
        expect(count, equals(1));
        
        // Verify cleanup happened
        final updatedBook = await repository.getFriendBookById(book.id);
        expect(updatedBook!.friendIds, equals([existingFriend.id]));
        expect(updatedBook.friendIds, isNot(contains(orphanedFriendId)));
      });
      
      test('should return 0 for non-existent book', () async {
        // Act
        final count = await repository.getFriendCountInBook('non-existent-book');
        
        // Assert
        expect(count, equals(0));
      });
      
      test('should return 0 for empty book', () async {
        // Arrange
        final book = createTestFriendBook(name: 'Empty Book', friendIds: []);
        await repository.saveFriendBook(book);
        
        // Act
        final count = await repository.getFriendCountInBook(book.id);
        
        // Assert
        expect(count, equals(0));
      });
    });
    
    group('Friend Book Associations', () {
      test('should get all friendbooks for a specific friend', () async {
        // Arrange
        final friend = createTestFriend(name: 'John Doe');
        await friendRepository.saveFriend(friend);
        
        final books = [
          createTestFriendBook(name: 'Work', friendIds: [friend.id]),
          createTestFriendBook(name: 'Family', friendIds: [friend.id]),
          createTestFriendBook(name: 'School', friendIds: []), // Not associated
        ];
        
        for (final book in books) {
          await repository.saveFriendBook(book);
        }
        
        // Act
        final friendBooks = await repository.getFriendBooksForFriend(friend.id);
        
        // Assert
        expect(friendBooks.length, equals(2));
        expect(friendBooks.map((b) => b.name).toSet(), equals({'Work', 'Family'}));
      });
      
      test('should return empty list for friend with no book associations', () async {
        // Arrange
        final friend = createTestFriend();
        await friendRepository.saveFriend(friend);
        
        final book = createTestFriendBook(friendIds: []); // Empty book
        await repository.saveFriendBook(book);
        
        // Act
        final friendBooks = await repository.getFriendBooksForFriend(friend.id);
        
        // Assert
        expect(friendBooks, isEmpty);
      });
    });
    
    group('Edge Cases and Error Handling', () {
      test('should handle friendbook with null description', () async {
        // Arrange
        final book = createTestFriendBook(
          name: 'Simple Book',
          description: null,
        );
        
        // Act
        await repository.saveFriendBook(book);
        final retrieved = await repository.getFriendBookById(book.id);
        
        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.description, isNull);
      });
      
      test('should handle very long names and descriptions', () async {
        // Arrange
        final longName = 'A' * 1000;
        final longDescription = 'B' * 2000;
        final book = createTestFriendBook(
          name: longName,
          description: longDescription,
        );
        
        // Act
        await repository.saveFriendBook(book);
        final retrieved = await repository.getFriendBookById(book.id);
        
        // Assert
        expect(retrieved!.name, equals(longName));
        expect(retrieved.description, equals(longDescription));
      });
      
      test('should handle special characters in search', () async {
        // Arrange
        final book = createTestFriendBook(
          name: 'Café & Restaurant Friends',
          description: 'Ümlauts and special chars: äöü ßñ',
        );
        await repository.saveFriendBook(book);
        
        // Act
        final results1 = await repository.searchFriendBooks('Café');
        final results2 = await repository.searchFriendBooks('äöü');
        
        // Assert
        expect(results1.length, equals(1));
        expect(results2.length, equals(1));
      });
      
      test('should handle invalid color hex values', () async {
        // Arrange
        final book = createTestFriendBook(colorHex: 'invalid-color');
        
        // Act & Assert - should not throw
        await repository.saveFriendBook(book);
        final retrieved = await repository.getFriendBookById(book.id);
        expect(retrieved!.colorHex, equals('invalid-color'));
      });
    });
    
    group('Concurrent Operations', () {
      test('should handle concurrent saves', () async {
        // Arrange
        final books = createTestFriendBooks(10);
        
        // Act
        final futures = books.map((b) => repository.saveFriendBook(b)).toList();
        await Future.wait(futures);
        
        final allBooks = await repository.getAllFriendBooks();
        
        // Assert
        expect(allBooks.length, equals(10));
      });
      
      test('should handle concurrent friend additions to same book', () async {
        // Arrange
        final friends = createTestFriends(5);
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        final book = createTestFriendBook(name: 'Concurrent Book');
        await repository.saveFriendBook(book);
        
        // Act
        final futures = friends.map((f) => repository.addFriendToBook(book.id, f.id)).toList();
        await Future.wait(futures);
        
        // Assert
        final updatedBook = await repository.getFriendBookById(book.id);
        expect(updatedBook!.friendIds.length, equals(5));
        
        // Verify all friends have the book association
        for (final friend in friends) {
          final updatedFriend = await friendRepository.getFriendById(friend.id);
          expect(updatedFriend!.friendBookIds, contains(book.id));
        }
      });
      
      test('should handle concurrent searches', () async {
        // Arrange
        final books = createTestFriendBooks(20);
        for (final book in books) {
          await repository.saveFriendBook(book);
        }
        
        // Act
        final searchFutures = List.generate(
          5, 
          (index) => repository.searchFriendBooks('Book $index')
        );
        final results = await Future.wait(searchFutures);
        
        // Assert
        for (int i = 0; i < results.length; i++) {
          expect(results[i].length, equals(1));
          expect(results[i].first.name, equals('Test Book $i'));
        }
      });
    });
    
    group('Complex Integration Scenarios', () {
      test('should handle book with many friends and complex operations', () async {
        // Arrange
        final friends = createTestFriends(50);
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        final book = createTestFriendBook(name: 'Large Book');
        await repository.saveFriendBook(book);
        
        // Act - Add all friends
        for (final friend in friends) {
          await repository.addFriendToBook(book.id, friend.id);
        }
        
        // Remove some friends
        final toRemove = friends.take(10).toList();
        for (final friend in toRemove) {
          await repository.removeFriendFromBook(book.id, friend.id);
        }
        
        // Assert
        final finalCount = await repository.getFriendCountInBook(book.id);
        expect(finalCount, equals(40)); // 50 - 10 = 40
        
        final finalBook = await repository.getFriendBookById(book.id);
        expect(finalBook!.friendIds.length, equals(40));
        
        // Verify removed friends don't have book association
        for (final removedFriend in toRemove) {
          final friend = await friendRepository.getFriendById(removedFriend.id);
          expect(friend!.friendBookIds, isNot(contains(book.id)));
        }
      });
      
      test('should maintain data consistency when friends are deleted elsewhere', () async {
        // Arrange
        final friend = createTestFriend(name: 'To Be Deleted');
        await friendRepository.saveFriend(friend);
        
        final book = createTestFriendBook(name: 'Test Book', friendIds: [friend.id]);
        await repository.saveFriendBook(book);
        
        // Verify initial state
        expect(await repository.getFriendCountInBook(book.id), equals(1));
        
        // Act - Delete friend directly from friend repository
        await friendRepository.deleteFriend(friend.id);
        
        // Assert - Count should reflect reality and clean up orphaned ID
        final countAfterDeletion = await repository.getFriendCountInBook(book.id);
        expect(countAfterDeletion, equals(0));
        
        final updatedBook = await repository.getFriendBookById(book.id);
        expect(updatedBook!.friendIds, isEmpty);
      });
    });
  });
}