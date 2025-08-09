// Unit tests for Friend entity
// 
// Tests the Friend entity's functionality and data integrity

import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/features/friend/domain/entities/friend.dart';

void main() {
  group('Friend Entity Tests', () {
    // Test data setup
    final testDate = DateTime(2024, 1, 15);
    final testBirthday = DateTime(1990, 5, 20);
    
    test('should create Friend instance with all required fields', () {
      // Arrange & Act
      final friend = Friend(
        id: '123',
        name: 'Max Mustermann',
        firstMetDate: testDate,
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      // Assert
      expect(friend.id, '123');
      expect(friend.name, 'Max Mustermann');
      expect(friend.firstMetDate, testDate);
      expect(friend.templateType, 'classic');
      expect(friend.isFavorite, false);
    });
    
    test('should create Friend instance with optional fields', () {
      // Arrange & Act
      final friend = Friend(
        id: '456',
        name: 'Erika Musterfrau',
        nickname: 'Eri',
        photoPath: '/path/to/photo.jpg',
        firstMetLocation: 'Berlin',
        firstMetLatitude: 52.5200,
        firstMetLongitude: 13.4050,
        firstMetDate: testDate,
        birthday: testBirthday,
        phone: '+49 123 456789',
        email: 'erika@example.com',
        homeLocation: 'Hamburg',
        work: 'Software Developer',
        likes: 'Coding, Coffee',
        dislikes: 'Bugs',
        hobbies: 'Reading, Gaming',
        favoriteColor: 'Blue',
        socialMedia: '@erika',
        notes: 'Met at conference',
        templateType: 'modern',
        friendBookIds: ['book1', 'book2'],
        isFavorite: true,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      // Assert
      expect(friend.nickname, 'Eri');
      expect(friend.photoPath, '/path/to/photo.jpg');
      expect(friend.firstMetLocation, 'Berlin');
      expect(friend.firstMetLatitude, 52.5200);
      expect(friend.firstMetLongitude, 13.4050);
      expect(friend.birthday, testBirthday);
      expect(friend.phone, '+49 123 456789');
      expect(friend.email, 'erika@example.com');
      expect(friend.homeLocation, 'Hamburg');
      expect(friend.work, 'Software Developer');
      expect(friend.likes, 'Coding, Coffee');
      expect(friend.dislikes, 'Bugs');
      expect(friend.hobbies, 'Reading, Gaming');
      expect(friend.favoriteColor, 'Blue');
      expect(friend.socialMedia, '@erika');
      expect(friend.notes, 'Met at conference');
      expect(friend.friendBookIds.length, 2);
      expect(friend.isFavorite, true);
    });
    
    test('should correctly implement copyWith method', () {
      // Arrange
      final original = Friend(
        id: '789',
        name: 'Original Name',
        firstMetDate: testDate,
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      // Act
      final modified = original.copyWith(
        name: 'Modified Name',
        isFavorite: true,
        nickname: 'Nick',
      );
      
      // Assert
      expect(modified.name, 'Modified Name');
      expect(modified.isFavorite, true);
      expect(modified.nickname, 'Nick');
      expect(modified.id, original.id); // Should remain unchanged
      expect(modified.firstMetDate, original.firstMetDate); // Should remain unchanged
    });
    
    test('should correctly compare friends using Equatable', () {
      // Arrange
      final friend1 = Friend(
        id: 'same-id',
        name: 'John Doe',
        firstMetDate: testDate,
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      final friend2 = Friend(
        id: 'same-id',
        name: 'John Doe',
        firstMetDate: testDate,
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      final friend3 = Friend(
        id: 'different-id',
        name: 'John Doe',
        firstMetDate: testDate,
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: testDate,
        updatedAt: testDate,
      );
      
      // Assert
      expect(friend1, equals(friend2)); // Same data
      expect(friend1, isNot(equals(friend3))); // Different ID
    });
  });
}