// MyFriends App - Working Test Suite
//
// Runs all working tests for the MyFriends application

import 'package:flutter_test/flutter_test.dart';

// Import all basic test files that are working
import 'simple_test.dart' as simple_tests;
import 'friend_repository_basic_test.dart' as friend_basic_tests;
import 'friendbook_repository_basic_test.dart' as friendbook_basic_tests;
import 'template_repository_basic_test.dart' as template_basic_tests;
import 'integration_basic_test.dart' as integration_basic_tests;

void main() {
  group('MyFriends App - Working Test Suite', () {
    
    group('🧪 Setup Tests', () {
      simple_tests.main();
    });
    
    group('🧑‍🤝‍🧑 Friend Management Tests', () {
      friend_basic_tests.main();
    });
    
    group('📚 FriendBook Management Tests', () {
      friendbook_basic_tests.main();
    });
    
    group('📝 Template Management Tests', () {
      template_basic_tests.main();
    });
    
    group('🔗 Integration Tests', () {
      integration_basic_tests.main();
    });
  });
}