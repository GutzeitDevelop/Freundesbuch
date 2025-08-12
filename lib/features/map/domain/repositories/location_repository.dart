// Location Repository Interface
// 
// Defines the contract for location-related operations
// Version 0.4.0

import '../entities/friend_location.dart';

/// Repository interface for location operations
abstract class LocationRepository {
  /// Get all friend locations for a specific friendbook
  Future<List<FriendLocation>> getFriendLocations(String friendBookId);
  
  /// Get all friend locations across all friendbooks
  Future<List<FriendLocation>> getAllFriendLocations();
  
  /// Update a friend's location
  Future<void> updateFriendLocation(FriendLocation location);
  
  /// Update user's own location
  Future<void> updateUserLocation(double latitude, double longitude);
  
  /// Get user's current location
  Future<(double latitude, double longitude)?> getUserLocation();
  
  /// Toggle location sharing for a friend
  Future<void> toggleLocationSharing(String friendId, bool isSharing);
  
  /// Update friend's status emoji
  Future<void> updateFriendStatus(String friendId, String statusEmoji);
  
  /// Send "Let's drink" notification to friendbook
  Future<void> sendDrinkNotification(String friendBookId);
  
  /// Search for address and get coordinates
  Future<(double latitude, double longitude)?> searchAddress(String query);
  
  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(double latitude, double longitude);
  
  /// Mock friend locations for demo purposes
  Future<List<FriendLocation>> generateMockLocations(String friendBookId);
}