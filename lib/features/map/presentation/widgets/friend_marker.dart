// Friend Marker Widget
// 
// Custom map marker showing friend's nickname and status emoji
// Version 0.4.0

import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/friend_location.dart';

/// Custom marker widget for displaying friend on map
class FriendMarker extends StatelessWidget {
  final FriendLocation location;
  final VoidCallback? onTap;
  
  const FriendMarker({
    super.key,
    required this.location,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markerColor = location.colorHex != null
        ? _parseColor(location.colorHex!, theme.colorScheme.primary)
        : theme.colorScheme.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status emoji and marker pin
          Stack(
            alignment: Alignment.center,
            children: [
              // Pin shape with shadow
              CustomPaint(
                size: const Size(40, 50),
                painter: _MarkerPinPainter(
                  color: markerColor,
                  isRecent: location.isRecent,
                ),
              ),
              
              // Status emoji or photo
              Positioned(
                top: 5,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: markerColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: location.photoPath != null && File(location.photoPath!).existsSync()
                        ? ClipOval(
                            child: Image.file(
                              File(location.photoPath!),
                              width: 26,
                              height: 26,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            location.statusEmoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ),
            ],
          ),
          
          // Nickname label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              location.displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Parse color from hex string safely
  Color _parseColor(String colorHex, Color fallback) {
    try {
      // Remove any leading hash if present
      String hex = colorHex.replaceAll('#', '');
      
      // Check if it already has 0xFF prefix
      if (hex.startsWith('0xFF') || hex.startsWith('0xff')) {
        return Color(int.parse(hex));
      }
      
      // Add alpha if not present
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      
      // Parse the color
      return Color(int.parse('0x$hex'));
    } catch (e) {
      // Return fallback color if parsing fails
      return fallback;
    }
  }
}

/// Custom painter for the marker pin shape
class _MarkerPinPainter extends CustomPainter {
  final Color color;
  final bool isRecent;
  
  _MarkerPinPainter({
    required this.color,
    required this.isRecent,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    // Draw path for pin shape
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height * 0.35;
    final radius = size.width * 0.35;
    
    // Create teardrop shape
    path.moveTo(centerX, size.height);
    path.quadraticBezierTo(
      centerX - radius * 0.5, centerY + radius * 0.7,
      centerX - radius, centerY,
    );
    path.arcToPoint(
      Offset(centerX + radius, centerY),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.quadraticBezierTo(
      centerX + radius * 0.5, centerY + radius * 0.7,
      centerX, size.height,
    );
    path.close();
    
    // Draw shadow
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);
    
    // Draw pin
    canvas.drawPath(path, paint);
    
    // Draw pulse animation for recent locations
    if (isRecent) {
      final pulsePaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius + 3,
        pulsePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _MarkerPinPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isRecent != isRecent;
  }
}

/// Clustered marker for multiple friends at same location
class ClusteredFriendMarker extends StatelessWidget {
  final List<FriendLocation> locations;
  final VoidCallback? onTap;
  
  const ClusteredFriendMarker({
    super.key,
    required this.locations,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = locations.length;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+$count',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (count <= 3)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: locations
                      .take(3)
                      .map((loc) => Text(
                            loc.statusEmoji,
                            style: const TextStyle(fontSize: 8),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}