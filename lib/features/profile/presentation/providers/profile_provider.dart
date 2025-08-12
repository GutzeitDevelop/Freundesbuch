// Profile Provider
// 
// Manages user profile state with Riverpod
// Version 0.3.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';

/// Provider for profile repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

/// State notifier for user profile
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final ProfileRepository _repository;
  
  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }
  
  /// Load profile from storage
  Future<void> loadProfile() async {
    try {
      state = const AsyncValue.loading();
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Create a new profile
  Future<void> createProfile(UserProfile profile) async {
    try {
      state = const AsyncValue.loading();
      
      // Ensure the profile has an ID
      final profileWithId = profile.copyWith(
        id: profile.id.isEmpty ? const Uuid().v4() : profile.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _repository.saveProfile(profileWithId);
      state = AsyncValue.data(profileWithId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Update existing profile
  Future<void> updateProfile(UserProfile profile) async {
    try {
      // Optimistic update
      state = AsyncValue.data(profile);
      
      await _repository.updateProfile(profile);
      
      // Reload to ensure consistency
      await loadProfile();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      // Reload previous state
      await loadProfile();
    }
  }
  
  /// Delete profile
  Future<void> deleteProfile() async {
    try {
      state = const AsyncValue.loading();
      await _repository.deleteProfile();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Update profile photo
  Future<void> updatePhoto(String photoPath) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;
    
    final updatedProfile = currentProfile.copyWith(
      photoPath: photoPath,
      updatedAt: DateTime.now(),
    );
    
    await updateProfile(updatedProfile);
  }
  
  /// Check if profile exists
  Future<bool> hasProfile() async {
    try {
      return await _repository.hasProfile();
    } catch (e) {
      return false;
    }
  }
  
  /// Export profile to JSON
  Future<Map<String, dynamic>?> exportProfile() async {
    try {
      return await _repository.exportProfile();
    } catch (e) {
      return null;
    }
  }
  
  /// Import profile from JSON
  Future<void> importProfile(Map<String, dynamic> data) async {
    try {
      state = const AsyncValue.loading();
      await _repository.importProfile(data);
      await loadProfile();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Create profile from friend data (for quick import)
  Future<void> createFromFriendData({
    required String name,
    String? nickname,
    String? phone,
    String? email,
    String? homeLocation,
    String? work,
    String? likes,
    String? dislikes,
    String? hobbies,
  }) async {
    final profile = UserProfile(
      id: const Uuid().v4(),
      name: name,
      nickname: nickname,
      phone: phone,
      email: email,
      homeLocation: homeLocation,
      work: work,
      likes: likes,
      dislikes: dislikes,
      hobbies: hobbies,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await createProfile(profile);
  }
}

/// Provider for profile state
final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

/// Provider to check if profile exists
final hasProfileProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.hasProfile();
});

/// Provider for profile completion percentage
final profileCompletionProvider = Provider<double>((ref) {
  final profileAsync = ref.watch(profileProvider);
  
  return profileAsync.when(
    data: (profile) => profile?.completionPercentage ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});