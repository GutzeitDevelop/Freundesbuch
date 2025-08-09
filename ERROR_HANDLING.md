# Error Handling Guide - MyFriends App

## 🎯 Error Handling Philosophy

All errors in the MyFriends app are handled gracefully with:
- User-friendly error messages in German/English
- Fallback behaviors for critical features
- Detailed logging for debugging
- Recovery suggestions for users

## 🔴 Error Categories

### 1. Storage Errors

#### E001: Database Initialization Failed
**Description**: Hive database failed to initialize  
**Typical Cause**: Insufficient storage space or corrupted database  
**User Message (DE)**: "Datenbankfehler: Bitte App neu starten"  
**User Message (EN)**: "Database error: Please restart the app"  
**Solution**:
```dart
// lib/core/error/storage_errors.dart
try {
  await Hive.initFlutter();
} catch (e) {
  // Clear cache and retry
  await _clearAppCache();
  await Hive.initFlutter();
}
```
**Recovery**: App attempts to clear cache and reinitialize

#### E002: Save Friend Failed
**Description**: Failed to save friend entry to local storage  
**Typical Cause**: Storage full or data corruption  
**User Message (DE)**: "Speichern fehlgeschlagen. Bitte Speicherplatz prüfen"  
**User Message (EN)**: "Save failed. Please check storage space"  
**Solution**:
```dart
// lib/features/friend/data/repositories/friend_repository_impl.dart
Future<Either<Failure, Friend>> saveFriend(Friend friend) async {
  try {
    await _friendBox.put(friend.id, friend);
    return Right(friend);
  } catch (e) {
    _logger.error('Save friend failed', e);
    return Left(StorageFailure('E002'));
  }
}
```

### 2. Permission Errors

#### P001: Camera Permission Denied
**Description**: User denied camera access  
**Typical Cause**: User rejected permission request  
**User Message (DE)**: "Kamerazugriff verweigert. Bitte in Einstellungen aktivieren"  
**User Message (EN)**: "Camera access denied. Please enable in settings"  
**Solution**:
```dart
// lib/features/friend/presentation/pages/add_friend_page.dart
final status = await Permission.camera.request();
if (status.isDenied) {
  _showPermissionDialog(context, 'P001');
}
```
**Recovery**: Show dialog with link to app settings

#### P002: Location Permission Denied
**Description**: User denied location access  
**Typical Cause**: User privacy preference  
**User Message (DE)**: "Standort optional. Manuell eingeben möglich"  
**User Message (EN)**: "Location optional. Manual entry available"  
**Solution**: Provide manual location input as fallback

### 3. Media Errors

#### M001: Image Processing Failed
**Description**: Failed to process captured/selected image  
**Typical Cause**: Corrupt image or unsupported format  
**User Message (DE)**: "Bildverarbeitung fehlgeschlagen. Bitte erneut versuchen"  
**User Message (EN)**: "Image processing failed. Please try again"  
**Solution**:
```dart
// lib/core/utils/image_processor.dart
try {
  final processedImage = await _processImage(file);
  return processedImage;
} catch (e) {
  // Try alternative processing method
  return await _fallbackImageProcessor(file);
}
```

#### M002: Image Too Large
**Description**: Image exceeds size limit  
**Typical Cause**: High resolution photo  
**User Message (DE)**: "Bild wird komprimiert..."  
**User Message (EN)**: "Compressing image..."  
**Solution**: Automatic compression to acceptable size

### 4. Validation Errors

#### V001: Required Field Missing
**Description**: Mandatory field not filled  
**Typical Cause**: User oversight  
**User Message (DE)**: "Bitte alle Pflichtfelder ausfüllen"  
**User Message (EN)**: "Please fill all required fields"  
**Solution**: Highlight missing fields in red

#### V002: Invalid Data Format
**Description**: Data doesn't match expected format  
**Typical Cause**: Wrong input pattern  
**User Message (DE)**: "Ungültiges Format. Beispiel: [example]"  
**User Message (EN)**: "Invalid format. Example: [example]"  
**Solution**: Show format example and validation rules

