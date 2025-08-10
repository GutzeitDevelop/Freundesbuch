import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/features/friend/presentation/widgets/friend_list_tile.dart';
import 'package:myfriends/features/friend/domain/entities/friend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myfriends/l10n/app_localizations.dart';

void main() {
  group('Photo Display Widget Tests', () {
    // Helper function to create a test widget
    Widget createTestWidget(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('de'),
            Locale('en'),
          ],
          locale: const Locale('de'),
          home: Scaffold(body: child),
        ),
      );
    }

    group('FriendListTile Photo Display', () {
      testWidgets('should display FileImage when photoPath is provided', (WidgetTester tester) async {
        // Arrange
        final friend = Friend(
          id: 'test-id',
          name: 'Test Friend',
          nickname: 'Testy',
          photoPath: '/path/to/photo.jpg',
          firstMetDate: DateTime.now(),
          firstMetLocation: 'Test Location',
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            FriendListTile(
              friend: friend,
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final circleAvatarFinder = find.byType(CircleAvatar);
        expect(circleAvatarFinder, findsOneWidget);
        
        final CircleAvatar avatar = tester.widget(circleAvatarFinder);
        expect(avatar.backgroundImage, isNotNull);
        expect(avatar.backgroundImage, isA<FileImage>());
        
        // Verify that the FileImage uses the correct path
        final fileImage = avatar.backgroundImage as FileImage;
        expect(fileImage.file.path, equals('/path/to/photo.jpg'));
      });

      testWidgets('should display initial letter when no photoPath', (WidgetTester tester) async {
        // Arrange
        final friend = Friend(
          id: 'test-id',
          name: 'Max Mustermann',
          photoPath: null, // No photo
          firstMetDate: DateTime.now(),
          firstMetLocation: 'Test Location',
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            FriendListTile(
              friend: friend,
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final circleAvatarFinder = find.byType(CircleAvatar);
        expect(circleAvatarFinder, findsOneWidget);
        
        final CircleAvatar avatar = tester.widget(circleAvatarFinder);
        expect(avatar.backgroundImage, isNull);
        expect(avatar.child, isNotNull);
        
        // Check that it displays the first letter
        final textFinder = find.text('M');
        expect(textFinder, findsOneWidget);
      });

      testWidgets('should handle empty name gracefully', (WidgetTester tester) async {
        // Arrange
        final friend = Friend(
          id: 'test-id',
          name: '', // Empty name
          photoPath: null,
          firstMetDate: DateTime.now(),
          firstMetLocation: 'Test Location',
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            FriendListTile(
              friend: friend,
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final circleAvatarFinder = find.byType(CircleAvatar);
        expect(circleAvatarFinder, findsOneWidget);
        
        // Should display '?' for empty name
        final textFinder = find.text('?');
        expect(textFinder, findsOneWidget);
      });
    });

    group('Photo Path Validation', () {
      testWidgets('should use FileImage for absolute paths', (WidgetTester tester) async {
        // Arrange
        final absolutePath = '/data/user/0/com.myfriendsapp.myfriends/app_flutter/photos/photo.jpg';
        final friend = Friend(
          id: 'test-id',
          name: 'Test',
          photoPath: absolutePath,
          firstMetDate: DateTime.now(),
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            FriendListTile(
              friend: friend,
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final CircleAvatar avatar = tester.widget(find.byType(CircleAvatar));
        expect(avatar.backgroundImage, isA<FileImage>());
        
        final fileImage = avatar.backgroundImage as FileImage;
        expect(fileImage.file.path, equals(absolutePath));
      });

      testWidgets('should NOT use AssetImage for file paths', (WidgetTester tester) async {
        // This test ensures we never use AssetImage for local file paths
        // Arrange
        final localPath = '/path/to/local/photo.jpg';
        final friend = Friend(
          id: 'test-id',
          name: 'Test',
          photoPath: localPath,
          firstMetDate: DateTime.now(),
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            FriendListTile(
              friend: friend,
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final CircleAvatar avatar = tester.widget(find.byType(CircleAvatar));
        expect(avatar.backgroundImage, isNotNull);
        expect(avatar.backgroundImage, isNot(isA<AssetImage>()));
        expect(avatar.backgroundImage, isA<FileImage>());
      });
    });

    group('UI Integration', () {
      testWidgets('should display all friend information with photo', (WidgetTester tester) async {
        // Arrange
        final friend = Friend(
          id: 'test-id',
          name: 'John Doe',
          nickname: 'Johnny',
          photoPath: '/path/to/photo.jpg',
          firstMetDate: DateTime(2024, 1, 15),
          firstMetLocation: 'Berlin, Germany',
          isFavorite: true,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            FriendListTile(
              friend: friend,
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('"Johnny"'), findsOneWidget);
        expect(find.text('Berlin, Germany'), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        
        // Verify photo is displayed with FileImage
        final CircleAvatar avatar = tester.widget(find.byType(CircleAvatar));
        expect(avatar.backgroundImage, isA<FileImage>());
      });

      testWidgets('should handle tap events correctly', (WidgetTester tester) async {
        // Arrange
        bool wasTapped = false;
        final friend = Friend(
          id: 'test-id',
          name: 'Test Friend',
          photoPath: '/path/to/photo.jpg',
          firstMetDate: DateTime.now(),
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            FriendListTile(
              friend: friend,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        // Assert
        expect(wasTapped, isTrue);
      });

      testWidgets('should handle favorite toggle correctly', (WidgetTester tester) async {
        // Arrange
        bool favoriteToggled = false;
        final friend = Friend(
          id: 'test-id',
          name: 'Test Friend',
          photoPath: null,
          firstMetDate: DateTime.now(),
          isFavorite: false,
          templateType: 'classic',
          friendBookIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          createTestWidget(
            FriendListTile(
              friend: friend,
              onTap: () {},
              onFavoriteToggle: () {
                favoriteToggled = true;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        // Assert
        expect(favoriteToggled, isTrue);
      });
    });
  });
}