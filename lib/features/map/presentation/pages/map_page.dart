// Map Page
// 
// Main map view showing friend locations and controls
// Version 0.4.0

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../core/providers/core_providers.dart';
import '../../services/location_service.dart';
import '../widgets/map_controls.dart';
import '../widgets/friendbook_selector.dart';
import '../widgets/beer_button.dart';
import '../widgets/friend_marker.dart';
import '../providers/map_provider.dart';

/// Main map page showing friend locations
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});
  
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> with TickerProviderStateMixin {
  // Map controller for programmatic map control
  late final MapController _mapController;
  
  // Animation controller for smooth transitions
  late final AnimationController _animationController;
  
  // Location service
  final LocationService _locationService = LocationService();
  
  // Current map settings
  bool _isFollowingLocation = false;
  String _mapType = 'normal'; // normal or satellite
  double _currentZoom = 13.0;
  LatLng _currentCenter = const LatLng(52.520008, 13.404954); // Default: Berlin
  
  // Selected friendbook
  String? _selectedFriendBookId;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Initialize location
    _initializeLocation();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Initialize user location
  Future<void> _initializeLocation() async {
    final hasPermission = await _locationService.requestLocationPermission();
    if (hasPermission) {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
        });
        
        // Animate to user location
        _animateToLocation(_currentCenter);
      }
    }
  }
  
  /// Animate map to a specific location
  void _animateToLocation(LatLng location, {double? zoom}) {
    _mapController.move(location, zoom ?? _currentZoom);
  }
  
  /// Handle map type change
  void _onMapTypeChanged(String type) {
    setState(() {
      _mapType = type;
    });
  }
  
  /// Handle zoom change
  void _onZoomChanged(double zoom) {
    setState(() {
      _currentZoom = zoom;
    });
    _mapController.move(_mapController.camera.center, zoom);
  }
  
  /// Handle current location button press
  void _onCurrentLocationPressed() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final location = LatLng(position.latitude, position.longitude);
      _animateToLocation(location, zoom: 15.0);
      setState(() {
        _isFollowingLocation = true;
      });
    }
  }
  
  /// Handle address search
  void _onSearchAddress(String query) async {
    final result = await _locationService.searchAddress(query);
    if (result != null) {
      final location = LatLng(result.$1, result.$2);
      _animateToLocation(location, zoom: 16.0);
    } else {
      // Show error
      ref.read(notificationServiceProvider).showError('Adresse nicht gefunden');
    }
  }
  
  /// Handle friendbook selection change
  void _onFriendBookChanged(String? friendBookId) {
    setState(() {
      _selectedFriendBookId = friendBookId;
    });
    
    // Reload friend locations for selected friendbook
    ref.invalidate(friendLocationsProvider);
  }
  
  /// Handle beer button press
  void _onBeerButtonPressed() {
    if (_selectedFriendBookId == null) {
      ref.read(notificationServiceProvider).showWarning('Bitte wähle zuerst ein Freundesbuch aus');
      return;
    }
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍺 Bier-Einladung'),
        content: const Text('Möchtest du alle Freunde in diesem Freundesbuch zu einem Bier einladen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Send notification (mocked for now)
              ref.read(notificationServiceProvider).showSuccess('Einladung wurde gesendet! 🍺');
            },
            child: const Text('Einladen'),
          ),
        ],
      ),
    );
  }
  
  /// Get tile layer based on map type
  TileLayer _getTileLayer() {
    if (_mapType == 'satellite') {
      // Using ESRI satellite imagery (free tier)
      return TileLayer(
        urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        userAgentPackageName: 'com.myfriends.app',
      );
    } else {
      // Using OpenStreetMap tiles
      return TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.myfriends.app',
        maxZoom: 19,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final navigationService = ref.read(navigationServiceProvider);
    final friendLocationsAsync = ref.watch(friendLocationsProvider(_selectedFriendBookId));
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        navigationService.navigateBack(context);
      },
      child: Scaffold(
        appBar: StandardAppBar(
          title: 'Freunde Karte',
          actions: [
            // Map type toggle
            IconButton(
              icon: Icon(_mapType == 'normal' ? Icons.satellite : Icons.map),
              onPressed: () => _onMapTypeChanged(
                _mapType == 'normal' ? 'satellite' : 'normal'
              ),
              tooltip: _mapType == 'normal' ? 'Satellit' : 'Karte',
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: _currentZoom,
                minZoom: 3.0,
                maxZoom: 18.0,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture && _isFollowingLocation) {
                    setState(() {
                      _isFollowingLocation = false;
                    });
                  }
                },
              ),
              children: [
                // Tile layer (map tiles)
                _getTileLayer(),
                
                // Current location layer
                CurrentLocationLayer(
                  alignPositionOnUpdate: _isFollowingLocation 
                      ? AlignOnUpdate.always 
                      : AlignOnUpdate.never,
                  alignDirectionOnUpdate: AlignOnUpdate.never,
                  style: const LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      color: Colors.blue,
                      child: Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    markerSize: Size(40, 40),
                    markerDirection: MarkerDirection.heading,
                    accuracyCircleColor: Color.fromARGB(50, 33, 150, 243),
                    headingSectorColor: Color.fromARGB(100, 33, 150, 243),
                    headingSectorRadius: 60,
                  ),
                ),
                
                // Friend markers layer
                MarkerLayer(
                  markers: friendLocationsAsync.when(
                    data: (locations) => locations.map((location) {
                      return Marker(
                        point: LatLng(location.latitude, location.longitude),
                        width: 80,
                        height: 80,
                        child: FriendMarker(
                          location: location,
                          onTap: () {
                            // Show friend details
                            _showFriendDetails(location);
                          },
                        ),
                      );
                    }).toList(),
                    loading: () => [],
                    error: (_, __) => [],
                  ),
                ),
              ],
            ),
            
            // Map controls overlay
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  // Search bar
                  MapSearchBar(
                    onSearch: _onSearchAddress,
                  ),
                  const SizedBox(height: 8),
                  
                  // FriendBook selector
                  FriendBookSelector(
                    selectedFriendBookId: _selectedFriendBookId,
                    onChanged: _onFriendBookChanged,
                  ),
                ],
              ),
            ),
            
            // Zoom controls
            Positioned(
              right: 16,
              bottom: 120,
              child: MapZoomControls(
                currentZoom: _currentZoom,
                onZoomIn: () => _onZoomChanged(_currentZoom + 1),
                onZoomOut: () => _onZoomChanged(_currentZoom - 1),
              ),
            ),
            
            // Current location button
            Positioned(
              right: 16,
              bottom: 200,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: _isFollowingLocation 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.surface,
                onPressed: _onCurrentLocationPressed,
                child: Icon(
                  Icons.my_location,
                  color: _isFollowingLocation 
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            
            // Beer button
            Positioned(
              left: 16,
              bottom: 32,
              child: BeerButton(
                onPressed: _onBeerButtonPressed,
                isEnabled: _selectedFriendBookId != null,
              ),
            ),
            
            // Loading indicator
            if (friendLocationsAsync.isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Show friend details in a bottom sheet
  void _showFriendDetails(location) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  location.statusEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        location.timeSinceUpdate,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to friend detail
                    ref.read(navigationServiceProvider).navigateTo(
                      context,
                      '/friends/${location.friendId}',
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Profil anzeigen'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to location
                    _animateToLocation(
                      LatLng(location.latitude, location.longitude),
                      zoom: 16.0,
                    );
                  },
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigieren'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}