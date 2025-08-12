// Friend Location Entity
// 
// Represents a friend's current location and status on the map
// Version 0.4.0

import 'package:equatable/equatable.dart';

/// Entity representing a friend's location and status for map display
class FriendLocation extends Equatable {
  /// Friend's unique identifier
  final String friendId;
  
  /// Friend's display name/nickname
  final String displayName;
  
  /// Current latitude coordinate
  final double latitude;
  
  /// Current longitude coordinate  
  final double longitude;
  
  /// Single emoji representing friend's current status
  final String statusEmoji;
  
  /// Whether friend is actively sharing their location
  final bool isSharing;
  
  /// Last time location was updated
  final DateTime lastUpdated;
  
  /// Friend's theme color (from friendbook or default)
  final String? colorHex;
  
  /// Friend's photo path for marker display
  final String? photoPath;
  
  /// Friendbook IDs this friend belongs to
  final List<String> friendBookIds;
  
  const FriendLocation({
    required this.friendId,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.statusEmoji,
    required this.isSharing,
    required this.lastUpdated,
    this.colorHex,
    this.photoPath,
    required this.friendBookIds,
  });
  
  /// Creates a copy with updated fields
  FriendLocation copyWith({
    String? friendId,
    String? displayName,
    double? latitude,
    double? longitude,
    String? statusEmoji,
    bool? isSharing,
    DateTime? lastUpdated,
    String? colorHex,
    String? photoPath,
    List<String>? friendBookIds,
  }) {
    return FriendLocation(
      friendId: friendId ?? this.friendId,
      displayName: displayName ?? this.displayName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      statusEmoji: statusEmoji ?? this.statusEmoji,
      isSharing: isSharing ?? this.isSharing,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      colorHex: colorHex ?? this.colorHex,
      photoPath: photoPath ?? this.photoPath,
      friendBookIds: friendBookIds ?? this.friendBookIds,
    );
  }
  
  /// Check if location is recent (within last hour)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inHours < 1;
  }
  
  /// Get formatted time since last update
  String get timeSinceUpdate {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    
    if (difference.inMinutes < 1) {
      return 'Gerade eben';
    } else if (difference.inMinutes < 60) {
      return 'Vor ${difference.inMinutes} Min.';
    } else if (difference.inHours < 24) {
      return 'Vor ${difference.inHours} Std.';
    } else {
      return 'Vor ${difference.inDays} Tagen';
    }
  }
  
  @override
  List<Object?> get props => [
    friendId,
    displayName,
    latitude,
    longitude,
    statusEmoji,
    isSharing,
    lastUpdated,
    colorHex,
    photoPath,
    friendBookIds,
  ];
}