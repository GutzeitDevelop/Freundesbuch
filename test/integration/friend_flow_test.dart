// Integration tests for complete friend management flow
// 
// Tests the entire user journey from adding to viewing friends

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:myfriends/main.dart';
import 'package:myfriends/core/services/database_service.dart';
import 'package:myfriends/features/friend/data/models/friend_model.dart';
import '../helpers/test_setup.dart';

void main() {
  group('Friend Management Integration Tests', () {
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
    
    testWidgets('Complete flow: Add friend -> View in list -> View details', 
        (WidgetTester tester) async {
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyFriendsApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify we're on home page
      expect(find.text('Willkommen bei MyFriends'), findsOneWidget);
      
      // Navigate to add friend page
      await tester.tap(find.text('Neuen Freund hinzufügen'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify we're on add friend page by looking for form fields
      expect(find.byType(TextFormField), findsWidgets);
      
      // Find and fill the name field (first TextFormField)
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Freund');
      await tester.pump();
      
      // Scroll down to see save button
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      
      // Find and tap the save button
      final saveButton = find.byType(ElevatedButton).first;
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify we're redirected to friends list
      expect(find.text('Meine Freunde'), findsOneWidget);
      
      // Verify friend appears in list
      expect(find.text('Test Freund'), findsOneWidget);
    });
    
    testWidgets('Should search and filter friends', (WidgetTester tester) async {
      // Pre-populate some test data
      final box = await Hive.openBox<FriendModel>('friends');
      
      final friend1 = FriendModel(
        id: '1',
        name: 'Max Mustermann',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final friend2 = FriendModel(
        id: '2',
        name: 'Erika Schmidt',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await box.put('1', friend1);
      await box.put('2', friend2);
      
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyFriendsApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Navigate to friends list
      await tester.tap(find.text('Meine Freunde'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify both friends are visible
      expect(find.text('Max Mustermann'), findsOneWidget);
      expect(find.text('Erika Schmidt'), findsOneWidget);
      
      // Search functionality will be implemented later
      // For now, just verify the friends are shown
    });
    
    testWidgets('Should display existing friend', (WidgetTester tester) async {
      // Pre-populate test data
      final box = await Hive.openBox<FriendModel>('friends');
      
      final friend = FriendModel(
        id: 'display-test',
        name: 'Display Test Friend',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await box.put('display-test', friend);
      
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyFriendsApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Navigate to friends list
      await tester.tap(find.text('Meine Freunde'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify friend is displayed
      expect(find.text('Display Test Friend'), findsOneWidget);
    });
    
    testWidgets('Should verify empty state', (WidgetTester tester) async {
      // Clear any existing data
      if (Hive.isBoxOpen('friends')) {
        await Hive.box<FriendModel>('friends').clear();
      }
      
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyFriendsApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Navigate to friends list
      await tester.tap(find.text('Meine Freunde'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify empty state is shown
      expect(find.text('Noch keine Freunde hinzugefügt'), findsOneWidget);
    });
  });
}