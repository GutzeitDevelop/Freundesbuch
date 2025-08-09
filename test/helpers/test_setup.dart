// Test setup utilities for MyFriends app
//
// Provides common test setup and mock configurations

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:myfriends/features/friend/data/models/friend_model.dart';

/// Setup Hive for testing
/// 
/// Initializes Hive with in-memory storage for tests
Future<void> setupHiveForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive with in-memory storage
  final testPath = '.';
  Hive.init(testPath);
  
  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(FriendModelAdapter());
  }
}

/// Clean up Hive after tests
Future<void> cleanupHive() async {
  // Close all open boxes
  await Hive.close();
}

/// Clear all data from a Hive box
Future<void> clearHiveBox(String boxName) async {
  if (Hive.isBoxOpen(boxName)) {
    final box = Hive.box(boxName);
    await box.clear();
  }
}