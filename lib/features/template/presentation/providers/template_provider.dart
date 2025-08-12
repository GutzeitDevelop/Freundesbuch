// Template state management
// 
// Manages template state using Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../friend/domain/entities/friend_template.dart';
import '../../domain/repositories/template_repository.dart';
import '../../data/repositories/template_repository_impl.dart';

/// Provider for template repository
final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepositoryImpl();
});

/// State notifier for managing templates
class TemplateNotifier extends StateNotifier<AsyncValue<List<FriendTemplate>>> {
  final TemplateRepository _repository;
  
  TemplateNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTemplates();
  }
  
  /// Load all templates
  Future<void> loadTemplates() async {
    try {
      state = const AsyncValue.loading();
      final templates = await _repository.getAllTemplates();
      state = AsyncValue.data(templates);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Create a new custom template
  Future<void> createTemplate({
    required String name,
    required List<String> visibleFields,
    required List<String> requiredFields,
    List<CustomField>? customFields,
  }) async {
    try {
      // Check if name already exists
      if (await _repository.templateNameExists(name)) {
        throw Exception('Ein Template mit diesem Namen existiert bereits');
      }
      
      final template = FriendTemplate(
        id: const Uuid().v4(),
        name: name,
        type: TemplateType.custom,
        visibleFields: visibleFields,
        requiredFields: requiredFields,
        customFields: customFields ?? [],
        isCustom: true,
        createdAt: DateTime.now(),
      );
      
      await _repository.saveTemplate(template);
      await loadTemplates();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Update an existing custom template
  Future<void> updateTemplate(FriendTemplate template) async {
    try {
      if (!template.isCustom) {
        throw Exception('Vordefinierte Templates können nicht bearbeitet werden');
      }
      
      await _repository.updateTemplate(template);
      await loadTemplates();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Delete a custom template
  Future<void> deleteTemplate(String id) async {
    try {
      final success = await _repository.deleteTemplate(id);
      if (!success) {
        throw Exception('Template konnte nicht gelöscht werden');
      }
      await loadTemplates();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Get a template by ID
  Future<FriendTemplate?> getTemplateById(String id) async {
    return await _repository.getTemplateById(id);
  }
  
  /// Get only custom templates
  Future<List<FriendTemplate>> getCustomTemplates() async {
    return await _repository.getCustomTemplates();
  }
}

/// Main provider for templates
final templateProvider = StateNotifierProvider<TemplateNotifier, AsyncValue<List<FriendTemplate>>>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return TemplateNotifier(repository);
});