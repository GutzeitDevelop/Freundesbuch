// User Profile entity - Core business model
// 
// Represents the user's own profile in the app
// Can be shared with new friends for quick data exchange
// Version 0.3.0

import 'package:equatable/equatable.dart';

/// User's own profile for sharing with friends
class UserProfile extends Equatable {
  /// Unique identifier for the profile
  final String id;
  
  /// User's full name
  final String name;
  
  /// User's nickname (optional)
  final String? nickname;
  
  /// Path to user's profile photo (optional)
  final String? photoPath;
  
  /// User's birthday (optional)
  final DateTime? birthday;
  
  /// User's phone number (optional)
  final String? phone;
  
  /// User's email address (optional)
  final String? email;
  
  /// User's home location (optional)
  final String? homeLocation;
  
  /// User's occupation (optional)
  final String? work;
  
  /// Things the user likes (optional)
  final String? likes;
  
  /// Things the user dislikes (optional)
  final String? dislikes;
  
  /// User's hobbies (optional)
  final String? hobbies;
  
  /// User's favorite music (optional)
  final String? favoriteMusic;
  
  /// User's favorite movies (optional)
  final String? favoriteMovies;
  
  /// User's favorite books (optional)
  final String? favoriteBooks;
  
  /// User's favorite food (optional)
  final String? favoriteFood;
  
  /// User's motto or life philosophy (optional)
  final String? motto;
  
  /// Social media handles (optional)
  final Map<String, String>? socialMedia;
  
  /// Custom fields added by user
  final Map<String, dynamic>? customFields;
  
  /// Profile creation date
  final DateTime createdAt;
  
  /// Profile last update date
  final DateTime updatedAt;
  
  /// Whether profile is complete
  bool get isComplete => name.isNotEmpty && photoPath != null;
  
  /// Profile completion percentage
  double get completionPercentage {
    int totalFields = 19; // Total optional fields
    int filledFields = 0;
    
    if (name.isNotEmpty) filledFields++;
    if (nickname != null && nickname!.isNotEmpty) filledFields++;
    if (photoPath != null && photoPath!.isNotEmpty) filledFields++;
    if (birthday != null) filledFields++;
    if (phone != null && phone!.isNotEmpty) filledFields++;
    if (email != null && email!.isNotEmpty) filledFields++;
    if (homeLocation != null && homeLocation!.isNotEmpty) filledFields++;
    if (work != null && work!.isNotEmpty) filledFields++;
    if (likes != null && likes!.isNotEmpty) filledFields++;
    if (dislikes != null && dislikes!.isNotEmpty) filledFields++;
    if (hobbies != null && hobbies!.isNotEmpty) filledFields++;
    if (favoriteMusic != null && favoriteMusic!.isNotEmpty) filledFields++;
    if (favoriteMovies != null && favoriteMovies!.isNotEmpty) filledFields++;
    if (favoriteBooks != null && favoriteBooks!.isNotEmpty) filledFields++;
    if (favoriteFood != null && favoriteFood!.isNotEmpty) filledFields++;
    if (motto != null && motto!.isNotEmpty) filledFields++;
    if (socialMedia != null && socialMedia!.isNotEmpty) filledFields++;
    if (customFields != null && customFields!.isNotEmpty) filledFields++;
    
    return (filledFields / totalFields) * 100;
  }
  
  const UserProfile({
    required this.id,
    required this.name,
    this.nickname,
    this.photoPath,
    this.birthday,
    this.phone,
    this.email,
    this.homeLocation,
    this.work,
    this.likes,
    this.dislikes,
    this.hobbies,
    this.favoriteMusic,
    this.favoriteMovies,
    this.favoriteBooks,
    this.favoriteFood,
    this.motto,
    this.socialMedia,
    this.customFields,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? nickname,
    String? photoPath,
    DateTime? birthday,
    String? phone,
    String? email,
    String? homeLocation,
    String? work,
    String? likes,
    String? dislikes,
    String? hobbies,
    String? favoriteMusic,
    String? favoriteMovies,
    String? favoriteBooks,
    String? favoriteFood,
    String? motto,
    Map<String, String>? socialMedia,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      photoPath: photoPath ?? this.photoPath,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      homeLocation: homeLocation ?? this.homeLocation,
      work: work ?? this.work,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      hobbies: hobbies ?? this.hobbies,
      favoriteMusic: favoriteMusic ?? this.favoriteMusic,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
      favoriteFood: favoriteFood ?? this.favoriteFood,
      motto: motto ?? this.motto,
      socialMedia: socialMedia ?? this.socialMedia,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Convert to shareable format (for QR codes, etc.)
  Map<String, dynamic> toShareableMap() {
    return {
      'name': name,
      if (nickname != null) 'nickname': nickname,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (homeLocation != null) 'homeLocation': homeLocation,
      if (work != null) 'work': work,
      if (likes != null) 'likes': likes,
      if (dislikes != null) 'dislikes': dislikes,
      if (hobbies != null) 'hobbies': hobbies,
      if (socialMedia != null) 'socialMedia': socialMedia,
    };
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    nickname,
    photoPath,
    birthday,
    phone,
    email,
    homeLocation,
    work,
    likes,
    dislikes,
    hobbies,
    favoriteMusic,
    favoriteMovies,
    favoriteBooks,
    favoriteFood,
    motto,
    socialMedia,
    customFields,
    createdAt,
    updatedAt,
  ];
}