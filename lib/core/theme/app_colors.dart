// App Color Palette for MyFriends
// 
// Color scheme designed for warmth and friendliness
// Supporting both light and dark modes
// 
// Primary colors represent connection and trust
// Secondary colors for actions and highlights

import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors - Warm and friendly blue tones
  static const Color primaryBlue = Color(0xFF2196F3);  // Main brand color
  static const Color primaryBlueDark = Color(0xFF1976D2);  // Darker variant
  static const Color primaryBlueLight = Color(0xFF64B5F6);  // Lighter variant
  static const Color primary = primaryBlue;  // Alias for primary color
  
  // Secondary Colors - Accent and complementary
  static const Color secondaryOrange = Color(0xFFFF9800);  // Warm accent
  static const Color secondaryOrangeDark = Color(0xFFF57C00);
  static const Color secondaryOrangeLight = Color(0xFFFFB74D);
  static const Color secondary = secondaryOrange;  // Alias for secondary color
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);  // Green for success
  static const Color warning = Color(0xFFFFC107);  // Amber for warnings
  static const Color error = Color(0xFFF44336);  // Red for errors
  static const Color info = Color(0xFF2196F3);  // Blue for information
  
  // Neutral Colors - Grays and blacks
  static const Color textPrimary = Color(0xFF212121);  // Almost black
  static const Color textSecondary = Color(0xFF757575);  // Medium gray
  static const Color textDisabled = Color(0xFFBDBDBD);  // Light gray
  static const Color divider = Color(0xFFE0E0E0);  // Very light gray
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);  // Off-white
  static const Color backgroundWhite = Color(0xFFFFFFFF);  // Pure white
  static const Color backgroundGrey = Color(0xFFF5F5F5);  // Light grey
  static const Color surface = backgroundGrey;  // Alias for surface color
  
  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF121212);  // Dark background
  static const Color surfaceDark = Color(0xFF1E1E1E);  // Dark surface
  static const Color textPrimaryDark = Color(0xFFE0E0E0);  // Light text on dark
  static const Color textSecondaryDark = Color(0xFFB0B0B0);  // Medium light text
  
  // Special Purpose Colors
  static const Color friendCardBackground = Color(0xFFF3F8FF);  // Light blue tint
  static const Color locationPin = Color(0xFFE91E63);  // Pink for location
  static const Color photoFrame = Color(0xFF9C27B0);  // Purple for photos
  static const Color favoriteHeart = Color(0xFFE91E63);  // Pink for favorites
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryOrange, secondaryOrangeLight],
  );
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);  // 10% black
  static const Color shadowMedium = Color(0x33000000);  // 20% black
  static const Color shadowDark = Color(0x4D000000);  // 30% black
  
  // Material Design Elevation Overlays for Dark Theme
  static Color elevationOverlay(BuildContext context, double elevation) {
    final ThemeData theme = Theme.of(context);
    if (theme.brightness == Brightness.light) {
      return Colors.transparent;
    }
    
    // Material Design elevation overlay percentages
    final double opacity = {
      0.0: 0.0,
      1.0: 0.05,
      2.0: 0.07,
      3.0: 0.08,
      4.0: 0.09,
      6.0: 0.11,
      8.0: 0.12,
      12.0: 0.14,
      16.0: 0.15,
      24.0: 0.16,
    }[elevation] ?? 0.0;
    
    return Colors.white.withValues(alpha: opacity);
  }
}