// FriendBook Hive model for local persistence
// 
// Implements the FriendBook entity with Hive adapters for storage

import 'package:hive/hive.dart';
import '../../domain/entities/friend_book.dart';

part 'friend_book_model.g.dart';

/// Hive model for FriendBook entity
/// 
/// This model is used for local storage with Hive database
/// TypeId 1 is used (0 is already used by FriendModel)
@HiveType(typeId: 1)
class FriendBookModel extends HiveObject {
  /// Unique identifier for the friend book
  @HiveField(0)
  final String id;
  
  /// Name of the friend book
  @HiveField(1)
  final String name;
  
  /// Description of the friend book (optional)
  @HiveField(2)
  final String? description;
  
  /// Color theme for the friend book (as hex string)
  @HiveField(3)
  final String colorHex;
  
  /// Icon name for the friend book
  @HiveField(4)
  final String iconName;
  
  /// List of friend IDs in this book
  @HiveField(5)
  final List<String> friendIds;
  
  /// Date when the friend book was created
  @HiveField(6)
  final DateTime createdAt;
  
  /// Date when the friend book was last updated
  @HiveField(7)
  final DateTime updatedAt;
  
  FriendBookModel({
    required this.id,
    required this.name,
    this.description,
    required this.colorHex,
    required this.iconName,
    required this.friendIds,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Converts domain entity to Hive model
  factory FriendBookModel.fromEntity(FriendBook friendBook) {
    return FriendBookModel(
      id: friendBook.id,
      name: friendBook.name,
      description: friendBook.description,
      colorHex: friendBook.colorHex,
      iconName: friendBook.iconName,
      friendIds: List<String>.from(friendBook.friendIds),
      createdAt: friendBook.createdAt,
      updatedAt: friendBook.updatedAt,
    );
  }
  
  /// Converts Hive model to domain entity
  FriendBook toEntity() {
    return FriendBook(
      id: id,
      name: name,
      description: description,
      colorHex: colorHex,
      iconName: iconName,
      friendIds: List<String>.from(friendIds),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  /// Creates a copy with updated fields
  FriendBookModel copyWith({
    String? id,
    String? name,
    String? description,
    String? colorHex,
    String? iconName,
    List<String>? friendIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FriendBookModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      friendIds: friendIds ?? this.friendIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}