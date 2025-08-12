// Friend entity - Core business model
// 
// Represents a friend in the domain layer
// Independent of data sources and frameworks

import 'package:equatable/equatable.dart';

/// Friend entity representing a person in the user's life
class Friend extends Equatable {
  /// Unique identifier for the friend
  final String id;
  
  /// Friend's full name
  final String name;
  
  /// Friend's nickname (optional)
  final String? nickname;
  
  /// Path to friend's photo (optional)
  final String? photoPath;
  
  /// Location where first met (optional)
  final String? firstMetLocation;
  
  /// Latitude of first meeting location (optional)
  final double? firstMetLatitude;
  
  /// Longitude of first meeting location (optional)
  final double? firstMetLongitude;
  
  /// Date when first met
  final DateTime firstMetDate;
  
  /// Friend's birthday (optional)
  final DateTime? birthday;
  
  /// Friend's phone number (optional)
  final String? phone;
  
  /// Friend's email address (optional)
  final String? email;
  
  /// Friend's home location (optional)
  final String? homeLocation;
  
  /// Friend's occupation (optional)
  final String? work;
  
  /// Things the friend likes (optional)
  final String? likes;
  
  /// Things the friend dislikes (optional)
  final String? dislikes;
  
  /// Friend's hobbies (optional)
  final String? hobbies;
  
  /// Friend's favorite color (optional)
  final String? favoriteColor;
  
  /// Friend's social media handles (optional)
  final String? socialMedia;
  
  /// Additional notes about the friend (optional)
  final String? notes;
  
  /// Template type used for this friend entry
  final String templateType;
  
  /// Friend book IDs this friend belongs to
  final List<String> friendBookIds;
  
  /// Whether this friend is marked as favorite
  final bool isFavorite;
  
  /// Date when the friend was added to the app
  final DateTime createdAt;
  
  /// Date when the friend was last updated
  final DateTime updatedAt;
  
  /// Custom field values (field name -> value)
  final Map<String, dynamic>? customFieldValues;
  
  const Friend({
    required this.id,
    required this.name,
    this.nickname,
    this.photoPath,
    this.firstMetLocation,
    this.firstMetLatitude,
    this.firstMetLongitude,
    required this.firstMetDate,
    this.birthday,
    this.phone,
    this.email,
    this.homeLocation,
    this.work,
    this.likes,
    this.dislikes,
    this.hobbies,
    this.favoriteColor,
    this.socialMedia,
    this.notes,
    required this.templateType,
    required this.friendBookIds,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.customFieldValues,
  });
  
  /// Creates a copy of this friend with the given fields replaced
  Friend copyWith({
    String? id,
    String? name,
    String? nickname,
    String? photoPath,
    String? firstMetLocation,
    double? firstMetLatitude,
    double? firstMetLongitude,
    DateTime? firstMetDate,
    DateTime? birthday,
    String? phone,
    String? email,
    String? homeLocation,
    String? work,
    String? likes,
    String? dislikes,
    String? hobbies,
    String? favoriteColor,
    String? socialMedia,
    String? notes,
    String? templateType,
    List<String>? friendBookIds,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFieldValues,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      photoPath: photoPath ?? this.photoPath,
      firstMetLocation: firstMetLocation ?? this.firstMetLocation,
      firstMetLatitude: firstMetLatitude ?? this.firstMetLatitude,
      firstMetLongitude: firstMetLongitude ?? this.firstMetLongitude,
      firstMetDate: firstMetDate ?? this.firstMetDate,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      homeLocation: homeLocation ?? this.homeLocation,
      work: work ?? this.work,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      hobbies: hobbies ?? this.hobbies,
      favoriteColor: favoriteColor ?? this.favoriteColor,
      socialMedia: socialMedia ?? this.socialMedia,
      notes: notes ?? this.notes,
      templateType: templateType ?? this.templateType,
      friendBookIds: friendBookIds ?? this.friendBookIds,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customFieldValues: customFieldValues ?? this.customFieldValues,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    nickname,
    photoPath,
    firstMetLocation,
    firstMetLatitude,
    firstMetLongitude,
    firstMetDate,
    birthday,
    phone,
    email,
    homeLocation,
    work,
    likes,
    dislikes,
    hobbies,
    favoriteColor,
    socialMedia,
    notes,
    templateType,
    friendBookIds,
    isFavorite,
    createdAt,
    updatedAt,
    customFieldValues,
  ];
}