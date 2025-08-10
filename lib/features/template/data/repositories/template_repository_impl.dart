// Template repository implementation
// 
// Implements template data operations using Hive

import 'package:hive_flutter/hive_flutter.dart';
import '../../../friend/domain/entities/friend_template.dart';
import '../../domain/repositories/template_repository.dart';
import '../models/template_model.dart';

/// Implementation of template repository using Hive
class TemplateRepositoryImpl implements TemplateRepository {
  static const String _boxName = 'templates';
  
  /// Get or open the templates box
  Future<Box<TemplateModel>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<TemplateModel>(_boxName);
    }
    return await Hive.openBox<TemplateModel>(_boxName);
  }
  
  @override
  Future<List<FriendTemplate>> getAllTemplates() async {
    // Start with predefined templates
    final templates = <FriendTemplate>[
      FriendTemplate.classic(),
      FriendTemplate.modern(),
    ];
    
    // Add custom templates from database
    final box = await _getBox();
    final customTemplates = box.values.map((model) => model.toEntity()).toList();
    templates.addAll(customTemplates);
    
    // Sort by creation date (newest first for custom templates)
    templates.sort((a, b) {
      // Predefined templates always come first
      if (!a.isCustom && b.isCustom) return -1;
      if (a.isCustom && !b.isCustom) return 1;
      // For custom templates, sort by creation date
      if (a.isCustom && b.isCustom) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return 0;
    });
    
    return templates;
  }
  
  @override
  Future<List<FriendTemplate>> getCustomTemplates() async {
    final box = await _getBox();
    return box.values.map((model) => model.toEntity()).toList();
  }
  
  @override
  Future<FriendTemplate?> getTemplateById(String id) async {
    // Check predefined templates first
    if (id == 'classic') return FriendTemplate.classic();
    if (id == 'modern') return FriendTemplate.modern();
    
    // Check custom templates
    final box = await _getBox();
    final model = box.get(id);
    return model?.toEntity();
  }
  
  @override
  Future<FriendTemplate> saveTemplate(FriendTemplate template) async {
    final box = await _getBox();
    final model = TemplateModel.fromEntity(template);
    await box.put(template.id, model);
    return template;
  }
  
  @override
  Future<FriendTemplate> updateTemplate(FriendTemplate template) async {
    final box = await _getBox();
    final model = TemplateModel.fromEntity(template);
    await box.put(template.id, model);
    return template;
  }
  
  @override
  Future<bool> deleteTemplate(String id) async {
    // Cannot delete predefined templates
    if (id == 'classic' || id == 'modern') return false;
    
    final box = await _getBox();
    if (box.containsKey(id)) {
      await box.delete(id);
      return true;
    }
    return false;
  }
  
  @override
  Future<bool> templateNameExists(String name) async {
    // Check predefined templates
    if (name.toLowerCase() == 'klassisch' || name.toLowerCase() == 'modern') {
      return true;
    }
    
    // Check custom templates
    final box = await _getBox();
    return box.values.any((model) => 
      model.name.toLowerCase() == name.toLowerCase()
    );
  }
}