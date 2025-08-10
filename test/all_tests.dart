// MyFriends App - All Tests Suite
//
// Runs all comprehensive tests for the MyFriends application
// This file serves as the main entry point for running the complete test suite

import 'package:flutter_test/flutter_test.dart';

// Import all comprehensive test files
import 'features/friend/data/repositories/friend_repository_comprehensive_test.dart' as friend_tests;
import 'features/friendbook/data/repositories/friend_book_repository_comprehensive_test.dart' as friendbook_tests;
import 'features/template/data/repositories/template_repository_comprehensive_test.dart' as template_tests;
import 'integration/comprehensive_integration_test.dart' as integration_tests;

void main() {
  group('MyFriends App - Complete Test Suite', () {
    
    group('🧑‍🤝‍🧑 Friend Management Tests', () {
      friend_tests.main();
    });
    
    group('📚 FriendBook Management Tests', () {
      friendbook_tests.main();
    });
    
    group('📝 Template Management Tests', () {
      template_tests.main();
    });
    
    group('🔗 Integration Tests', () {
      integration_tests.main();
    });
  });
}