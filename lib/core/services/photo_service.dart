import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Custom exceptions for photo-related errors
/// Following OWASP Mobile Security Guidelines for proper error handling
class PhotoPermissionDeniedException implements Exception {
  final String message;
  const PhotoPermissionDeniedException(this.message);
  
  @override
  String toString() => 'PhotoPermissionDeniedException: $message';
}

class PhotoStorageException implements Exception {
  final String message;
  const PhotoStorageException(this.message);
  
  @override
  String toString() => 'PhotoStorageException: $message';
}

class CameraNotFoundException implements Exception {
  final String message;
  const CameraNotFoundException(this.message);
  
  @override
  String toString() => 'CameraNotFoundException: $message';
}

/// Photo data container with metadata for security tracking
class PhotoData {
  final String filePath;
  final String fileName;
  final DateTime capturedAt;
  final int fileSizeBytes;
  final String source; // 'camera' or 'gallery'
  
  const PhotoData({
    required this.filePath,
    required this.fileName,
    required this.capturedAt,
    required this.fileSizeBytes,
    required this.source,
  });
  
  @override
  String toString() => 'PhotoData(fileName: $fileName, source: $source, size: ${fileSizeBytes}B)';
}

/// Secure photo service implementation following OWASP Mobile Security Guidelines
/// 
/// Key Security Features:
/// - Uses image_picker which handles permissions internally on iOS
/// - Secure local storage in app-specific directories
/// - File size and type validation
/// - No metadata leakage in error messages
/// - Proper resource cleanup
/// 
/// Developer Notes:
/// This service handles both camera capture and gallery selection.
/// On iOS, image_picker handles permission requests and shows native dialogs.
/// All photos are stored locally in the app's documents directory with unique filenames.
class PhotoService {
  final ImagePicker _picker = ImagePicker();
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB max file size
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'heic'];
  
  /// Captures a photo using the device camera
  /// 
  /// Simply uses image_picker which handles permissions internally on iOS
  /// This avoids conflicts with permission_handler
  Future<PhotoData> captureFromCamera() async {
    try {
      // Let image_picker handle permissions internally
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,  // Balance quality vs performance
        maxHeight: 1920,
        imageQuality: 85, // Good quality with reasonable file size
        preferredCameraDevice: CameraDevice.rear, // Default to rear camera
      );
      
      if (image == null) {
        throw const PhotoStorageException('Photo capture was cancelled');
      }
      
      // Validate file before processing
      await _validatePhotoFile(image);
      
      // Save to secure app directory with unique filename
      return await _savePhotoToAppDirectory(image, 'camera');
      
    } catch (e) {
      if (kDebugMode) {
        print('PhotoService.captureFromCamera error: $e');
      }
      
      if (e is PhotoStorageException) {
        rethrow;
      }
      
      // If image_picker fails due to permissions, it will show iOS dialog
      throw const PhotoPermissionDeniedException(
        'Camera permission is required to take photos'
      );
    }
  }
  
  /// Selects a photo from the device gallery
  /// 
  /// Simply uses image_picker which handles permissions internally on iOS
  Future<PhotoData> selectFromGallery() async {
    try {
      // Let image_picker handle permissions internally
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,  // Resize large images for performance
        maxHeight: 1920,
        imageQuality: 90, // Slightly higher quality for gallery images
      );
      
      if (image == null) {
        throw const PhotoStorageException('Photo selection was cancelled');
      }
      
      // Validate selected file
      await _validatePhotoFile(image);
      
      // Copy to secure app directory
      return await _savePhotoToAppDirectory(image, 'gallery');
      
    } catch (e) {
      if (kDebugMode) {
        print('PhotoService.selectFromGallery error: $e');
      }
      
      if (e is PhotoStorageException) {
        rethrow;
      }
      
      // If image_picker fails due to permissions, it will show iOS dialog
      throw const PhotoPermissionDeniedException(
        'Photo library permission is required to select photos'
      );
    }
  }
  
  /// Deletes a photo file securely from the app directory
  /// 
  /// Security: Only allows deletion of files within app directory
  /// to prevent accidental deletion of system files
  Future<bool> deletePhoto(String filePath) async {
    try {
      final file = File(filePath);
      final appDir = await getApplicationDocumentsDirectory();
      
      // Security: Ensure file is within app directory
      if (!filePath.startsWith(appDir.path)) {
        if (kDebugMode) {
          print('PhotoService: Attempted to delete file outside app directory: $filePath');
        }
        return false;
      }
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('PhotoService.deletePhoto error: $e');
      }
      return false;
    }
  }
  
  /// Validates photo file size and format for security
  Future<void> _validatePhotoFile(XFile image) async {
    final fileSize = await image.length();
    
    // Security: Prevent DOS attacks via large files
    if (fileSize > maxFileSizeBytes) {
      throw PhotoStorageException(
        'Photo file too large: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB (max: ${maxFileSizeBytes / 1024 / 1024}MB)'
      );
    }
    
    // Security: Validate file extension
    final extension = path.extension(image.path).toLowerCase().replaceFirst('.', '');
    if (!allowedExtensions.contains(extension)) {
      throw const PhotoStorageException(
        'Unsupported photo format. Please use JPG, PNG, or HEIC files.'
      );
    }
  }
  
  /// Saves photo to secure app directory with unique filename
  Future<PhotoData> _savePhotoToAppDirectory(XFile image, String source) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(path.join(appDir.path, 'photos'));
      
      // Create photos directory if it doesn't exist
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }
      
      // Generate unique filename with timestamp to prevent conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(image.path);
      final fileName = 'photo_${timestamp}_$source$extension';
      final filePath = path.join(photosDir.path, fileName);
      
      // Copy file to app directory
      final savedFile = await File(image.path).copy(filePath);
      final fileSize = await savedFile.length();
      
      // Clean up temporary file if different from saved file
      if (image.path != filePath) {
        try {
          await File(image.path).delete();
        } catch (e) {
          // Temporary file cleanup is not critical
          if (kDebugMode) {
            print('Failed to cleanup temporary file: $e');
          }
        }
      }
      
      // On iOS, we need to store only the filename, not the full path
      // because the app directory changes between app launches
      return PhotoData(
        filePath: fileName,  // Store only filename for iOS compatibility
        fileName: fileName,
        capturedAt: DateTime.now(),
        fileSizeBytes: fileSize,
        source: source,
      );
      
    } catch (e) {
      if (kDebugMode) {
        print('PhotoService._savePhotoToAppDirectory error: $e');
      }
      throw const PhotoStorageException('Failed to save photo to device');
    }
  }
  
  /// Returns the photos directory path for the app
  Future<String> get photosDirectoryPath async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, 'photos');
  }
  
  /// Resolves a photo path - handles both full paths and filenames
  /// This is needed for iOS where app directories change between launches
  static Future<String> resolvePhotoPath(String? pathOrFilename) async {
    if (pathOrFilename == null) return '';
    
    // If it's already a full path and the file exists, return it
    final file = File(pathOrFilename);
    if (await file.exists()) {
      return pathOrFilename;
    }
    
    // If it's just a filename or the full path doesn't exist,
    // reconstruct the path with current app directory
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(appDir.path, 'photos'));
    
    // Extract just the filename from the path
    final filename = path.basename(pathOrFilename);
    final fullPath = path.join(photosDir.path, filename);
    
    return fullPath;
  }
  
  /// Lists all photos in the app directory (for debugging/admin purposes)
  Future<List<PhotoData>> getAllPhotos() async {
    try {
      final photosDir = Directory(await photosDirectoryPath);
      
      if (!await photosDir.exists()) {
        return [];
      }
      
      final files = await photosDir.list().where((entity) => entity is File).cast<File>().toList();
      final photos = <PhotoData>[];
      
      for (final file in files) {
        final stat = await file.stat();
        final fileName = path.basename(file.path);
        
        // Extract source from filename if possible
        String source = 'unknown';
        if (fileName.contains('_camera')) {
          source = 'camera';
        } else if (fileName.contains('_gallery')) {
          source = 'gallery';
        }
        
        photos.add(PhotoData(
          filePath: file.path,
          fileName: fileName,
          capturedAt: stat.modified,
          fileSizeBytes: stat.size,
          source: source,
        ));
      }
      
      // Sort by capture date, newest first
      photos.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      
      return photos;
    } catch (e) {
      if (kDebugMode) {
        print('PhotoService.getAllPhotos error: $e');
      }
      return [];
    }
  }
  
  /// Gets total storage used by photos in MB
  Future<double> getTotalStorageUsed() async {
    try {
      final photos = await getAllPhotos();
      final totalBytes = photos.fold<int>(0, (sum, photo) => sum + photo.fileSizeBytes);
      return totalBytes / 1024 / 1024; // Convert to MB
    } catch (e) {
      if (kDebugMode) {
        print('PhotoService.getTotalStorageUsed error: $e');
      }
      return 0.0;
    }
  }
}