// Friend model for data layer
// 
// Handles serialization and Hive storage

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/friend.dart';

part 'friend_model.g.dart';

/// Friend model for data persistence
@HiveType(typeId: 0)
@JsonSerializable()
class FriendModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? nickname;
  
  @HiveField(3)
  final String? photoPath;
  
  @HiveField(4)
  final String? firstMetLocation;
  
  @HiveField(5)
  final double? firstMetLatitude;
  
  @HiveField(6)
  final double? firstMetLongitude;
  
  @HiveField(7)
  final DateTime firstMetDate;
  
  @HiveField(8)
  final DateTime? birthday;
  
  @HiveField(9)
  final String? phone;
  
  @HiveField(10)
  final String? email;
  
  @HiveField(11)
  final String? homeLocation;
  
  @HiveField(12)
  final String? work;
  
  @HiveField(13)
  final String? likes;
  
  @HiveField(14)
  final String? dislikes;
  
  @HiveField(15)
  final String? hobbies;
  
  @HiveField(16)
  final String? favoriteColor;
  
  @HiveField(17)
  final String? socialMedia;
  
  @HiveField(18)
  final String? notes;
  
  @HiveField(19)
  final String templateType;
  
  @HiveField(20)
  final List<String> friendBookIds;
  
  @HiveField(21)
  final bool isFavorite;
  
  @HiveField(22)
  final DateTime createdAt;
  
  @HiveField(23)
  final DateTime updatedAt;
  
  @HiveField(24)
  final Map<String, dynamic>? customFieldValues;
  
  @HiveField(25)
  final double? currentLatitude;
  
  @HiveField(26)
  final double? currentLongitude;
  
  @HiveField(27)
  final bool isLocationSharingEnabled;
  
  @HiveField(28)
  final String? statusEmoji;
  
  @HiveField(29)
  final DateTime? lastLocationUpdate;
  
  FriendModel({
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
    this.currentLatitude,
    this.currentLongitude,
    this.isLocationSharingEnabled = false,
    this.statusEmoji,
    this.lastLocationUpdate,
  });
  
  /// Creates a FriendModel from a Friend entity
  factory FriendModel.fromEntity(Friend friend) {
    return FriendModel(
      id: friend.id,
      name: friend.name,
      nickname: friend.nickname,
      photoPath: friend.photoPath,
      firstMetLocation: friend.firstMetLocation,
      firstMetLatitude: friend.firstMetLatitude,
      firstMetLongitude: friend.firstMetLongitude,
      firstMetDate: friend.firstMetDate,
      birthday: friend.birthday,
      phone: friend.phone,
      email: friend.email,
      homeLocation: friend.homeLocation,
      work: friend.work,
      likes: friend.likes,
      dislikes: friend.dislikes,
      hobbies: friend.hobbies,
      favoriteColor: friend.favoriteColor,
      socialMedia: friend.socialMedia,
      notes: friend.notes,
      templateType: friend.templateType,
      friendBookIds: friend.friendBookIds,
      isFavorite: friend.isFavorite,
      createdAt: friend.createdAt,
      updatedAt: friend.updatedAt,
      customFieldValues: friend.customFieldValues,
      currentLatitude: friend.currentLatitude,
      currentLongitude: friend.currentLongitude,
      isLocationSharingEnabled: friend.isLocationSharingEnabled,
      statusEmoji: friend.statusEmoji,
      lastLocationUpdate: friend.lastLocationUpdate,
    );
  }
  
  /// Converts this FriendModel to a Friend entity
  Friend toEntity() {
    return Friend(
      id: id,
      name: name,
      nickname: nickname,
      photoPath: photoPath,
      firstMetLocation: firstMetLocation,
      firstMetLatitude: firstMetLatitude,
      firstMetLongitude: firstMetLongitude,
      firstMetDate: firstMetDate,
      birthday: birthday,
      phone: phone,
      email: email,
      homeLocation: homeLocation,
      work: work,
      likes: likes,
      dislikes: dislikes,
      hobbies: hobbies,
      favoriteColor: favoriteColor,
      socialMedia: socialMedia,
      notes: notes,
      templateType: templateType,
      friendBookIds: friendBookIds,
      isFavorite: isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
      customFieldValues: customFieldValues,
      currentLatitude: currentLatitude,
      currentLongitude: currentLongitude,
      isLocationSharingEnabled: isLocationSharingEnabled,
      statusEmoji: statusEmoji,
      lastLocationUpdate: lastLocationUpdate,
    );
  }
  
  /// Creates a copy with updated fields
  FriendModel copyWith({
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
    double? currentLatitude,
    double? currentLongitude,
    bool? isLocationSharingEnabled,
    String? statusEmoji,
    DateTime? lastLocationUpdate,
  }) {
    return FriendModel(
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
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isLocationSharingEnabled: isLocationSharingEnabled ?? this.isLocationSharingEnabled,
      statusEmoji: statusEmoji ?? this.statusEmoji,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }
  
  /// Creates a FriendModel from JSON
  factory FriendModel.fromJson(Map<String, dynamic> json) => 
    _$FriendModelFromJson(json);
  
  /// Converts this FriendModel to JSON
  Map<String, dynamic> toJson() => _$FriendModelToJson(this);
}