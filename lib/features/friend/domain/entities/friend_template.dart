// Friend template entity
// 
// Defines different template types for friend entries
// with support for custom fields

import 'package:equatable/equatable.dart';

/// Enum for predefined template types
enum TemplateType {
  classic,
  modern,
  custom,
}

/// Enum for custom field types
enum CustomFieldType {
  text,
  number,
  date,
  boolean,
  select,
  multiSelect,
  url,
  email,
}

/// Custom field definition
class CustomField extends Equatable {
  /// Unique identifier for the field
  final String id;
  
  /// Field name (internal key)
  final String name;
  
  /// Display label
  final String label;
  
  /// Field type
  final CustomFieldType type;
  
  /// Whether the field is required
  final bool isRequired;
  
  /// Options for select/multiSelect fields
  final List<String>? options;
  
  /// Placeholder text
  final String? placeholder;
  
  /// Validation pattern (regex)
  final String? validationPattern;
  
  /// Default value
  final dynamic defaultValue;
  
  const CustomField({
    required this.id,
    required this.name,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.options,
    this.placeholder,
    this.validationPattern,
    this.defaultValue,
  });
  
  @override
  List<Object?> get props => [
    id,
    name,
    label,
    type,
    isRequired,
    options,
    placeholder,
    validationPattern,
    defaultValue,
  ];
}

/// Friend template entity with custom field support
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
  
  /// Custom fields defined for this template
  final List<CustomField> customFields;
  
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
    this.customFields = const [],
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
      customFields: const [],
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
      customFields: const [],
      isCustom: false,
      createdAt: DateTime.now(),
    );
  }
  
  /// Create a copy with modifications
  FriendTemplate copyWith({
    String? id,
    String? name,
    TemplateType? type,
    List<String>? visibleFields,
    List<String>? requiredFields,
    List<CustomField>? customFields,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return FriendTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      visibleFields: visibleFields ?? this.visibleFields,
      requiredFields: requiredFields ?? this.requiredFields,
      customFields: customFields ?? this.customFields,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    type,
    visibleFields,
    requiredFields,
    customFields,
    isCustom,
    createdAt,
  ];
}