### 5. Network Errors (Future Features)

#### N001: No Internet Connection
**Description**: Network unavailable for sync  
**Typical Cause**: Device offline  
**User Message (DE)**: "Offline-Modus aktiv. Daten lokal gespeichert"  
**User Message (EN)**: "Offline mode active. Data saved locally"  
**Solution**: Queue actions for later sync

#### N002: Sync Failed
**Description**: Data synchronization failed  
**Typical Cause**: Server issue or timeout  
**User Message (DE)**: "Synchronisierung fehlgeschlagen. Wird später wiederholt"  
**User Message (EN)**: "Sync failed. Will retry later"  
**Solution**: Exponential backoff retry strategy

## 🛠️ Error Handling Implementation

### Global Error Handler
```dart
// lib/core/error/error_handler.dart
class GlobalErrorHandler {
  static void handleError(
    BuildContext context,
    String errorCode,
    {dynamic error, StackTrace? stackTrace}
  ) {
    // Log error
    _logger.error(errorCode, error, stackTrace);
    
    // Get localized message
    final message = _getLocalizedMessage(context, errorCode);
    
    // Show user-friendly dialog
    _showErrorDialog(context, message);
    
    // Attempt recovery if possible
    _attemptRecovery(errorCode);
  }
}
```

### Error Boundary Widget
```dart
// lib/core/widgets/error_boundary.dart
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return ErrorWidget.builder = (details) {
      GlobalErrorHandler.handleError(
        context,
        'UNEXPECTED_ERROR',
        error: details.exception,
        stackTrace: details.stack,
      );
      return FallbackErrorWidget();
    };
  }
}
```

## 📊 Error Monitoring

### Logging Strategy
- **Development**: Verbose logging to console
- **Production**: Error aggregation for analysis
- **Critical Errors**: Immediate notification

### Error Metrics
- Error frequency by type
- User impact assessment
- Recovery success rate
- Performance impact

## 🔄 Recovery Strategies

### Automatic Recovery
1. **Retry with exponential backoff**
2. **Fallback to cached data**
3. **Graceful degradation**
4. **Alternative processing paths**

### User-Guided Recovery
1. **Clear action instructions**
2. **Settings redirection**
3. **Manual retry options**
4. **Support contact information**

## 🌍 Localization

All error messages support:
- 🇩🇪 German (Primary)
- 🇬🇧 English (Fallback)

Messages stored in:
- `lib/l10n/app_de.arb`
- `lib/l10n/app_en.arb`

## 🧪 Testing Error Scenarios

### Unit Tests
```dart
// test/error_handling_test.dart
test('Storage error shows correct message', () async {
  when(mockStorage.save()).thenThrow(StorageException());
  
  final result = await repository.saveFriend(friend);
  
  expect(result.isLeft(), true);
  expect(result.left.code, 'E002');
});
```

### Integration Tests
- Simulate storage full scenarios
- Test permission denial flows
- Verify error recovery mechanisms
- Check offline mode behavior

## 📱 Platform-Specific Errors

### iOS Specific
- **I001**: App Tracking Transparency issues
- **I002**: iCloud sync failures
- **I003**: Face ID/Touch ID errors

### Android Specific
- **A001**: External storage access issues
- **A002**: Background service restrictions
- **A003**: Battery optimization impacts

## 🚨 Critical Error Handling

### Data Loss Prevention
- Always save to temporary storage first
- Implement transaction-like operations
- Regular auto-save for forms
- Recovery from app crashes

### User Data Protection
- Never expose sensitive data in errors
- Sanitize error messages
- Secure error logging
- Privacy-compliant error reporting

---

**Last Updated**: August 2025  
**Version**: 1.0.0  
**Error Code Range**: E001-E999, P001-P999, M001-M999, V001-V999, N001-N999