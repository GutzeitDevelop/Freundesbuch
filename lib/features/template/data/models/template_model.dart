// Template Hive model
// 
// Hive model for storing custom templates

import 'package:hive/hive.dart';
import '../../../friend/domain/entities/friend_template.dart';

part 'template_model.g.dart';

/// Hive model for template persistence
@HiveType(typeId: 2) // Using typeId 2 (0 is Friend, 1 is FriendBook)
class TemplateModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String type; // Stored as string
  
  @HiveField(3)
  final List<String> visibleFields;
  
  @HiveField(4)
  final List<String> requiredFields;
  
  @HiveField(5)
  final bool isCustom;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;
  
  @HiveField(8)
  final List<Map<String, dynamic>>? customFields;
  
  TemplateModel({
    required this.id,
    required this.name,
    required this.type,
    required this.visibleFields,
    required this.requiredFields,
    required this.isCustom,
    required this.createdAt,
    required this.updatedAt,
    this.customFields,
  });
  
  /// Convert from entity to model
  factory TemplateModel.fromEntity(FriendTemplate template) {
    return TemplateModel(
      id: template.id,
      name: template.name,
      type: template.type.toString().split('.').last,
      visibleFields: List<String>.from(template.visibleFields),
      requiredFields: List<String>.from(template.requiredFields),
      isCustom: template.isCustom,
      createdAt: template.createdAt,
      updatedAt: DateTime.now(),
      customFields: template.customFields.isEmpty ? null : template.customFields.map((field) => {
        'id': field.id,
        'name': field.name,
        'label': field.label,
        'type': field.type.index,
        'isRequired': field.isRequired,
        'options': field.options,
        'placeholder': field.placeholder,
        'validationPattern': field.validationPattern,
        'defaultValue': field.defaultValue,
      }).toList(),
    );
  }
  
  /// Convert from model to entity
  FriendTemplate toEntity() {
    return FriendTemplate(
      id: id,
      name: name,
      type: TemplateType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
        orElse: () => TemplateType.custom,
      ),
      visibleFields: List<String>.from(visibleFields),
      requiredFields: List<String>.from(requiredFields),
      isCustom: isCustom,
      createdAt: createdAt,
      customFields: customFields?.map((fieldMap) => CustomField(
        id: fieldMap['id'] as String,
        name: fieldMap['name'] as String,
        label: fieldMap['label'] as String,
        type: CustomFieldType.values[fieldMap['type'] as int],
        isRequired: fieldMap['isRequired'] as bool? ?? false,
        options: fieldMap['options'] != null 
            ? List<String>.from(fieldMap['options'] as List)
            : null,
        placeholder: fieldMap['placeholder'] as String?,
        validationPattern: fieldMap['validationPattern'] as String?,
        defaultValue: fieldMap['defaultValue'],
      )).toList() ?? [],
    );
  }
}