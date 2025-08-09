// Friend template entity
// 
// Defines different template types for friend entries

import 'package:equatable/equatable.dart';

/// Enum for predefined template types
enum TemplateType {
  classic,
  modern,
  custom,
}

/// Friend template entity
class FriendTemplate extends Equatable {
  /// Unique identifier for the template
  final String id;
  
  /// Template name
  final String name;
  
  /// Template type
  final TemplateType type;
  
  /// List of field names that are visible in this template
  final List<String> visibleFields;
  
  /// List of field names that are required in this template
  final List<String> requiredFields;
  
  /// Whether this is a user-created custom template
  final bool isCustom;
  
  /// Date when the template was created
  final DateTime createdAt;
  
  const FriendTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.visibleFields,
    required this.requiredFields,
    required this.isCustom,
    required this.createdAt,
  });
  
  /// Classic template with traditional friend book fields
  static FriendTemplate classic() {
    return FriendTemplate(
      id: 'classic',
      name: 'Klassisch',
      type: TemplateType.classic,
      visibleFields: const [
        'name',
        'nickname',
        'photo',
        'homeLocation',
        'birthday',
        'phone',
        'email',
        'hobbies',
        'favoriteColor',
        'likes',
        'dislikes',
        'firstMet',
        'notes',
      ],
      requiredFields: const ['name'],
      isCustom: false,
      createdAt: DateTime.now(),
    );
  }
  
  /// Modern template with social media focus
  static FriendTemplate modern() {
    return FriendTemplate(
      id: 'modern',
      name: 'Modern',
      type: TemplateType.modern,
      visibleFields: const [
        'name',
        'nickname',
        'photo',
        'phone',
        'socialMedia',
        'likes',
        'dislikes',
        'work',
        'firstMet',
        'notes',
      ],
      requiredFields: const ['name'],
      isCustom: false,
      createdAt: DateTime.now(),
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    type,
    visibleFields,
    requiredFields,
    isCustom,
    createdAt,
  ];
}