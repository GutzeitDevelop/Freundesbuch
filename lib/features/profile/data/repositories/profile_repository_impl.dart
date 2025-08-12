// Profile Repository Implementation
// 
// Handles profile data persistence using Hive
// Version 0.3.0

import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

/// Implementation of ProfileRepository using Hive
class ProfileRepositoryImpl implements ProfileRepository {
  static const String _boxName = 'userProfile';
  static const String _profileKey = 'currentProfile';
  
  Box<UserProfileModel>? _box;
  
  /// Get or open the Hive box
  Future<Box<UserProfileModel>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    
    _box = await Hive.openBox<UserProfileModel>(_boxName);
    return _box!;
  }
  
  @override
  Future<UserProfile?> getProfile() async {
    try {
      final box = await _getBox();
      final model = box.get(_profileKey);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }
  
  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      final box = await _getBox();
      final model = UserProfileModel.fromEntity(profile);
      await box.put(_profileKey, model);
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }
  
  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      // Update the updatedAt timestamp
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );
      await saveProfile(updatedProfile);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  @override
  Future<void> deleteProfile() async {
    try {
      final box = await _getBox();
      await box.delete(_profileKey);
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }
  
  @override
  Future<bool> hasProfile() async {
    try {
      final box = await _getBox();
      return box.containsKey(_profileKey);
    } catch (e) {
      throw Exception('Failed to check profile existence: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> exportProfile() async {
    try {
      final profile = await getProfile();
      if (profile == null) {
        throw Exception('No profile to export');
      }
      
      final model = UserProfileModel.fromEntity(profile);
      return model.toJson();
    } catch (e) {
      throw Exception('Failed to export profile: $e');
    }
  }
  
  @override
  Future<void> importProfile(Map<String, dynamic> data) async {
    try {
      final model = UserProfileModel.fromJson(data);
      final profile = model.toEntity();
      await saveProfile(profile);
    } catch (e) {
      throw Exception('Failed to import profile: $e');
    }
  }
  
  /// Close the box when done
  Future<void> close() async {
    await _box?.close();
  }
}