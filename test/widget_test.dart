// Basic widget test for MyFriends app
//
// Tests the main app initialization and basic navigation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfriends/main.dart';
import 'helpers/test_setup.dart';

void main() {
  setUpAll(() async {
    await setupHiveForTesting();
  });
  
  testWidgets('App smoke test - Home page loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyFriendsApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that home page loads with welcome text
    expect(find.text('Willkommen bei MyFriends'), findsOneWidget);
    expect(find.text('Neuen Freund hinzufügen'), findsOneWidget);
    expect(find.text('Meine Freunde'), findsOneWidget);
    
    // Verify main icon is present
    expect(find.byIcon(Icons.people_outline), findsOneWidget);
  });
}