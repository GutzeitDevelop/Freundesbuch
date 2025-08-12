// Profile Repository Interface
// 
// Abstract repository for profile operations
// Version 0.3.0

import '../entities/user_profile.dart';

/// Repository interface for profile operations
abstract class ProfileRepository {
  /// Get the current user profile
  Future<UserProfile?> getProfile();
  
  /// Save a new profile
  Future<void> saveProfile(UserProfile profile);
  
  /// Update existing profile
  Future<void> updateProfile(UserProfile profile);
  
  /// Delete the profile
  Future<void> deleteProfile();
  
  /// Check if profile exists
  Future<bool> hasProfile();
  
  /// Export profile to JSON
  Future<Map<String, dynamic>> exportProfile();
  
  /// Import profile from JSON
  Future<void> importProfile(Map<String, dynamic> data);
}