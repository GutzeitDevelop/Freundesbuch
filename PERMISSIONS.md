# Permissions Guide - MyFriends App

## 📱 Permission Overview

This document lists all permissions required by the MyFriends app, their use cases, and implementation details.

## 🔐 iOS Permissions (Info.plist)

### 1. Camera Access
**Permission Key**: `NSCameraUsageDescription`  
**User Message (DE)**: "MyFriends möchte auf die Kamera zugreifen, um Fotos von neuen Freunden aufzunehmen"  
**User Message (EN)**: "MyFriends would like to access the camera to take photos of new friends"  
**Use Case**: 
- Taking photos when adding new friends
- Capturing moments when meeting someone
- Profile picture updates

**Code Location**:
```dart
// lib/features/friend/presentation/pages/add_friend_page.dart
// lib/features/profile/presentation/pages/edit_profile_page.dart
```

### 2. Photo Library Access
**Permission Key**: `NSPhotoLibraryUsageDescription`  
**User Message (DE)**: "MyFriends möchte auf deine Fotos zugreifen, um Bilder für Freunde auszuwählen"  
**User Message (EN)**: "MyFriends would like to access your photos to select pictures for friends"  
**Use Case**:
- Selecting existing photos for friend entries
- Choosing profile pictures
- Importing memorable photos

**Code Location**:
```dart
// lib/features/friend/presentation/widgets/photo_selector.dart
// lib/core/utils/media_picker.dart
```

### 3. Location When In Use
**Permission Key**: `NSLocationWhenInUseUsageDescription`  
**User Message (DE)**: "MyFriends möchte deinen Standort verwenden, um zu speichern, wo du neue Freunde getroffen hast"  
**User Message (EN)**: "MyFriends would like to use your location to save where you met new friends"  
**Use Case**:
- Recording meeting location automatically
- Showing nearby friends on map (future feature)
- Location-based memories

**Code Location**:
```dart
// lib/features/friend/presentation/pages/add_friend_page.dart
// lib/core/services/location_service.dart
```

### 4. Face ID/Touch ID
**Permission Key**: `NSFaceIDUsageDescription`  
**User Message (DE)**: "MyFriends möchte Face ID/Touch ID verwenden, um deine privaten Daten zu schützen"  
**User Message (EN)**: "MyFriends would like to use Face ID/Touch ID to protect your private data"  
**Use Case**:
- App lock for privacy
- Secure access to sensitive friend information
- Protection of personal data

**Code Location**:
```dart
// lib/features/auth/presentation/pages/biometric_lock_page.dart
// lib/core/services/biometric_service.dart
```

## 🤖 Android Permissions (AndroidManifest.xml)

### 1. Camera
**Permission**: `android.permission.CAMERA`  
**Protection Level**: Dangerous  
**Use Case**: Same as iOS camera access  

**Implementation**:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
```

**Runtime Request**:
```dart
// lib/core/services/permission_service.dart
final status = await Permission.camera.request();
```

### 2. Read External Storage
**Permission**: `android.permission.READ_EXTERNAL_STORAGE`  
**Protection Level**: Dangerous  
**Use Case**: Reading photos from device gallery  
**Note**: For Android 13+, use `READ_MEDIA_IMAGES` instead

**Implementation**:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### 3. Write External Storage
**Permission**: `android.permission.WRITE_EXTERNAL_STORAGE`  
**Protection Level**: Dangerous  
**Use Case**: Saving photos taken within app  
**Note**: Not needed for Android 10+ (scoped storage)

**Implementation**:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="28" />
```

### 4. Access Fine Location
**Permission**: `android.permission.ACCESS_FINE_LOCATION`  
**Protection Level**: Dangerous  
**Use Case**: Precise location for meeting points  

**Implementation**:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 5. Use Biometric
**Permission**: `android.permission.USE_BIOMETRIC`  
**Protection Level**: Normal  
**Use Case**: Fingerprint/Face authentication  

**Implementation**:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### 6. Internet (Future Feature)
**Permission**: `android.permission.INTERNET`  
**Protection Level**: Normal  
**Use Case**: Cloud sync, profile sharing  

**Implementation**:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 🔄 Permission Request Flow

### Request Strategy
```dart
// lib/core/services/permission_service.dart
class PermissionService {
  // Check permission status before requesting
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isDenied) {
      // First time request
      final result = await Permission.camera.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // User previously denied, show settings dialog
      await _showSettingsDialog();
      return false;
    }
    
    return status.isGranted;
  }
  
  // Graceful degradation for denied permissions
  Future<void> handlePermissionDenied(Permission permission) async {
    switch (permission) {
      case Permission.camera:
        // Offer gallery selection as alternative
        await _offerGalleryAlternative();
        break;
      case Permission.location:
        // Offer manual location input
        await _offerManualLocationInput();
        break;
      default:
        // Show generic message
        await _showPermissionRationale(permission);
    }
  }
}
```

