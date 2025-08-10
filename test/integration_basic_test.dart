// Basic Integration Tests
//
// Simplified integration tests to verify cross-feature functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:myfriends/features/friendbook/data/repositories/friend_book_repository_impl.dart';
import 'package:myfriends/features/template/data/repositories/template_repository_impl.dart';
import 'helpers/test_setup.dart';

void main() {
  group('MyFriends Integration Basic Tests', () {
    late FriendRepositoryImpl friendRepository;
    late FriendBookRepositoryImpl friendBookRepository;
    late TemplateRepositoryImpl templateRepository;
    
    setUp(() async {
      await setupHiveForTesting();
      friendRepository = FriendRepositoryImpl();
      friendBookRepository = FriendBookRepositoryImpl();
      templateRepository = TemplateRepositoryImpl();
    });
    
    tearDown(() async {
      await clearHiveBox('friends');
      await clearHiveBox('friendbooks');
      await clearHiveBox('templates');
      await cleanupHive();
    });
    
    test('should create friends with custom templates and organize in books', () async {
      // Step 1: Create custom template
      final customTemplate = createTestTemplate(
        name: 'Work Template',
        visibleFields: ['name', 'email', 'phone', 'work'],
        requiredFields: ['name', 'email'],
      );
      await templateRepository.saveTemplate(customTemplate);
      
      // Step 2: Create friend book
      final friendBook = createTestFriendBook(name: 'Work Colleagues');
      await friendBookRepository.saveFriendBook(friendBook);
      
      // Step 3: Create friends with different templates
      final friends = [
        createTestFriend(name: 'John Work', templateType: customTemplate.id),
        createTestFriend(name: 'Jane Classic', templateType: 'classic'),
        createTestFriend(name: 'Bob Modern', templateType: 'modern'),
      ];
      
      for (final friend in friends) {
        await friendRepository.saveFriend(friend);
      }
      
      // Step 4: Add friends to book
      for (final friend in friends) {
        await friendBookRepository.addFriendToBook(friendBook.id, friend.id);
      }
      
      // Verify integration
      final bookCount = await friendBookRepository.getFriendCountInBook(friendBook.id);
      expect(bookCount, equals(3));
      
      final friendsInBook = await friendRepository.getFriendsByBookId(friendBook.id);
      expect(friendsInBook.length, equals(3));
      
      // Verify all friends are associated with the book
      for (final friend in friends) {
        final updatedFriend = await friendRepository.getFriendById(friend.id);
        expect(updatedFriend!.friendBookIds, contains(friendBook.id));
      }
      
      // Verify templates are accessible
      final workTemplate = await templateRepository.getTemplateById(customTemplate.id);
      final classicTemplate = await templateRepository.getTemplateById('classic');
      final modernTemplate = await templateRepository.getTemplateById('modern');
      
      expect(workTemplate, isNotNull);
      expect(classicTemplate, isNotNull);
      expect(modernTemplate, isNotNull);
    });
    
    test('should handle friend deletion with book cleanup', () async {
      // Arrange - Create friend and book with association
      final friend = createTestFriend(name: 'To Delete');
      await friendRepository.saveFriend(friend);
      
      final book = createTestFriendBook(name: 'Test Book');
      await friendBookRepository.saveFriendBook(book);
      await friendBookRepository.addFriendToBook(book.id, friend.id);
      
      // Verify initial state
      expect(await friendBookRepository.getFriendCountInBook(book.id), equals(1));
      
      // Act - Delete friend
      await friendRepository.deleteFriend(friend.id);
      
      // Assert - Book should be cleaned up
      final countAfterDeletion = await friendBookRepository.getFriendCountInBook(book.id);
      expect(countAfterDeletion, equals(0));
      
      final updatedBook = await friendBookRepository.getFriendBookById(book.id);
      expect(updatedBook!.friendIds, isEmpty);
    });
    
    test('should handle template deletion with existing friends', () async {
      // Arrange - Create custom template and friends using it
      final customTemplate = createTestTemplate(name: 'To Delete Template');
      await templateRepository.saveTemplate(customTemplate);
      
      final friends = [
        createTestFriend(name: 'Friend 1', templateType: customTemplate.id),
        createTestFriend(name: 'Friend 2', templateType: 'classic'),
      ];
      
      for (final friend in friends) {
        await friendRepository.saveFriend(friend);
      }
      
      // Act - Delete template
      final deleted = await templateRepository.deleteTemplate(customTemplate.id);
      expect(deleted, isTrue);
      
      // Assert - Friends should still exist
      for (final originalFriend in friends) {
        final friend = await friendRepository.getFriendById(originalFriend.id);
        expect(friend, isNotNull);
        expect(friend!.name, equals(originalFriend.name));
      }
      
      // Template should be gone
      final template = await templateRepository.getTemplateById(customTemplate.id);
      expect(template, isNull);
    });
    
    test('should handle complex friend-book relationships', () async {
      // Arrange - Create multiple friends and books
      final friends = [
        createTestFriend(name: 'Friend 1'),
        createTestFriend(name: 'Friend 2'),
        createTestFriend(name: 'Friend 3'),
      ];
      for (final friend in friends) {
        await friendRepository.saveFriend(friend);
      }
      
      final books = [
        createTestFriendBook(name: 'Book 1'),
        createTestFriendBook(name: 'Book 2'),
      ];
      for (final book in books) {
        await friendBookRepository.saveFriendBook(book);
      }
      
      // Act - Create complex relationships
      // Friend 1 -> Book 1, 2
      await friendBookRepository.addFriendToBook(books[0].id, friends[0].id);
      await friendBookRepository.addFriendToBook(books[1].id, friends[0].id);
      
      // Friend 2 -> Book 1
      await friendBookRepository.addFriendToBook(books[0].id, friends[1].id);
      
      // Friend 3 -> Book 2
      await friendBookRepository.addFriendToBook(books[1].id, friends[2].id);
      
      // Assert - Verify all relationships
      final friend1 = await friendRepository.getFriendById(friends[0].id);
      expect(friend1!.friendBookIds.toSet(), equals({books[0].id, books[1].id}));
      
      final friend2 = await friendRepository.getFriendById(friends[1].id);
      expect(friend2!.friendBookIds, equals([books[0].id]));
      
      final friend3 = await friendRepository.getFriendById(friends[2].id);
      expect(friend3!.friendBookIds, equals([books[1].id]));
      
      // Verify book contents
      expect(await friendBookRepository.getFriendCountInBook(books[0].id), equals(2));
      expect(await friendBookRepository.getFriendCountInBook(books[1].id), equals(2));
      
      final book1Friends = await friendRepository.getFriendsByBookId(books[0].id);
      expect(book1Friends.map((f) => f.name).toSet(), equals({'Friend 1', 'Friend 2'}));
      
      final book2Friends = await friendRepository.getFriendsByBookId(books[1].id);
      expect(book2Friends.map((f) => f.name).toSet(), equals({'Friend 1', 'Friend 3'}));
    });
  });
}