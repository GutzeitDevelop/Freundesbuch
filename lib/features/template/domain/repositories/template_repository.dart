// Template repository interface
// 
// Defines contract for template data operations

import '../../../friend/domain/entities/friend_template.dart';

/// Repository interface for template operations
abstract class TemplateRepository {
  /// Get all templates (including predefined and custom)
  Future<List<FriendTemplate>> getAllTemplates();
  
  /// Get only custom templates
  Future<List<FriendTemplate>> getCustomTemplates();
  
  /// Get a template by ID
  Future<FriendTemplate?> getTemplateById(String id);
  
  /// Save a custom template
  Future<FriendTemplate> saveTemplate(FriendTemplate template);
  
  /// Update a custom template
  Future<FriendTemplate> updateTemplate(FriendTemplate template);
  
  /// Delete a custom template
  Future<bool> deleteTemplate(String id);
  
  /// Check if a template name already exists
  Future<bool> templateNameExists(String name);
}