## 📊 Permission Matrix

| Feature | Camera | Photos | Location | Biometric | Storage |
|---------|--------|--------|----------|-----------|---------|
| Add Friend | Optional | Optional | Optional | No | Yes |
| Take Photo | Required | No | No | No | Yes |
| Select Photo | No | Required | No | No | Yes |
| Save Location | No | No | Optional | No | No |
| App Lock | No | No | No | Optional | No |
| Export Data | No | No | No | No | Yes |

## 🎯 Permission Best Practices

### 1. Just-In-Time Requests
- Request permissions only when needed
- Explain why before requesting
- Never request all permissions on app start

### 2. Graceful Degradation
- App remains functional without optional permissions
- Provide alternatives for denied permissions
- Clear communication about limited functionality

### 3. Permission Rationale
```dart
// lib/core/widgets/permission_rationale_dialog.dart
class PermissionRationaleDialog extends StatelessWidget {
  final Permission permission;
  final String rationale;
  
  // Shows user why permission is needed
  // Provides "Grant" and "Deny" options
  // Explains impact of denial
}
```

## 🔒 Privacy Considerations

### Data Minimization
- Only request necessary permissions
- Use least privileged access
- Remove unused permissions

### User Control
- Settings page for permission management
- Clear data deletion options
- Export personal data feature

### Transparency
- Clear permission descriptions
- No hidden permission usage
- Regular permission audits

## 🧪 Testing Permissions

### Unit Tests
```dart
// test/services/permission_service_test.dart
test('Camera permission request flow', () async {
  when(mockPermission.camera.status)
    .thenAnswer((_) async => PermissionStatus.denied);
  
  final granted = await service.requestCameraPermission();
  
  verify(mockPermission.camera.request()).called(1);
  expect(granted, isTrue);
});
```

### Integration Tests
- Test permission denial scenarios
- Verify fallback behaviors
- Check settings redirection

## 📱 Platform Differences

### iOS Specific
- Permissions cannot be requested again after denial
- Must redirect to Settings app
- More descriptive usage descriptions required

### Android Specific
- Can request permissions multiple times
- Runtime permissions for dangerous permissions
- Permission groups affect related permissions

## 🔄 Future Permissions

### Planned for Future Releases
1. **Contacts Access**: Import friends from contacts
2. **Calendar Access**: Add friend birthdays to calendar
3. **Notification Permission**: Reminder notifications
4. **Background Location**: Location-based features

## 📝 Permission Checklist

### Before Release
- [ ] All permission strings translated (DE/EN)
- [ ] Usage descriptions are clear and honest
- [ ] Fallback behaviors implemented
- [ ] Settings page includes permission management
- [ ] Privacy policy updated with permission usage
- [ ] App store descriptions mention permissions

---

## ✅ Currently Implemented (v0.2.2)

### iOS Permissions (Info.plist)
- ✅ **NSLocationWhenInUseUsageDescription**: Fully implemented
- ✅ **NSLocationAlwaysAndWhenInUseUsageDescription**: Fully implemented  
- ✅ **NSLocationUsageDescription**: Fully implemented
- ✅ **NSCameraUsageDescription**: Fully implemented (v0.2.2)
- ✅ **NSPhotoLibraryUsageDescription**: Fully implemented (v0.2.2)

### Android Permissions (AndroidManifest.xml)
- ✅ **ACCESS_FINE_LOCATION**: Fully implemented
- ✅ **ACCESS_COARSE_LOCATION**: Fully implemented
- ✅ **INTERNET**: Fully implemented (for geocoding)
- ✅ **ACCESS_BACKGROUND_LOCATION**: Optional, implemented
- ✅ **CAMERA**: Fully implemented (v0.2.2)
- ✅ **READ_EXTERNAL_STORAGE**: Fully implemented with API level constraints (v0.2.2)
- ✅ **READ_MEDIA_IMAGES**: Fully implemented for Android 13+ (v0.2.2)
- ✅ **WRITE_EXTERNAL_STORAGE**: Fully implemented with API level constraints (v0.2.2)

### Location Service Features
- ✅ Runtime permission handling with proper user guidance
- ✅ Fallback to settings when permissions denied
- ✅ Battery-efficient GPS with distance filtering
- ✅ Error handling with localized messages
- ✅ Address resolution via geocoding services

### Photo Service Features (New in v0.2.2)
- ✅ Camera permission handling with security validation
- ✅ Gallery permission handling for all Android versions
- ✅ Secure photo storage in app-specific directories
- ✅ File size and format validation (max 10MB, JPG/PNG/HEIC)
- ✅ User-friendly error dialogs with localized messages
- ✅ Battery-efficient image processing with quality optimization
- ✅ Cross-platform compatibility (iOS & Android tested)

---

**Last Updated**: August 2025  
**Version**: 0.2.2  
**Compliance**: GDPR, iOS App Store Guidelines, Google Play Store Policies