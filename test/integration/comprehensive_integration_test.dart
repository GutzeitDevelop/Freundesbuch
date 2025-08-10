// Comprehensive Integration Tests
//
// Tests the interaction between all major features of the MyFriends app

import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/features/friend/data/repositories/friend_repository_impl.dart';
import 'package:myfriends/features/friendbook/data/repositories/friend_book_repository_impl.dart';
import 'package:myfriends/features/template/data/repositories/template_repository_impl.dart';
import 'package:myfriends/features/friend/domain/entities/friend.dart';
import 'package:myfriends/features/friendbook/domain/entities/friend_book.dart';
import 'package:myfriends/features/friend/domain/entities/friend_template.dart';
import '../helpers/test_setup.dart';

void main() {
  group('MyFriends App Integration Tests', () {
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
    
    group('Friend and FriendBook Integration', () {
      test('should maintain bidirectional associations when creating friends with books', () async {
        // Arrange
        final friendBook = createTestFriendBook(name: 'Work Colleagues');
        await friendBookRepository.saveFriendBook(friendBook);
        
        // Act - Create friend and add to book
        final friend = createTestFriend(name: 'John Doe');
        await friendRepository.saveFriend(friend);
        await friendBookRepository.addFriendToBook(friendBook.id, friend.id);
        
        // Assert - Verify bidirectional association
        final updatedFriend = await friendRepository.getFriendById(friend.id);
        expect(updatedFriend!.friendBookIds, contains(friendBook.id));
        
        final updatedBook = await friendBookRepository.getFriendBookById(friendBook.id);
        expect(updatedBook!.friendIds, contains(friend.id));
        
        final friendsInBook = await friendRepository.getFriendsByBookId(friendBook.id);
        expect(friendsInBook.length, equals(1));
        expect(friendsInBook.first.id, equals(friend.id));
      });
      
      test('should handle complex friend-book relationships', () async {
        // Arrange - Create multiple friends and books
        final friends = createTestFriends(5);
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        final books = createTestFriendBooks(3);
        for (final book in books) {
          await friendBookRepository.saveFriendBook(book);
        }
        
        // Act - Create complex relationships
        // Friend 0 -> Book 0, 1
        await friendBookRepository.addFriendToBook(books[0].id, friends[0].id);
        await friendBookRepository.addFriendToBook(books[1].id, friends[0].id);
        
        // Friend 1 -> Book 0, 2
        await friendBookRepository.addFriendToBook(books[0].id, friends[1].id);
        await friendBookRepository.addFriendToBook(books[2].id, friends[1].id);
        
        // Friend 2 -> Book 1
        await friendBookRepository.addFriendToBook(books[1].id, friends[2].id);
        
        // Friends 3, 4 -> No books
        
        // Assert - Verify all relationships
        final friend0 = await friendRepository.getFriendById(friends[0].id);
        expect(friend0!.friendBookIds.toSet(), equals({books[0].id, books[1].id}));
        
        final friend1 = await friendRepository.getFriendById(friends[1].id);
        expect(friend1!.friendBookIds.toSet(), equals({books[0].id, books[2].id}));
        
        final friend2 = await friendRepository.getFriendById(friends[2].id);
        expect(friend2!.friendBookIds, equals([books[1].id]));
        
        // Verify book contents
        final book0Friends = await friendRepository.getFriendsByBookId(books[0].id);
        expect(book0Friends.map((f) => f.id).toSet(), equals({friends[0].id, friends[1].id}));
        
        final book1Friends = await friendRepository.getFriendsByBookId(books[1].id);
        expect(book1Friends.map((f) => f.id).toSet(), equals({friends[0].id, friends[2].id}));
        
        final book2Friends = await friendRepository.getFriendsByBookId(books[2].id);
        expect(book2Friends.map((f) => f.id), equals([friends[1].id]));
      });
      
      test('should clean up relationships when friends are deleted', () async {
        // Arrange - Create friends and books with relationships
        final friends = createTestFriends(3);
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        final book = createTestFriendBook(name: 'Test Book');
        await friendBookRepository.saveFriendBook(book);
        
        // Add all friends to book
        for (final friend in friends) {
          await friendBookRepository.addFriendToBook(book.id, friend.id);
        }
        
        // Verify initial state
        expect(await friendBookRepository.getFriendCountInBook(book.id), equals(3));
        
        // Act - Delete one friend
        await friendRepository.deleteFriend(friends[1].id);
        
        // Assert - Book should be automatically cleaned up
        final count = await friendBookRepository.getFriendCountInBook(book.id);
        expect(count, equals(2));
        
        final updatedBook = await friendBookRepository.getFriendBookById(book.id);
        expect(updatedBook!.friendIds, isNot(contains(friends[1].id)));
        expect(updatedBook.friendIds.length, equals(2));
      });
      
      test('should clean up relationships when books are deleted', () async {
        // Arrange
        final friends = createTestFriends(2);
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        final book = createTestFriendBook(name: 'To Delete');
        await friendBookRepository.saveFriendBook(book);
        
        for (final friend in friends) {
          await friendBookRepository.addFriendToBook(book.id, friend.id);
        }
        
        // Verify initial associations
        for (final friend in friends) {
          final friendWithBook = await friendRepository.getFriendById(friend.id);
          expect(friendWithBook!.friendBookIds, contains(book.id));
        }
        
        // Act - Delete book
        await friendBookRepository.deleteFriendBook(book.id);
        
        // Assert - Friends should no longer reference the book
        for (final friend in friends) {
          final friendAfterBookDeletion = await friendRepository.getFriendById(friend.id);
          expect(friendAfterBookDeletion!.friendBookIds, isNot(contains(book.id)));
        }
      });
    });
    
    group('Friend and Template Integration', () {
      test('should create friends with custom templates', () async {
        // Arrange - Create custom template
        final customTemplate = createTestTemplate(
          name: 'Business Template',
          visibleFields: ['name', 'email', 'phone', 'work', 'homeLocation'],
          requiredFields: ['name', 'email'],
        );
        await templateRepository.saveTemplate(customTemplate);
        
        // Act - Create friend using custom template
        final friend = createTestFriend(
          name: 'Business Contact',
          templateType: customTemplate.id,
        );
        await friendRepository.saveFriend(friend);
        
        // Assert
        final savedFriend = await friendRepository.getFriendById(friend.id);
        expect(savedFriend!.templateType, equals(customTemplate.id));
        
        // Verify template exists and is retrievable
        final template = await templateRepository.getTemplateById(customTemplate.id);
        expect(template, isNotNull);
        expect(template!.name, equals('Business Template'));
      });
      
      test('should handle template deletion with existing friends', () async {
        // Arrange - Create custom template and friends using it
        final customTemplate = createTestTemplate(name: 'To Delete Template');
        await templateRepository.saveTemplate(customTemplate);
        
        final friends = [
          createTestFriend(name: 'Friend 1', templateType: customTemplate.id),
          createTestFriend(name: 'Friend 2', templateType: customTemplate.id),
          createTestFriend(name: 'Friend 3', templateType: 'classic'), // Different template
        ];
        
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        // Act - Delete template
        final deleted = await templateRepository.deleteTemplate(customTemplate.id);
        expect(deleted, isTrue);
        
        // Assert - Friends should still exist but template reference is orphaned
        for (int i = 0; i < friends.length; i++) {
          final friend = await friendRepository.getFriendById(friends[i].id);
          expect(friend, isNotNull);
          
          if (i < 2) {
            // These friends had the deleted template
            expect(friend!.templateType, equals(customTemplate.id));
          } else {
            // This friend had a different template
            expect(friend!.templateType, equals('classic'));
          }
        }
        
        // Template should be gone
        final template = await templateRepository.getTemplateById(customTemplate.id);
        expect(template, isNull);
      });
      
      test('should work with all template types', () async {
        // Arrange - Create friends with different template types
        final customTemplate = createTestTemplate(name: 'Custom Template');
        await templateRepository.saveTemplate(customTemplate);
        
        final friends = [
          createTestFriend(name: 'Classic Friend', templateType: 'classic'),
          createTestFriend(name: 'Modern Friend', templateType: 'modern'),
          createTestFriend(name: 'Custom Friend', templateType: customTemplate.id),
        ];
        
        // Act
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        // Assert - All templates should be accessible
        final classicTemplate = await templateRepository.getTemplateById('classic');
        final modernTemplate = await templateRepository.getTemplateById('modern');
        final customTemplateRetrieved = await templateRepository.getTemplateById(customTemplate.id);
        
        expect(classicTemplate, isNotNull);
        expect(modernTemplate, isNotNull);
        expect(customTemplateRetrieved, isNotNull);
        
        expect(classicTemplate!.type, equals(TemplateType.classic));
        expect(modernTemplate!.type, equals(TemplateType.modern));
        expect(customTemplateRetrieved!.type, equals(TemplateType.custom));
        
        // All friends should be retrievable
        for (final originalFriend in friends) {
          final savedFriend = await friendRepository.getFriendById(originalFriend.id);
          expect(savedFriend, isNotNull);
          expect(savedFriend!.name, equals(originalFriend.name));
        }
      });
    });
    
    group('Complete Workflow Integration', () {
      test('should handle complete friend management workflow', () async {
        // Scenario: User creates templates, books, and friends, then manages them
        
        // Step 1: Create custom templates
        final templates = [
          createTestTemplate(name: 'Work Template', visibleFields: ['name', 'email', 'phone', 'work']),
          createTestTemplate(name: 'Social Template', visibleFields: ['name', 'nickname', 'hobbies', 'socialMedia']),
        ];
        for (final template in templates) {
          await templateRepository.saveTemplate(template);
        }
        
        // Step 2: Create friend books
        final books = [
          createTestFriendBook(name: 'Work Colleagues', colorHex: '#2196F3', iconName: 'work'),
          createTestFriendBook(name: 'Social Friends', colorHex: '#4CAF50', iconName: 'group'),
          createTestFriendBook(name: 'Family', colorHex: '#FF5722', iconName: 'family_restroom'),
        ];
        for (final book in books) {
          await friendBookRepository.saveFriendBook(book);
        }
        
        // Step 3: Create friends with different templates
        final friends = [
          createTestFriend(name: 'John Work', templateType: templates[0].id),
          createTestFriend(name: 'Jane Social', templateType: templates[1].id),
          createTestFriend(name: 'Bob Classic', templateType: 'classic'),
          createTestFriend(name: 'Alice Modern', templateType: 'modern'),
          createTestFriend(name: 'Charlie Family', templateType: 'classic'),
        ];
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        // Step 4: Organize friends into books
        await friendBookRepository.addFriendToBook(books[0].id, friends[0].id); // John Work -> Work
        await friendBookRepository.addFriendToBook(books[1].id, friends[1].id); // Jane Social -> Social
        await friendBookRepository.addFriendToBook(books[1].id, friends[2].id); // Bob Classic -> Social
        await friendBookRepository.addFriendToBook(books[2].id, friends[4].id); // Charlie Family -> Family
        await friendBookRepository.addFriendToBook(books[0].id, friends[3].id); // Alice Modern -> Work (cross-template)
        
        // Step 5: Verify complete setup
        // Check templates
        final allTemplates = await templateRepository.getAllTemplates();
        expect(allTemplates.length, equals(4)); // 2 predefined + 2 custom
        
        // Check books and their friend counts
        expect(await friendBookRepository.getFriendCountInBook(books[0].id), equals(2)); // Work: John, Alice
        expect(await friendBookRepository.getFriendCountInBook(books[1].id), equals(2)); // Social: Jane, Bob
        expect(await friendBookRepository.getFriendCountInBook(books[2].id), equals(1)); // Family: Charlie
        
        // Check friends
        final allFriends = await friendRepository.getAllFriends();
        expect(allFriends.length, equals(5));
        
        // Step 6: Perform modifications
        // Update a friend's book membership
        await friendBookRepository.removeFriendFromBook(books[1].id, friends[2].id); // Remove Bob from Social
        await friendBookRepository.addFriendToBook(books[2].id, friends[2].id); // Add Bob to Family
        
        // Mark a friend as favorite
        final updatedFriend = friends[1].copyWith(isFavorite: true);
        await friendRepository.saveFriend(updatedFriend);
        
        // Delete a template (after creating a new one to replace it)
        final replacementTemplate = createTestTemplate(name: 'New Work Template');
        await templateRepository.saveTemplate(replacementTemplate);
        await templateRepository.deleteTemplate(templates[0].id);
        
        // Step 7: Verify modifications
        // Check updated book memberships
        expect(await friendBookRepository.getFriendCountInBook(books[1].id), equals(1)); // Social: only Jane
        expect(await friendBookRepository.getFriendCountInBook(books[2].id), equals(2)); // Family: Charlie, Bob
        
        // Check favorite friend
        final favoriteFriends = await friendRepository.getFavoriteFriends();
        expect(favoriteFriends.length, equals(1));
        expect(favoriteFriends.first.name, equals('Jane Social'));
        
        // Check template deletion
        final deletedTemplate = await templateRepository.getTemplateById(templates[0].id);
        expect(deletedTemplate, isNull);
        
        final newTemplate = await templateRepository.getTemplateById(replacementTemplate.id);
        expect(newTemplate, isNotNull);
      });
      
      test('should handle search operations across all entities', () async {
        // Arrange - Set up diverse data
        final customTemplate = createTestTemplate(name: 'Searchable Template');
        await templateRepository.saveTemplate(customTemplate);
        
        final friends = [
          createTestFriend(name: 'John Doe', nickname: 'Johnny'),
          createTestFriend(name: 'Jane Smith', nickname: 'Janey'),
          createTestFriend(name: 'Bob Johnson'),
          createTestFriend(name: 'Alice Brown', nickname: 'Ally'),
        ];
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        final books = [
          createTestFriendBook(name: 'Work Team', description: 'Office colleagues'),
          createTestFriendBook(name: 'Sports Club', description: 'Tennis and golf partners'),
          createTestFriendBook(name: 'Book Club', description: 'Monthly reading group'),
        ];
        for (final book in books) {
          await friendBookRepository.saveFriendBook(book);
        }
        
        // Act & Assert - Perform various searches
        
        // Search friends by name
        final johnSearch = await friendRepository.searchFriends('John');
        expect(johnSearch.length, equals(2)); // John Doe and Bob Johnson
        
        // Search friends by nickname
        final nicknameSearch = await friendRepository.searchFriends('Johnny');
        expect(nicknameSearch.length, equals(1));
        expect(nicknameSearch.first.name, equals('John Doe'));
        
        // Search friend books by name
        final bookSearch = await friendBookRepository.searchFriendBooks('Book');
        expect(bookSearch.length, equals(1));
        expect(bookSearch.first.name, equals('Book Club'));
        
        // Search friend books by description
        final descriptionSearch = await friendBookRepository.searchFriendBooks('Office');
        expect(descriptionSearch.length, equals(1));
        expect(descriptionSearch.first.name, equals('Work Team'));
        
        // Check template name existence
        final templateExists = await templateRepository.templateNameExists('Searchable Template');
        expect(templateExists, isTrue);
        
        final nonExistentTemplate = await templateRepository.templateNameExists('Non-existent Template');
        expect(nonExistentTemplate, isFalse);
      });
    });
    
    group('Data Consistency and Integrity', () {
      test('should maintain referential integrity under stress', () async {
        // Arrange - Create a complex interconnected dataset
        final templates = List.generate(5, (i) => createTestTemplate(name: 'Template $i'));
        for (final template in templates) {
          await templateRepository.saveTemplate(template);
        }
        
        final books = List.generate(10, (i) => createTestFriendBook(name: 'Book $i'));
        for (final book in books) {
          await friendBookRepository.saveFriendBook(book);
        }
        
        final friends = List.generate(20, (i) => createTestFriend(
          name: 'Friend $i',
          templateType: i < 5 ? templates[i].id : (i % 2 == 0 ? 'classic' : 'modern'),
        ));
        for (final friend in friends) {
          await friendRepository.saveFriend(friend);
        }
        
        // Create random associations
        for (int i = 0; i < friends.length; i++) {
          final bookIndex1 = i % books.length;
          final bookIndex2 = (i + 1) % books.length;
          if (bookIndex1 != bookIndex2) {
            await friendBookRepository.addFriendToBook(books[bookIndex1].id, friends[i].id);
            if (i % 3 == 0) { // Some friends in multiple books
              await friendBookRepository.addFriendToBook(books[bookIndex2].id, friends[i].id);
            }
          }
        }
        
        // Act - Perform destructive operations
        // Delete some templates
        for (int i = 0; i < 2; i++) {
          await templateRepository.deleteTemplate(templates[i].id);
        }
        
        // Delete some friends
        final friendsToDelete = friends.take(5).toList();
        for (final friend in friendsToDelete) {
          await friendRepository.deleteFriend(friend.id);
        }
        
        // Delete some books
        final booksToDelete = books.take(3).toList();
        for (final book in booksToDelete) {
          await friendBookRepository.deleteFriendBook(book.id);
        }
        
        // Assert - Verify data consistency
        final remainingFriends = await friendRepository.getAllFriends();
        final remainingBooks = await friendBookRepository.getAllFriendBooks();
        final remainingTemplates = await templateRepository.getAllTemplates();
        
        expect(remainingFriends.length, equals(15)); // 20 - 5 deleted
        expect(remainingBooks.length, equals(7)); // 10 - 3 deleted
        expect(remainingTemplates.length, equals(5)); // 2 predefined + 5 created - 2 deleted = 5
        
        // Verify no orphaned references exist
        for (final friend in remainingFriends) {
          for (final bookId in friend.friendBookIds) {
            final bookExists = remainingBooks.any((b) => b.id == bookId);
            expect(bookExists, isTrue, reason: 'Friend ${friend.name} references non-existent book $bookId');
          }
        }
        
        for (final book in remainingBooks) {
          for (final friendId in book.friendIds) {
            final friendExists = remainingFriends.any((f) => f.id == friendId);
            expect(friendExists, isTrue, reason: 'Book ${book.name} references non-existent friend $friendId');
          }
        }
        
        // Verify friend counts are accurate
        for (final book in remainingBooks) {
          final count = await friendBookRepository.getFriendCountInBook(book.id);
          expect(count, equals(book.friendIds.length));
        }
      });
      
      test('should handle concurrent operations across all repositories', () async {
        // Arrange - Set up initial data
        final template = createTestTemplate(name: 'Concurrent Template');
        await templateRepository.saveTemplate(template);
        
        final book = createTestFriendBook(name: 'Concurrent Book');
        await friendBookRepository.saveFriendBook(book);
        
        // Act - Perform concurrent operations
        final concurrentFriends = List.generate(20, (i) => createTestFriend(
          name: 'Concurrent Friend $i',
          templateType: i % 2 == 0 ? template.id : 'classic',
        ));
        
        // Save friends concurrently
        final friendSaveFutures = concurrentFriends.map((f) => friendRepository.saveFriend(f));
        await Future.wait(friendSaveFutures);
        
        // Add friends to book concurrently
        final addToBookFutures = concurrentFriends.map((f) => 
          friendBookRepository.addFriendToBook(book.id, f.id));
        await Future.wait(addToBookFutures);
        
        // Perform concurrent searches
        final searchFutures = [
          friendRepository.searchFriends('Concurrent'),
          friendBookRepository.searchFriendBooks('Concurrent'),
          templateRepository.templateNameExists('Concurrent Template'),
          friendRepository.getAllFriends(),
          friendBookRepository.getAllFriendBooks(),
          templateRepository.getAllTemplates(),
        ];
        final results = await Future.wait(searchFutures);
        
        // Assert
        final friendSearchResults = results[0] as List<Friend>;
        final bookSearchResults = results[1] as List<FriendBook>;
        final templateExists = results[2] as bool;
        final allFriends = results[3] as List<Friend>;
        final allBooks = results[4] as List<FriendBook>;
        final allTemplates = results[5] as List<FriendTemplate>;
        
        expect(friendSearchResults.length, equals(20));
        expect(bookSearchResults.length, equals(1));
        expect(templateExists, isTrue);
        expect(allFriends.length, equals(20));
        expect(allBooks.length, equals(1));
        expect(allTemplates.length, equals(3)); // 2 predefined + 1 custom
        
        // Verify final book state
        final finalCount = await friendBookRepository.getFriendCountInBook(book.id);
        expect(finalCount, equals(20));
      });
    });
  });
}