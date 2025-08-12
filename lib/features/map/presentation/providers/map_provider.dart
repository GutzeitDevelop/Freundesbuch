// Map Provider
// 
// State management for map features and friend locations
// Version 0.4.0

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/friend/domain/entities/friend.dart';
import '../../../../features/friend/presentation/providers/friends_provider.dart';
import '../../../../features/friendbook/presentation/providers/friend_books_provider.dart';
import '../../domain/entities/friend_location.dart';
import '../../services/location_service.dart';

/// Provider for friend locations based on selected friendbook
final friendLocationsProvider = FutureProvider.family<List<FriendLocation>, String?>((ref, friendBookId) async {
  final locationService = LocationService();
  
  // Get all friends first
  final friendsAsync = ref.watch(friendsProvider);
  
  // Get friends list
  List<Friend> allFriends = [];
  if (friendsAsync.hasValue) {
    allFriends = friendsAsync.value!;
  }
  
  // Filter friends based on friendbook selection
  List<Friend> friends;
  if (friendBookId != null) {
    // Filter friends that belong to the specific friendbook
    friends = allFriends.where((friend) => friend.friendBookIds.contains(friendBookId)).toList();
  } else {
    // Use all friends
    friends = allFriends;
  }
  
  // Get current user location for generating mock data
  final userPosition = await locationService.getCurrentLocation();
  final centerLat = userPosition?.latitude ?? 52.520008; // Default: Berlin
  final centerLon = userPosition?.longitude ?? 13.404954;
  
  // Generate mock locations for demo
  final mockLocations = locationService.generateMockLocationsNearby(
    centerLat: centerLat,
    centerLon: centerLon,
    count: friends.length,
    radiusKm: 3.0,
  );
  
  // Create friend locations with mock data
  final locations = <FriendLocation>[];
  final random = Random();
  
  for (int i = 0; i < friends.length; i++) {
    final friend = friends[i];
    final mockLocation = i < mockLocations.length 
        ? mockLocations[i] 
        : (centerLat + (random.nextDouble() - 0.5) * 0.05, 
           centerLon + (random.nextDouble() - 0.5) * 0.05);
    
    // Check if friend has location data or use mock
    final latitude = friend.currentLatitude ?? mockLocation.$1;
    final longitude = friend.currentLongitude ?? mockLocation.$2;
    
    // Generate random status emoji if not set
    final statusEmoji = friend.statusEmoji ?? locationService.getRandomStatusEmoji();
    
    // Generate random last update time (within last 24 hours)
    final lastUpdate = DateTime.now().subtract(
      Duration(minutes: random.nextInt(1440)), // 0-24 hours ago
    );
    
    locations.add(FriendLocation(
      friendId: friend.id,
      displayName: friend.nickname ?? friend.name,
      latitude: latitude,
      longitude: longitude,
      statusEmoji: statusEmoji,
      isSharing: friend.isLocationSharingEnabled,
      lastUpdated: friend.lastLocationUpdate ?? lastUpdate,
      colorHex: null, // Will be set from friendbook
      photoPath: friend.photoPath,
      friendBookIds: friend.friendBookIds,
    ));
  }
  
  return locations;
});

/// Provider for current map view settings
final mapSettingsProvider = StateNotifierProvider<MapSettingsNotifier, MapSettings>((ref) {
  return MapSettingsNotifier();
});

/// Map settings state
class MapSettings {
  final String mapType; // 'normal' or 'satellite'
  final double zoom;
  final bool showFriendNames;
  final bool showDistances;
  final bool clusterMarkers;
  
  const MapSettings({
    this.mapType = 'normal',
    this.zoom = 13.0,
    this.showFriendNames = true,
    this.showDistances = false,
    this.clusterMarkers = false,
  });
  
  MapSettings copyWith({
    String? mapType,
    double? zoom,
    bool? showFriendNames,
    bool? showDistances,
    bool? clusterMarkers,
  }) {
    return MapSettings(
      mapType: mapType ?? this.mapType,
      zoom: zoom ?? this.zoom,
      showFriendNames: showFriendNames ?? this.showFriendNames,
      showDistances: showDistances ?? this.showDistances,
      clusterMarkers: clusterMarkers ?? this.clusterMarkers,
    );
  }
}

/// Map settings state notifier
class MapSettingsNotifier extends StateNotifier<MapSettings> {
  MapSettingsNotifier() : super(const MapSettings());
  
  void setMapType(String type) {
    state = state.copyWith(mapType: type);
  }
  
  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom);
  }
  
  void toggleFriendNames() {
    state = state.copyWith(showFriendNames: !state.showFriendNames);
  }
  
  void toggleDistances() {
    state = state.copyWith(showDistances: !state.showDistances);
  }
  
  void toggleClustering() {
    state = state.copyWith(clusterMarkers: !state.clusterMarkers);
  }
}