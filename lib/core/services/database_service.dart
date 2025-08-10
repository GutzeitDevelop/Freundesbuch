// Database service for Hive initialization
// 
// Manages database setup and registration

import 'package:hive_flutter/hive_flutter.dart';
import '../../features/friend/data/models/friend_model.dart';
import '../../features/friendbook/data/models/friend_book_model.dart';

/// Service for managing database initialization
class DatabaseService {
  static bool _initialized = false;
  
  /// Initializes the database
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register adapters
    _registerAdapters();
    
    // Open boxes
    await _openBoxes();
    
    _initialized = true;
  }
  
  /// Registers all Hive type adapters
  static void _registerAdapters() {
    // Register FriendModel adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FriendModelAdapter());
    }
    
    // Register FriendBookModel adapter if not already registered
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FriendBookModelAdapter());
    }
  }
  
  /// Opens all required Hive boxes
  static Future<void> _openBoxes() async {
    // Open friends box
    await Hive.openBox<FriendModel>('friends');
    
    // Open friendbooks box
    await Hive.openBox<FriendBookModel>('friendbooks');
    
    // Open other boxes as needed
    // await Hive.openBox<TemplateModel>('templates');
  }
  
  /// Clears all data (use with caution)
  static Future<void> clearAllData() async {
    final friendsBox = Hive.box<FriendModel>('friends');
    await friendsBox.clear();
    
    // Clear other boxes as needed
  }
  
  /// Closes all boxes
  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}