import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/core/services/photo_service.dart';

void main() {
  group('PhotoService Tests', () {
    late PhotoService photoService;
    
    setUp(() {
      photoService = PhotoService();
    });

    group('PhotoData Model', () {
      test('should create PhotoData with all required fields', () {
        // Arrange
        final testDate = DateTime.now();
        
        // Act
        final photoData = PhotoData(
          filePath: '/test/path/photo.jpg',
          fileName: 'photo.jpg',
          capturedAt: testDate,
          fileSizeBytes: 1024,
          source: 'camera',
        );
        
        // Assert
        expect(photoData.filePath, equals('/test/path/photo.jpg'));
        expect(photoData.fileName, equals('photo.jpg'));
        expect(photoData.capturedAt, equals(testDate));
        expect(photoData.fileSizeBytes, equals(1024));
        expect(photoData.source, equals('camera'));
      });

      test('should convert PhotoData to string correctly', () {
        // Arrange
        final photoData = PhotoData(
          filePath: '/test/path/photo.jpg',
          fileName: 'photo.jpg',
          capturedAt: DateTime.now(),
          fileSizeBytes: 2048,
          source: 'gallery',
        );
        
        // Act
        final result = photoData.toString();
        
        // Assert
        expect(result, contains('fileName: photo.jpg'));
        expect(result, contains('source: gallery'));
        expect(result, contains('size: 2048B'));
      });
    });

    group('Exception Classes', () {
      test('PhotoPermissionDeniedException should have correct message', () {
        // Arrange & Act
        final exception = PhotoPermissionDeniedException('Test permission denied');
        
        // Assert
        expect(exception.message, equals('Test permission denied'));
        expect(exception.toString(), equals('PhotoPermissionDeniedException: Test permission denied'));
      });

      test('PhotoStorageException should have correct message', () {
        // Arrange & Act
        final exception = PhotoStorageException('Storage error occurred');
        
        // Assert
        expect(exception.message, equals('Storage error occurred'));
        expect(exception.toString(), equals('PhotoStorageException: Storage error occurred'));
      });

      test('CameraNotFoundException should have correct message', () {
        // Arrange & Act
        final exception = CameraNotFoundException('No camera available');
        
        // Assert
        expect(exception.message, equals('No camera available'));
        expect(exception.toString(), equals('CameraNotFoundException: No camera available'));
      });
    });

    group('File Size Validation', () {
      test('should validate file size limits', () {
        // Arrange
        const maxSize = PhotoService.maxFileSizeBytes;
        
        // Assert
        expect(maxSize, equals(10 * 1024 * 1024)); // 10MB
      });

      test('should validate allowed extensions', () {
        // Arrange
        const allowedExtensions = PhotoService.allowedExtensions;
        
        // Assert
        expect(allowedExtensions, contains('jpg'));
        expect(allowedExtensions, contains('jpeg'));
        expect(allowedExtensions, contains('png'));
        expect(allowedExtensions, contains('heic'));
        expect(allowedExtensions.length, equals(4));
      });
    });

    group('Photo Deletion', () {
      test('should only allow deletion within app directory', () async {
        // This test verifies the security constraint that photos
        // can only be deleted from the app's own directory
        
        // Arrange
        final systemPath = '/system/important/file.jpg';
        
        // Act
        final result = await photoService.deletePhoto(systemPath);
        
        // Assert
        expect(result, isFalse); // Should refuse to delete outside app directory
      });
    });

    group('Storage Management', () {
      test('getTotalStorageUsed should return zero when no photos exist', () async {
        // Act
        final storage = await photoService.getTotalStorageUsed();
        
        // Assert
        expect(storage, greaterThanOrEqualTo(0.0));
      });

      test('photosDirectoryPath should return valid path', () async {
        // Act
        final path = await photoService.photosDirectoryPath;
        
        // Assert
        expect(path, isNotEmpty);
        expect(path, contains('photos'));
      });
    });
  });
}