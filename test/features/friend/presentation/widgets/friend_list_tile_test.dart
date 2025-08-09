// Widget tests for FriendListTile
// 
// Tests the friend list tile widget display and interactions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myfriends/features/friend/presentation/widgets/friend_list_tile.dart';
import 'package:myfriends/features/friend/domain/entities/friend.dart';
import 'package:myfriends/l10n/app_localizations.dart';

void main() {
  group('FriendListTile Widget Tests', () {
    // Helper function to wrap widget with necessary providers
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('de'),
          Locale('en'),
        ],
        home: Scaffold(body: child),
      );
    }
    
    testWidgets('should display friend name', (WidgetTester tester) async {
      // Arrange
      final friend = Friend(
        id: '123',
        name: 'Max Mustermann',
        firstMetDate: DateTime(2024, 1, 15),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await tester.pumpWidget(
        createTestWidget(
          FriendListTile(friend: friend),
        ),
      );
      
      // Assert
      expect(find.text('Max Mustermann'), findsOneWidget);
    });
    
    testWidgets('should display nickname when available', (WidgetTester tester) async {
      // Arrange
      final friend = Friend(
        id: '456',
        name: 'Erika Musterfrau',
        nickname: 'Eri',
        firstMetDate: DateTime(2024, 1, 15),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await tester.pumpWidget(
        createTestWidget(
          FriendListTile(friend: friend),
        ),
      );
      
      // Assert
      expect(find.text('"Eri"'), findsOneWidget);
    });
    
    testWidgets('should display location when available', (WidgetTester tester) async {
      // Arrange
      final friend = Friend(
        id: '789',
        name: 'Hans Schmidt',
        firstMetLocation: 'Berlin, Deutschland',
        firstMetDate: DateTime(2024, 1, 15),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await tester.pumpWidget(
        createTestWidget(
          FriendListTile(friend: friend),
        ),
      );
      
      // Assert
      expect(find.text('Berlin, Deutschland'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });
    
    testWidgets('should show favorite icon when friend is favorite', (WidgetTester tester) async {
      // Arrange
      final friend = Friend(
        id: '111',
        name: 'Favorite Friend',
        firstMetDate: DateTime(2024, 1, 15),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await tester.pumpWidget(
        createTestWidget(
          FriendListTile(friend: friend),
        ),
      );
      
      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
    
    testWidgets('should trigger onTap callback when tapped', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      final friend = Friend(
        id: '222',
        name: 'Tappable Friend',
        firstMetDate: DateTime(2024, 1, 15),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await tester.pumpWidget(
        createTestWidget(
          FriendListTile(
            friend: friend,
            onTap: () => wasTapped = true,
          ),
        ),
      );
      
      await tester.tap(find.byType(ListTile));
      await tester.pump();
      
      // Assert
      expect(wasTapped, true);
    });
    
    testWidgets('should trigger favorite toggle when favorite icon tapped', (WidgetTester tester) async {
      // Arrange
      bool favoriteToggled = false;
      final friend = Friend(
        id: '333',
        name: 'Toggle Friend',
        firstMetDate: DateTime(2024, 1, 15),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await tester.pumpWidget(
        createTestWidget(
          FriendListTile(
            friend: friend,
            onFavoriteToggle: () => favoriteToggled = true,
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      
      // Assert
      expect(favoriteToggled, true);
    });
    
    testWidgets('should display first letter when no photo', (WidgetTester tester) async {
      // Arrange
      final friend = Friend(
        id: '444',
        name: 'Anna',
        firstMetDate: DateTime(2024, 1, 15),
        templateType: 'classic',
        friendBookIds: [],
        isFavorite: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await tester.pumpWidget(
        createTestWidget(
          FriendListTile(friend: friend),
        ),
      );
      
      // Assert
      expect(find.text('A'), findsOneWidget);
    });
  });
}