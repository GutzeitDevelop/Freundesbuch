// Simple test to verify test setup works
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_setup.dart';

void main() {
  group('Simple Test Setup Verification', () {
    setUp(() async {
      await setupHiveForTesting();
    });
    
    tearDown(() async {
      await clearHiveBox('friends');
      await clearHiveBox('friendbooks');
      await clearHiveBox('templates');
      await cleanupHive();
    });
    
    test('should create test data without errors', () async {
      // Arrange
      final friend = createTestFriend(name: 'Test Friend');
      final book = createTestFriendBook(name: 'Test Book');
      final template = createTestTemplate(name: 'Test Template');
      
      // Assert
      expect(friend.name, equals('Test Friend'));
      expect(book.name, equals('Test Book'));
      expect(template.name, equals('Test Template'));
    });
  });
}