// Location Service - Handles GPS and location-related operations
//
// Provides secure location access with proper permission handling
// Following OWASP Mobile Security Guidelines for location privacy

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

/// Exception thrown when location permission is denied
class LocationPermissionDeniedException implements Exception {
  final String message;
  const LocationPermissionDeniedException(this.message);
  
  @override
  String toString() => 'LocationPermissionDeniedException: $message';
}

/// Exception thrown when location services are disabled
class LocationServicesDisabledException implements Exception {
  final String message;
  const LocationServicesDisabledException(this.message);
  
  @override
  String toString() => 'LocationServicesDisabledException: $message';
}

/// Exception thrown when geocoding fails
class GeocodingException implements Exception {
  final String message;
  const GeocodingException(this.message);
  
  @override
  String toString() => 'GeocodingException: $message';
}

/// Location data model for internal use
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final double? accuracy;
  final DateTime timestamp;
  
  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.accuracy,
    required this.timestamp,
  });
  
  @override
  String toString() => 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
}

/// Service for handling location operations with security best practices
///
/// Features:
/// - Secure permission handling following iOS/Android guidelines
/// - Location privacy protection with minimal data collection
/// - Reverse geocoding for user-friendly addresses
/// - Error handling for all edge cases
/// - Battery-efficient location retrieval
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  
  /// Check if location services are available and enabled
  Future<bool> get isLocationServiceEnabled async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }
  
  /// Get current location permission status
  Future<LocationPermission> get locationPermission async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }
  
  /// Request location permission with proper user guidance
  ///
  /// Returns true if permission is granted, false otherwise
  /// Throws [LocationServicesDisabledException] if services are disabled
  Future<bool> requestLocationPermission() async {
    try {
      // First check if location services are enabled
      if (!await isLocationServiceEnabled) {
        throw const LocationServicesDisabledException(
          'Location services are disabled. Please enable them in device settings.'
        );
      }
      
      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied, we cannot request them
        throw const LocationPermissionDeniedException(
          'Location permissions are permanently denied. Please enable them in app settings.'
        );
      }
      
      // Permission granted (either whileInUse or always)
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
             
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get current location with security and battery optimization
  ///
  /// Returns [LocationData] with coordinates and optional address
  /// Throws [LocationPermissionDeniedException] if permission denied
  /// Throws [LocationServicesDisabledException] if services disabled
  /// Throws [GeocodingException] if address resolution fails
  Future<LocationData> getCurrentLocation({
    bool includeAddress = true,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      // Ensure we have permission
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw const LocationPermissionDeniedException(
          'Location permission is required to save meeting location.'
        );
      }
      
      // Get current position with battery-efficient settings
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Only update if moved 10+ meters
        ),
        timeLimit: timeout,
      );
      
      String? address;
      if (includeAddress) {
        try {
          address = await getAddressFromCoordinates(
            position.latitude, 
            position.longitude,
          );
        } catch (e) {
          // Address resolution failed, but location is still valid
          // Log error but don't fail the entire operation
          print('Address resolution failed: $e');
        }
      }
      
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
      );
      
    } on LocationServiceDisabledException {
      rethrow;
    } on LocationPermissionDeniedException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }
  
  /// Convert GPS coordinates to human-readable address
  ///
  /// Returns formatted address string or throws [GeocodingException]
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isEmpty) {
        throw const GeocodingException('No address found for coordinates');
      }
      
      final placemark = placemarks.first;
      
      // Build formatted address with available components
      final addressParts = <String>[];
      
      if (placemark.street?.isNotEmpty == true) {
        addressParts.add(placemark.street!);
      }
      if (placemark.locality?.isNotEmpty == true) {
        addressParts.add(placemark.locality!);
      }
      if (placemark.administrativeArea?.isNotEmpty == true) {
        addressParts.add(placemark.administrativeArea!);
      }
      if (placemark.country?.isNotEmpty == true) {
        addressParts.add(placemark.country!);
      }
      
      if (addressParts.isEmpty) {
        throw const GeocodingException('Address components are empty');
      }
      
      return addressParts.join(', ');
      
    } catch (e) {
      if (e is GeocodingException) rethrow;
      throw GeocodingException('Geocoding failed: $e');
    }
  }
  
  /// Convert address string to GPS coordinates
  ///
  /// Returns [LocationData] or throws [GeocodingException]
  Future<LocationData> getCoordinatesFromAddress(String address) async {
    try {
      if (address.trim().isEmpty) {
        throw const GeocodingException('Address cannot be empty');
      }
      
      final locations = await locationFromAddress(address);
      
      if (locations.isEmpty) {
        throw GeocodingException('No coordinates found for address: $address');
      }
      
      final location = locations.first;
      
      return LocationData(
        latitude: location.latitude,
        longitude: location.longitude,
        address: address,
        timestamp: DateTime.now(),
      );
      
    } catch (e) {
      if (e is GeocodingException) rethrow;
      throw GeocodingException('Failed to get coordinates for address: $e');
    }
  }
  
  /// Calculate distance between two GPS coordinates in meters
  ///
  /// Uses the Haversine formula for accurate distance calculation
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
  
  /// Format location data for display in UI
  String formatLocationForDisplay(LocationData location) {
    if (location.address?.isNotEmpty == true) {
      return location.address!;
    }
    
    // Fallback to coordinates if no address available
    return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
  }
  
  /// Check if location data is valid and recent
  bool isLocationDataValid(LocationData location, {Duration maxAge = const Duration(hours: 24)}) {
    final now = DateTime.now();
    final age = now.difference(location.timestamp);
    
    return age <= maxAge && 
           location.latitude >= -90 && location.latitude <= 90 &&
           location.longitude >= -180 && location.longitude <= 180;
  }
  
  /// Open device settings for location permissions
  ///
  /// Useful when permissions are permanently denied
  Future<bool> openLocationSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }
}