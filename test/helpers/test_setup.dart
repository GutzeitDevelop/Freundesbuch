// Test setup utilities for MyFriends app
//
// Provides common test setup and mock configurations

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:myfriends/features/friend/data/models/friend_model.dart';
import 'package:myfriends/features/friendbook/data/models/friend_book_model.dart';
import 'package:myfriends/features/template/data/models/template_model.dart';
import 'package:myfriends/features/friend/domain/entities/friend.dart';
import 'package:myfriends/features/friendbook/domain/entities/friend_book.dart';
import 'package:myfriends/features/friend/domain/entities/friend_template.dart';
import 'package:uuid/uuid.dart';

/// Global test directory reference
Directory? _testDirectory;

/// Setup Hive for testing
/// 
/// Initializes Hive with temporary directory for tests
Future<void> setupHiveForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Close any existing boxes and delete them
  await cleanupHive();
  
  // Create temporary directory for this test
  _testDirectory = await Directory.systemTemp.createTemp('hive_test_');
  
  // Initialize Hive with temporary directory
  Hive.init(_testDirectory!.path);
  
  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(FriendModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FriendBookModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TemplateModelAdapter());
  }
}

/// Clean up Hive after tests
Future<void> cleanupHive() async {
  try {
    // Clear known test boxes
    final boxNames = ['friends', 'friendbooks', 'templates'];
    for (final boxName in boxNames) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          await box.clear();
          await box.close();
        }
      } catch (e) {
        // Ignore individual box errors
      }
    }
    
    // Close all open boxes
    await Hive.close();
    
    // Delete temporary test directory
    if (_testDirectory != null && await _testDirectory!.exists()) {
      try {
        await _testDirectory!.delete(recursive: true);
        _testDirectory = null;
      } catch (e) {
        // Ignore directory deletion errors
      }
    }
  } catch (e) {
    // Ignore errors during cleanup
  }
}

/// Clear all data from a Hive box
Future<void> clearHiveBox(String boxName) async {
  try {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      await box.clear();
    }
  } catch (e) {
    // Ignore errors during cleanup
  }
}

/// Test data generators

/// Creates a test friend with optional parameters
Friend createTestFriend({
  String? id,
  String name = 'Test Friend',
  String? nickname,
  List<String>? friendBookIds,
  bool isFavorite = false,
  String templateType = 'classic',
  DateTime? createdAt,
}) {
  final now = DateTime.now();
  return Friend(
    id: id ?? const Uuid().v4(),
    name: name,
    nickname: nickname,
    firstMetDate: createdAt ?? now,
    templateType: templateType,
    friendBookIds: friendBookIds ?? [],
    isFavorite: isFavorite,
    createdAt: createdAt ?? now,
    updatedAt: now,
  );
}

/// Creates a test friend book with optional parameters
FriendBook createTestFriendBook({
  String? id,
  String name = 'Test FriendBook',
  String? description,
  String colorHex = '#2196F3',
  String iconName = 'group',
  List<String>? friendIds,
  DateTime? createdAt,
}) {
  final now = DateTime.now();
  return FriendBook(
    id: id ?? const Uuid().v4(),
    name: name,
    description: description,
    colorHex: colorHex,
    iconName: iconName,
    friendIds: friendIds ?? [],
    createdAt: createdAt ?? now,
    updatedAt: now,
  );
}

/// Creates a test custom template with optional parameters
FriendTemplate createTestTemplate({
  String? id,
  String name = 'Test Template',
  List<String>? visibleFields,
  List<String>? requiredFields,
  bool isCustom = true,
  DateTime? createdAt,
}) {
  return FriendTemplate(
    id: id ?? const Uuid().v4(),
    name: name,
    type: TemplateType.custom,
    visibleFields: visibleFields ?? ['name', 'nickname', 'phone'],
    requiredFields: requiredFields ?? ['name'],
    isCustom: isCustom,
    createdAt: createdAt ?? DateTime.now(),
  );
}

/// Creates multiple test friends
List<Friend> createTestFriends(int count) {
  return List.generate(count, (index) => createTestFriend(
    name: 'Test Friend $index',
    nickname: 'Friend$index',
  ));
}

/// Creates multiple test friend books
List<FriendBook> createTestFriendBooks(int count) {
  return List.generate(count, (index) => createTestFriendBook(
    name: 'Test Book $index',
    description: 'Description for book $index',
  ));
}