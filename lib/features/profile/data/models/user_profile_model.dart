// User Profile Model - Data layer model
// 
// Hive model for user profile persistence
// Version 0.3.0

import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

/// Hive model for UserProfile
@HiveType(typeId: 10) // Using typeId 10 for user profile
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? nickname;
  
  @HiveField(3)
  final String? photoPath;
  
  @HiveField(4)
  final DateTime? birthday;
  
  @HiveField(5)
  final String? phone;
  
  @HiveField(6)
  final String? email;
  
  @HiveField(7)
  final String? homeLocation;
  
  @HiveField(8)
  final String? work;
  
  @HiveField(9)
  final String? likes;
  
  @HiveField(10)
  final String? dislikes;
  
  @HiveField(11)
  final String? hobbies;
  
  @HiveField(12)
  final String? favoriteMusic;
  
  @HiveField(13)
  final String? favoriteMovies;
  
  @HiveField(14)
  final String? favoriteBooks;
  
  @HiveField(15)
  final String? favoriteFood;
  
  @HiveField(16)
  final String? motto;
  
  @HiveField(17)
  final Map<String, String>? socialMedia;
  
  @HiveField(18)
  final Map<String, dynamic>? customFields;
  
  @HiveField(19)
  final DateTime createdAt;
  
  @HiveField(20)
  final DateTime updatedAt;
  
  UserProfileModel({
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
  
  /// Convert from domain entity
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      nickname: profile.nickname,
      photoPath: profile.photoPath,
      birthday: profile.birthday,
      phone: profile.phone,
      email: profile.email,
      homeLocation: profile.homeLocation,
      work: profile.work,
      likes: profile.likes,
      dislikes: profile.dislikes,
      hobbies: profile.hobbies,
      favoriteMusic: profile.favoriteMusic,
      favoriteMovies: profile.favoriteMovies,
      favoriteBooks: profile.favoriteBooks,
      favoriteFood: profile.favoriteFood,
      motto: profile.motto,
      socialMedia: profile.socialMedia,
      customFields: profile.customFields,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
  
  /// Convert to domain entity
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      nickname: nickname,
      photoPath: photoPath,
      birthday: birthday,
      phone: phone,
      email: email,
      homeLocation: homeLocation,
      work: work,
      likes: likes,
      dislikes: dislikes,
      hobbies: hobbies,
      favoriteMusic: favoriteMusic,
      favoriteMovies: favoriteMovies,
      favoriteBooks: favoriteBooks,
      favoriteFood: favoriteFood,
      motto: motto,
      socialMedia: socialMedia,
      customFields: customFields,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  /// Create from JSON (for import/export)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      photoPath: json['photoPath'] as String?,
      birthday: json['birthday'] != null 
          ? DateTime.parse(json['birthday'] as String)
          : null,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      homeLocation: json['homeLocation'] as String?,
      work: json['work'] as String?,
      likes: json['likes'] as String?,
      dislikes: json['dislikes'] as String?,
      hobbies: json['hobbies'] as String?,
      favoriteMusic: json['favoriteMusic'] as String?,
      favoriteMovies: json['favoriteMovies'] as String?,
      favoriteBooks: json['favoriteBooks'] as String?,
      favoriteFood: json['favoriteFood'] as String?,
      motto: json['motto'] as String?,
      socialMedia: json['socialMedia'] != null
          ? Map<String, String>.from(json['socialMedia'] as Map)
          : null,
      customFields: json['customFields'] != null
          ? Map<String, dynamic>.from(json['customFields'] as Map)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  /// Convert to JSON (for import/export)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'photoPath': photoPath,
      'birthday': birthday?.toIso8601String(),
      'phone': phone,
      'email': email,
      'homeLocation': homeLocation,
      'work': work,
      'likes': likes,
      'dislikes': dislikes,
      'hobbies': hobbies,
      'favoriteMusic': favoriteMusic,
      'favoriteMovies': favoriteMovies,
      'favoriteBooks': favoriteBooks,
      'favoriteFood': favoriteFood,
      'motto': motto,
      'socialMedia': socialMedia,
      'customFields': customFields,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}