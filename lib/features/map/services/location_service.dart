// Location Service
// 
// Handles location permissions, tracking, and geocoding
// Version 0.4.0

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for handling location-related operations
class LocationService {
  /// Request location permission from user
  Future<bool> requestLocationPermission() async {
    // Check current permission status
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      // Request permission
      final result = await Permission.location.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // Open app settings for user to manually enable
      await openAppSettings();
      return false;
    }
    
    return false;
  }
  
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  /// Get current device location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }
      
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }
      
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }
  
  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];
        
        if (place.street != null && place.street!.isNotEmpty) {
          parts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          parts.add(place.postalCode!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          parts.add(place.country!);
        }
        
        return parts.join(', ');
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    return null;
  }
  
  /// Search for address using OpenStreetMap Nominatim API
  /// Returns coordinates if found
  Future<(double lat, double lon)?> searchAddress(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=1'
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MyFriendsApp/1.0', // Required by Nominatim
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final result = results.first;
          final lat = double.parse(result['lat']);
          final lon = double.parse(result['lon']);
          return (lat, lon);
        }
      }
    } catch (e) {
      debugPrint('Error searching address: $e');
    }
    return null;
  }
  
  /// Calculate distance between two coordinates in meters
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  /// Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
  
  /// Generate mock locations around a center point for demo
  List<(double lat, double lon)> generateMockLocationsNearby({
    required double centerLat,
    required double centerLon,
    required int count,
    double radiusKm = 5.0,
  }) {
    final random = Random();
    final locations = <(double, double)>[];
    
    for (int i = 0; i < count; i++) {
      // Generate random angle and distance
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radiusKm;
      
      // Convert distance to degrees (approximate)
      // 1 degree latitude ≈ 111 km
      // 1 degree longitude varies by latitude
      final latOffset = (distance / 111) * cos(angle);
      final lonOffset = (distance / (111 * cos(centerLat * pi / 180))) * sin(angle);
      
      locations.add((
        centerLat + latOffset,
        centerLon + lonOffset,
      ));
    }
    
    return locations;
  }
  
  /// Check if location is within a certain radius
  bool isWithinRadius({
    required double centerLat,
    required double centerLon,
    required double targetLat,
    required double targetLon,
    required double radiusMeters,
  }) {
    final distance = calculateDistance(centerLat, centerLon, targetLat, targetLon);
    return distance <= radiusMeters;
  }
  
  /// Get random status emoji for demo
  String getRandomStatusEmoji() {
    final emojis = ['😊', '🎉', '😴', '🏃', '🍕', '☕', '🎮', '📚', '🎵', '🚗'];
    final random = Random();
    return emojis[random.nextInt(emojis.length)];
  }
  
  /// Stream location updates
  Stream<Position> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}