// Friend book entity
// 
// Represents a group or collection of friends

import 'package:equatable/equatable.dart';

/// Friend book entity for organizing friends into groups
class FriendBook extends Equatable {
  /// Unique identifier for the friend book
  final String id;
  
  /// Name of the friend book
  final String name;
  
  /// Description of the friend book (optional)
  final String? description;
  
  /// Color theme for the friend book (as hex string)
  final String colorHex;
  
  /// Icon name for the friend book
  final String iconName;
  
  /// List of friend IDs in this book
  final List<String> friendIds;
  
  /// Date when the friend book was created
  final DateTime createdAt;
  
  /// Date when the friend book was last updated
  final DateTime updatedAt;
  
  const FriendBook({
    required this.id,
    required this.name,
    this.description,
    required this.colorHex,
    required this.iconName,
    required this.friendIds,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Creates a copy of this friend book with the given fields replaced
  FriendBook copyWith({
    String? id,
    String? name,
    String? description,
    String? colorHex,
    String? iconName,
    List<String>? friendIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FriendBook(
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
  
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    colorHex,
    iconName,
    friendIds,
    createdAt,
    updatedAt,
  ];
}