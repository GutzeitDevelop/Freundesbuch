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
      await tester.pumpAndSettle();
      
      // Verify we're on home page
      expect(find.text('Willkommen bei MyFriends'), findsOneWidget);
      
      // Navigate to add friend page
      await tester.tap(find.text('Neuen Freund hinzufügen'));
      await tester.pumpAndSettle();
      
      // Verify we're on add friend page
      expect(find.text('Name'), findsOneWidget);
      
      // Fill in friend details
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Test Freund',
      );
      
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Spitzname'),
        'Testi',
      );
      
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Telefon'),
        '+49 123 456789',
      );
      
      // Scroll down to see save button
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      
      // Save the friend
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();
      
      // Verify we're redirected to friends list
      expect(find.text('Meine Freunde'), findsOneWidget);
      
      // Verify friend appears in list
      expect(find.text('Test Freund'), findsOneWidget);
      expect(find.text('"Testi"'), findsOneWidget);
      
      // Tap on friend to view details
      await tester.tap(find.text('Test Freund'));
      await tester.pumpAndSettle();
      
      // Verify we're on detail page
      expect(find.text('Test Freund'), findsWidgets); // Name appears multiple times
      expect(find.text('+49 123 456789'), findsOneWidget);
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
      await tester.pumpAndSettle();
      
      // Navigate to friends list
      await tester.tap(find.text('Meine Freunde'));
      await tester.pumpAndSettle();
      
      // Verify both friends are visible
      expect(find.text('Max Mustermann'), findsOneWidget);
      expect(find.text('Erika Schmidt'), findsOneWidget);
      
      // Search for Max
      await tester.enterText(find.byType(TextField), 'Max');
      await tester.pumpAndSettle();
      
      // Verify only Max is visible
      expect(find.text('Max Mustermann'), findsOneWidget);
      expect(find.text('Erika Schmidt'), findsNothing);
      
      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      
      // Toggle favorites filter
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();
      
      // Verify only favorite friend is visible
      expect(find.text('Erika Schmidt'), findsOneWidget);
      expect(find.text('Max Mustermann'), findsNothing);
    });
    
    testWidgets('Should edit existing friend', (WidgetTester tester) async {
      // Pre-populate test data
      final box = await Hive.openBox<FriendModel>('friends');
      
      final friend = FriendModel(
        id: 'edit-test',
        name: 'Original Name',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await box.put('edit-test', friend);
      
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyFriendsApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      // Navigate to friends list
      await tester.tap(find.text('Meine Freunde'));
      await tester.pumpAndSettle();
      
      // Tap on friend to view details
      await tester.tap(find.text('Original Name'));
      await tester.pumpAndSettle();
      
      // Open menu and select edit
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Bearbeiten'));
      await tester.pumpAndSettle();
      
      // Clear and update name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Updated Name',
      );
      
      // Save changes
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();
      
      // Verify name was updated in list
      expect(find.text('Updated Name'), findsOneWidget);
      expect(find.text('Original Name'), findsNothing);
    });
    
    testWidgets('Should delete friend with confirmation', (WidgetTester tester) async {
      // Pre-populate test data
      final box = await Hive.openBox<FriendModel>('friends');
      
      final friend = FriendModel(
        id: 'delete-test',
        name: 'To Delete',
        firstMetDate: DateTime.now(),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await box.put('delete-test', friend);
      
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyFriendsApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      // Navigate to friends list
      await tester.tap(find.text('Meine Freunde'));
      await tester.pumpAndSettle();
      
      // Verify friend exists
      expect(find.text('To Delete'), findsOneWidget);
      
      // Tap on friend to view details
      await tester.tap(find.text('To Delete'));
      await tester.pumpAndSettle();
      
      // Open menu and select delete
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      
      // Verify confirmation dialog appears
      expect(find.text('Löschen bestätigen'), findsOneWidget);
      
      // Cancel deletion first
      await tester.tap(find.text('Nein'));
      await tester.pumpAndSettle();
      
      // Friend should still exist
      expect(find.text('To Delete'), findsOneWidget);
      
      // Try delete again and confirm
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Ja'));
      await tester.pumpAndSettle();
      
      // Verify we're back in list and friend is gone
      expect(find.text('To Delete'), findsNothing);
      expect(find.text('Noch keine Freunde hinzugefügt'), findsOneWidget);
    });
  });
}