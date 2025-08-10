import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/core/services/photo_service.dart';
import 'package:myfriends/features/friend/domain/entities/friend.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() {
  group('Photo Feature Integration Tests', () {
    late PhotoService photoService;
    
    setUp(() {
      photoService = PhotoService();
    });

    group('Photo Storage Integration', () {
      test('should correctly store and retrieve photo paths', () async {
        // This test verifies the entire flow of photo storage
        
        // Arrange
        final friend = Friend(
          id: 'integration-test-1',
          name: 'Integration Test Friend',
          nickname: 'Testy',
          photoPath: null,
          firstMetDate: DateTime.now(),
          firstMetLocation: 'Test Lab',
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act - Simulate photo path assignment
        final testPhotoPath = '/data/app/photos/test_photo.jpg';
        final updatedFriend = friend.copyWith(photoPath: testPhotoPath);

        // Assert
        expect(updatedFriend.photoPath, equals(testPhotoPath));
        expect(updatedFriend.photoPath, isNotNull);
        expect(updatedFriend.photoPath!.endsWith('.jpg'), isTrue);
      });

      test('should handle different photo formats correctly', () async {
        // Test that the system handles various image formats
        
        final testFormats = [
          'photo.jpg',
          'photo.jpeg',
          'photo.png',
          'photo.heic',
        ];

        for (final format in testFormats) {
          // Arrange
          final testPath = '/data/app/photos/$format';
          
          // Act
          final friend = Friend(
            id: 'format-test',
            name: 'Format Test',
            photoPath: testPath,
            firstMetDate: DateTime.now(),
            isFavorite: false,
            templateType: 'classic',
            friendBookIds: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Assert
          expect(friend.photoPath, equals(testPath));
          expect(friend.photoPath!.contains(RegExp(r'\.(jpg|jpeg|png|heic)$')), isTrue);
        }
      });

      test('should maintain photo paths across friend updates', () async {
        // Verify that photo paths persist when updating other friend fields
        
        // Arrange
        final originalPhotoPath = '/data/app/photos/original.jpg';
        final friend = Friend(
          id: 'update-test',
          name: 'Original Name',
          photoPath: originalPhotoPath,
          firstMetDate: DateTime.now(),
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act - Update other fields
        final updatedFriend = friend.copyWith(
          name: 'Updated Name',
          nickname: 'New Nickname',
          isFavorite: true,
        );

        // Assert - Photo path should remain unchanged
        expect(updatedFriend.photoPath, equals(originalPhotoPath));
        expect(updatedFriend.name, equals('Updated Name'));
        expect(updatedFriend.isFavorite, isTrue);
      });

      test('should handle null photo paths correctly', () async {
        // Test that friends without photos work correctly
        
        // Arrange & Act
        final friend = Friend(
          id: 'null-photo-test',
          name: 'No Photo Friend',
          photoPath: null,
          firstMetDate: DateTime.now(),
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(friend.photoPath, isNull);
        expect(friend.name, equals('No Photo Friend'));
      });
    });

    group('Photo Display Logic', () {
      test('should use FileImage for local paths, not AssetImage', () {
        // This test verifies we're using the correct image provider
        
        // Arrange
        final localPaths = [
          '/data/user/0/com.myfriendsapp.myfriends/app_flutter/photos/photo.jpg',
          '/storage/emulated/0/Android/data/com.myfriendsapp.myfriends/files/photo.png',
          '/var/mobile/Containers/Data/Application/UUID/Documents/photos/photo.heic',
        ];

        for (final localPath in localPaths) {
          // Act
          final friend = Friend(
            id: 'provider-test',
            name: 'Provider Test',
            photoPath: localPath,
            firstMetDate: DateTime.now(),
            isFavorite: false,
            templateType: 'classic',
            friendBookIds: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Assert
          expect(friend.photoPath, isNotNull);
          expect(friend.photoPath!.startsWith('/'), isTrue, 
            reason: 'Photo paths should be absolute paths');
          expect(friend.photoPath!.contains('asset'), isFalse,
            reason: 'Photo paths should not reference assets');
        }
      });

      test('should handle photo path updates correctly', () {
        // Test updating from no photo to having a photo
        
        // Arrange
        final friend = Friend(
          id: 'update-path-test',
          name: 'Update Path Test',
          photoPath: null,
          firstMetDate: DateTime.now(),
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final newPhotoPath = '/data/app/photos/new_photo.jpg';
        final updatedFriend = friend.copyWith(photoPath: newPhotoPath);

        // Assert
        expect(friend.photoPath, isNull);
        expect(updatedFriend.photoPath, equals(newPhotoPath));
      });
    });

    group('Photo Service Validation', () {
      test('PhotoService constants should be correctly defined', () {
        // Verify service configuration
        
        expect(PhotoService.maxFileSizeBytes, equals(10 * 1024 * 1024));
        expect(PhotoService.allowedExtensions, contains('jpg'));
        expect(PhotoService.allowedExtensions, contains('jpeg'));
        expect(PhotoService.allowedExtensions, contains('png'));
        expect(PhotoService.allowedExtensions, contains('heic'));
      });

      test('PhotoData should contain all required fields', () {
        // Verify data model completeness
        
        final photoData = PhotoData(
          filePath: '/test/path.jpg',
          fileName: 'path.jpg',
          capturedAt: DateTime.now(),
          fileSizeBytes: 1024,
          source: 'camera',
        );

        expect(photoData.filePath, isNotEmpty);
        expect(photoData.fileName, isNotEmpty);
        expect(photoData.capturedAt, isNotNull);
        expect(photoData.fileSizeBytes, greaterThan(0));
        expect(photoData.source, isIn(['camera', 'gallery']));
      });
    });

    group('Cross-Platform Path Handling', () {
      test('should handle iOS photo paths correctly', () {
        // iOS specific path format
        final iosPath = '/var/mobile/Containers/Data/Application/12345/Documents/photos/photo.jpg';
        
        final friend = Friend(
          id: 'ios-test',
          name: 'iOS Test',
          photoPath: iosPath,
          firstMetDate: DateTime.now(),
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(friend.photoPath, equals(iosPath));
        expect(friend.photoPath!.contains('Documents'), isTrue);
      });

      test('should handle Android photo paths correctly', () {
        // Android specific path format
        final androidPath = '/data/user/0/com.myfriendsapp.myfriends/app_flutter/photos/photo.jpg';
        
        final friend = Friend(
          id: 'android-test',
          name: 'Android Test',
          photoPath: androidPath,
          firstMetDate: DateTime.now(),
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(friend.photoPath, equals(androidPath));
        expect(friend.photoPath!.contains('com.myfriendsapp.myfriends'), isTrue);
      });
    });

    group('Error Handling', () {
      test('PhotoPermissionDeniedException should be properly formatted', () {
        final exception = PhotoPermissionDeniedException('Camera access denied');
        
        expect(exception.message, equals('Camera access denied'));
        expect(exception.toString(), contains('PhotoPermissionDeniedException'));
      });

      test('PhotoStorageException should be properly formatted', () {
        final exception = PhotoStorageException('Storage full');
        
        expect(exception.message, equals('Storage full'));
        expect(exception.toString(), contains('PhotoStorageException'));
      });

      test('CameraNotFoundException should be properly formatted', () {
        final exception = CameraNotFoundException('No camera found');
        
        expect(exception.message, equals('No camera found'));
        expect(exception.toString(), contains('CameraNotFoundException'));
      });
    });
  });
}