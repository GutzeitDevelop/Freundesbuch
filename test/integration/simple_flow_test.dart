// Simplified integration tests for friend management
// 
// Tests basic functionality without complex navigation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:myfriends/main.dart';
import 'package:myfriends/features/friend/data/models/friend_model.dart';
import '../helpers/test_setup.dart';

void main() {
  group('Simple Integration Tests', () {
    setUpAll(() async {
      await setupHiveForTesting();
    });
    
    setUp(() async {
      // Clear database before each test
      if (Hive.isBoxOpen('friends')) {
        await Hive.box<FriendModel>('friends').clear();
      }
    });
    
    tearDown(() async {
      // Clean up after tests
      await clearHiveBox('friends');
    });
    
    testWidgets('App should start and show home page', 
        (WidgetTester tester) async {
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyFriendsApp(),
        ),
      );
      
      // Wait for app to settle with longer timeout
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      
      // Verify we're on home page
      expect(find.text('Willkommen bei MyFriends'), findsOneWidget);
      expect(find.text('Neuen Freund hinzufügen'), findsOneWidget);
      expect(find.text('Meine Freunde'), findsOneWidget);
    });
    
    testWidgets('Should navigate to friends list', 
        (WidgetTester tester) async {
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyFriendsApp(),
        ),
      );
      
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      
      // Navigate to friends list
      await tester.tap(find.text('Meine Freunde'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      
      // Verify we're on friends list page (empty state)
      expect(find.text('Noch keine Freunde hinzugefügt'), findsOneWidget);
    });
    
    testWidgets('Should show pre-populated friend in list', 
        (WidgetTester tester) async {
      // Pre-populate test data
      final box = await Hive.openBox<FriendModel>('friends');
      
      final friend = FriendModel(
        id: 'test-1',
        name: 'Test Friend',
        nickname: 'Testi',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await box.put('test-1', friend);
      
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyFriendsApp(),
        ),
      );
      
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      
      // Navigate to friends list
      await tester.tap(find.text('Meine Freunde'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      
      // Verify friend is visible
      expect(find.text('Test Friend'), findsOneWidget);
      expect(find.text('"Testi"'), findsOneWidget);
    });
  });
}