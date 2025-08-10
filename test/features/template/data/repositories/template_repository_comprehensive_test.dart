// Comprehensive tests for Template Repository
//
// Tests all template repository functionality including edge cases

import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/features/template/data/repositories/template_repository_impl.dart';
import 'package:myfriends/features/friend/domain/entities/friend_template.dart';
import '../../../../helpers/test_setup.dart';

void main() {
  group('TemplateRepository Comprehensive Tests', () {
    late TemplateRepositoryImpl repository;
    
    setUp(() async {
      await setupHiveForTesting();
      repository = TemplateRepositoryImpl();
    });
    
    tearDown(() async {
      await clearHiveBox('templates');
      await cleanupHive();
    });
    
    group('Predefined Templates', () {
      test('should always include classic and modern templates', () async {
        // Act
        final templates = await repository.getAllTemplates();
        
        // Assert
        expect(templates.length, greaterThanOrEqualTo(2));
        expect(templates.any((t) => t.id == 'classic'), isTrue);
        expect(templates.any((t) => t.id == 'modern'), isTrue);
        
        final classicTemplate = templates.firstWhere((t) => t.id == 'classic');
        final modernTemplate = templates.firstWhere((t) => t.id == 'modern');
        
        expect(classicTemplate.isCustom, isFalse);
        expect(modernTemplate.isCustom, isFalse);
      });
      
      test('should get predefined templates by ID', () async {
        // Act
        final classicTemplate = await repository.getTemplateById('classic');
        final modernTemplate = await repository.getTemplateById('modern');
        
        // Assert
        expect(classicTemplate, isNotNull);
        expect(modernTemplate, isNotNull);
        
        expect(classicTemplate!.id, equals('classic'));
        expect(classicTemplate.type, equals(TemplateType.classic));
        expect(classicTemplate.isCustom, isFalse);
        
        expect(modernTemplate!.id, equals('modern'));
        expect(modernTemplate.type, equals(TemplateType.modern));
        expect(modernTemplate.isCustom, isFalse);
      });
      
      test('should not allow deletion of predefined templates', () async {
        // Act
        final deletedClassic = await repository.deleteTemplate('classic');
        final deletedModern = await repository.deleteTemplate('modern');
        
        // Assert
        expect(deletedClassic, isFalse);
        expect(deletedModern, isFalse);
        
        // Verify they still exist
        final classicExists = await repository.getTemplateById('classic');
        final modernExists = await repository.getTemplateById('modern');
        expect(classicExists, isNotNull);
        expect(modernExists, isNotNull);
      });
      
      test('should recognize predefined template names as existing', () async {
        // Act
        final classicExists = await repository.templateNameExists('Klassisch');
        final modernExists = await repository.templateNameExists('Modern');
        final caseInsensitive = await repository.templateNameExists('KLASSISCH');
        
        // Assert
        expect(classicExists, isTrue);
        expect(modernExists, isTrue);
        expect(caseInsensitive, isTrue);
      });
    });
    
    group('Custom Template CRUD Operations', () {
      test('should save and retrieve a custom template', () async {
        // Arrange
        final template = createTestTemplate(
          name: 'Business Template',
          visibleFields: ['name', 'email', 'phone', 'work'],
          requiredFields: ['name', 'email'],
        );
        
        // Act
        final savedTemplate = await repository.saveTemplate(template);
        final retrievedTemplate = await repository.getTemplateById(template.id);
        
        // Assert
        expect(savedTemplate.id, equals(template.id));
        expect(retrievedTemplate, isNotNull);
        expect(retrievedTemplate!.name, equals('Business Template'));
        expect(retrievedTemplate.isCustom, isTrue);
        expect(retrievedTemplate.type, equals(TemplateType.custom));
        expect(retrievedTemplate.visibleFields, equals(['name', 'email', 'phone', 'work']));
        expect(retrievedTemplate.requiredFields, equals(['name', 'email']));
      });
      
      test('should update an existing custom template', () async {
        // Arrange
        final originalTemplate = createTestTemplate(name: 'Original Name');
        await repository.saveTemplate(originalTemplate);
        
        final updatedTemplate = FriendTemplate(
          id: originalTemplate.id,
          name: 'Updated Name',
          type: TemplateType.custom,
          visibleFields: ['name', 'nickname', 'phone', 'socialMedia'],
          requiredFields: ['name'],
          isCustom: true,
          createdAt: originalTemplate.createdAt,
        );
        
        // Act
        await repository.updateTemplate(updatedTemplate);
        final retrievedTemplate = await repository.getTemplateById(originalTemplate.id);
        
        // Assert
        expect(retrievedTemplate!.name, equals('Updated Name'));
        expect(retrievedTemplate.visibleFields, equals(['name', 'nickname', 'phone', 'socialMedia']));
        expect(retrievedTemplate.id, equals(originalTemplate.id));
      });
      
      test('should delete a custom template', () async {
        // Arrange
        final template = createTestTemplate(name: 'To Delete');
        await repository.saveTemplate(template);
        
        // Verify it exists
        final existsBefore = await repository.getTemplateById(template.id);
        expect(existsBefore, isNotNull);
        
        // Act
        final deleted = await repository.deleteTemplate(template.id);
        
        // Assert
        expect(deleted, isTrue);
        final existsAfter = await repository.getTemplateById(template.id);
        expect(existsAfter, isNull);
      });
      
      test('should return false when deleting non-existent template', () async {
        // Act
        final deleted = await repository.deleteTemplate('non-existent-id');
        
        // Assert
        expect(deleted, isFalse);
      });
    });
    
    group('Template Collection Operations', () {
      test('should get all templates with correct ordering', () async {
        // Arrange - create custom templates with different timestamps
        final now = DateTime.now();
        final customTemplates = [
          createTestTemplate(name: 'Template 1', createdAt: now.subtract(const Duration(hours: 2))),
          createTestTemplate(name: 'Template 2', createdAt: now.subtract(const Duration(hours: 1))),
          createTestTemplate(name: 'Template 3', createdAt: now),
        ];
        
        // Save in random order
        await repository.saveTemplate(customTemplates[1]);
        await repository.saveTemplate(customTemplates[2]);
        await repository.saveTemplate(customTemplates[0]);
        
        // Act
        final allTemplates = await repository.getAllTemplates();
        
        // Assert - predefined templates should come first, then custom templates by creation date (newest first)
        expect(allTemplates.length, equals(5)); // 2 predefined + 3 custom
        
        // First two should be predefined
        expect(allTemplates[0].isCustom, isFalse);
        expect(allTemplates[1].isCustom, isFalse);
        
        // Custom templates should be sorted by creation date (newest first)
        final customInResult = allTemplates.skip(2).toList();
        expect(customInResult.map((t) => t.name).toList(), equals(['Template 3', 'Template 2', 'Template 1']));
      });
      
      test('should get only custom templates', () async {
        // Arrange
        final customTemplates = [
          createTestTemplate(name: 'Custom 1'),
          createTestTemplate(name: 'Custom 2'),
        ];
        
        for (final template in customTemplates) {
          await repository.saveTemplate(template);
        }
        
        // Act
        final onlyCustom = await repository.getCustomTemplates();
        
        // Assert
        expect(onlyCustom.length, equals(2));
        expect(onlyCustom.every((t) => t.isCustom), isTrue);
        expect(onlyCustom.map((t) => t.name).toSet(), equals({'Custom 1', 'Custom 2'}));
      });
      
      test('should return empty list when no custom templates exist', () async {
        // Act
        final customTemplates = await repository.getCustomTemplates();
        
        // Assert
        expect(customTemplates, isEmpty);
      });
    });
    
    group('Template Name Validation', () {
      test('should detect existing custom template names', () async {
        // Arrange
        final template = createTestTemplate(name: 'Unique Template');
        await repository.saveTemplate(template);
        
        // Act
        final exists = await repository.templateNameExists('Unique Template');
        final notExists = await repository.templateNameExists('Non Existent');
        
        // Assert
        expect(exists, isTrue);
        expect(notExists, isFalse);
      });
      
      test('should be case insensitive for name checking', () async {
        // Arrange
        final template = createTestTemplate(name: 'CaSeSeNsItIvE');
        await repository.saveTemplate(template);
        
        // Act
        final existsLower = await repository.templateNameExists('casesensitive');
        final existsUpper = await repository.templateNameExists('CASESENSITIVE');
        final existsMixed = await repository.templateNameExists('CaseSensitive');
        
        // Assert
        expect(existsLower, isTrue);
        expect(existsUpper, isTrue);
        expect(existsMixed, isTrue);
      });
      
      test('should handle empty and whitespace names', () async {
        // Act
        final emptyExists = await repository.templateNameExists('');
        final whitespaceExists = await repository.templateNameExists('   ');
        
        // Assert
        expect(emptyExists, isFalse);
        expect(whitespaceExists, isFalse);
      });
    });
    
    group('Template Field Configuration', () {
      test('should save templates with various field configurations', () async {
        // Arrange
        final templates = [
          createTestTemplate(
            name: 'Minimal Template',
            visibleFields: ['name'],
            requiredFields: ['name'],
          ),
          createTestTemplate(
            name: 'Full Template',
            visibleFields: ['name', 'nickname', 'phone', 'email', 'birthday', 'location', 'notes', 'hobbies', 'favoriteColor', 'homeLocation', 'work', 'socialMedia', 'iLike', 'iDontLike'],
            requiredFields: ['name', 'phone', 'email'],
          ),
          createTestTemplate(
            name: 'Social Template',
            visibleFields: ['name', 'nickname', 'socialMedia', 'hobbies', 'iLike', 'iDontLike'],
            requiredFields: ['name', 'nickname'],
          ),
        ];
        
        // Act
        for (final template in templates) {
          await repository.saveTemplate(template);
        }
        
        // Assert
        for (final originalTemplate in templates) {
          final retrieved = await repository.getTemplateById(originalTemplate.id);
          expect(retrieved, isNotNull);
          expect(retrieved!.visibleFields, equals(originalTemplate.visibleFields));
          expect(retrieved.requiredFields, equals(originalTemplate.requiredFields));
        }
      });
      
      test('should handle templates with duplicate fields in arrays', () async {
        // Arrange
        final template = createTestTemplate(
          name: 'Duplicate Fields',
          visibleFields: ['name', 'phone', 'phone', 'email', 'name'], // Duplicates
          requiredFields: ['name', 'name'], // Duplicates
        );
        
        // Act
        await repository.saveTemplate(template);
        final retrieved = await repository.getTemplateById(template.id);
        
        // Assert - should save as-is (repository doesn't clean duplicates)
        expect(retrieved!.visibleFields, equals(['name', 'phone', 'phone', 'email', 'name']));
        expect(retrieved.requiredFields, equals(['name', 'name']));
      });
      
      test('should handle templates with empty field arrays', () async {
        // Arrange
        final template = createTestTemplate(
          name: 'Empty Fields',
          visibleFields: [],
          requiredFields: [],
        );
        
        // Act
        await repository.saveTemplate(template);
        final retrieved = await repository.getTemplateById(template.id);
        
        // Assert
        expect(retrieved!.visibleFields, isEmpty);
        expect(retrieved.requiredFields, isEmpty);
      });
    });
    
    group('Edge Cases and Error Handling', () {
      test('should handle very long template names', () async {
        // Arrange
        final longName = 'A' * 1000;
        final template = createTestTemplate(name: longName);
        
        // Act
        await repository.saveTemplate(template);
        final retrieved = await repository.getTemplateById(template.id);
        
        // Assert
        expect(retrieved!.name, equals(longName));
      });
      
      test('should handle special characters in template names', () async {
        // Arrange
        final specialName = 'Template with ñáméß & spëcial chars! @#\$%^&*()';
        final template = createTestTemplate(name: specialName);
        
        // Act
        await repository.saveTemplate(template);
        final retrieved = await repository.getTemplateById(template.id);
        
        // Assert
        expect(retrieved!.name, equals(specialName));
      });
      
      test('should handle templates with very long field lists', () async {
        // Arrange
        final manyFields = List.generate(100, (index) => 'field$index');
        final template = createTestTemplate(
          name: 'Many Fields Template',
          visibleFields: manyFields,
          requiredFields: manyFields.take(50).toList(),
        );
        
        // Act
        await repository.saveTemplate(template);
        final retrieved = await repository.getTemplateById(template.id);
        
        // Assert
        expect(retrieved!.visibleFields.length, equals(100));
        expect(retrieved.requiredFields.length, equals(50));
      });
      
      test('should return null for non-existent template IDs', () async {
        // Act
        final nonExistent = await repository.getTemplateById('non-existent-id');
        
        // Assert
        expect(nonExistent, isNull);
      });
      
      test('should handle invalid field names in template', () async {
        // Arrange
        final template = createTestTemplate(
          name: 'Invalid Fields',
          visibleFields: ['validField', 'anotherField', 'lastField'],
          requiredFields: ['validField'],
        );
        
        // Act & Assert - should not throw
        await repository.saveTemplate(template);
        final retrieved = await repository.getTemplateById(template.id);
        expect(retrieved, isNotNull);
      });
    });
    
    group('Concurrent Operations', () {
      test('should handle concurrent template saves', () async {
        // Arrange
        final templates = List.generate(10, (index) => createTestTemplate(name: 'Template $index'));
        
        // Act
        final futures = templates.map((t) => repository.saveTemplate(t)).toList();
        await Future.wait(futures);
        
        final allTemplates = await repository.getAllTemplates();
        
        // Assert - should have 2 predefined + 10 custom = 12 total
        expect(allTemplates.length, equals(12));
        expect(allTemplates.where((t) => t.isCustom).length, equals(10));
      });
      
      test('should handle concurrent name existence checks', () async {
        // Arrange
        final template = createTestTemplate(name: 'Concurrent Template');
        await repository.saveTemplate(template);
        
        // Act
        final futures = List.generate(
          5, 
          (index) => repository.templateNameExists('Concurrent Template')
        );
        final results = await Future.wait(futures);
        
        // Assert
        expect(results.every((result) => result == true), isTrue);
      });
      
      test('should handle concurrent deletions', () async {
        // Arrange
        final templates = List.generate(5, (index) => createTestTemplate(name: 'Delete Template $index'));
        for (final template in templates) {
          await repository.saveTemplate(template);
        }
        
        // Act - try to delete the same templates concurrently
        final futures = templates.map((t) => repository.deleteTemplate(t.id)).toList();
        final results = await Future.wait(futures);
        
        // Assert - each should be deleted exactly once
        expect(results.where((result) => result == true).length, equals(5));
        
        // Verify all are deleted
        for (final template in templates) {
          final exists = await repository.getTemplateById(template.id);
          expect(exists, isNull);
        }
      });
    });
    
    group('Complex Integration Scenarios', () {
      test('should maintain consistency through multiple operations', () async {
        // Arrange & Act - perform a series of operations
        
        // 1. Create several templates
        final templates = [
          createTestTemplate(name: 'Template A'),
          createTestTemplate(name: 'Template B'),
          createTestTemplate(name: 'Template C'),
        ];
        
        for (final template in templates) {
          await repository.saveTemplate(template);
        }
        
        // 2. Update one template
        final updatedTemplate = FriendTemplate(
          id: templates[1].id,
          name: 'Template B Updated',
          type: TemplateType.custom,
          visibleFields: ['name', 'phone', 'email'],
          requiredFields: templates[1].requiredFields,
          isCustom: true,
          createdAt: templates[1].createdAt,
        );
        await repository.updateTemplate(updatedTemplate);
        
        // 3. Delete one template
        await repository.deleteTemplate(templates[2].id);
        
        // 4. Check name existence
        final nameExists = await repository.templateNameExists('Template B Updated');
        final deletedNameExists = await repository.templateNameExists('Template C');
        
        // Assert
        final allTemplates = await repository.getAllTemplates();
        expect(allTemplates.length, equals(4)); // 2 predefined + 2 remaining custom
        
        final customTemplates = allTemplates.where((t) => t.isCustom).toList();
        expect(customTemplates.length, equals(2));
        expect(customTemplates.any((t) => t.name == 'Template A'), isTrue);
        expect(customTemplates.any((t) => t.name == 'Template B Updated'), isTrue);
        expect(customTemplates.any((t) => t.name == 'Template C'), isFalse);
        
        expect(nameExists, isTrue);
        expect(deletedNameExists, isFalse);
      });
      
      test('should handle large-scale operations efficiently', () async {
        // Arrange - create many templates
        final manyTemplates = List.generate(100, (index) => createTestTemplate(name: 'Bulk Template $index'));
        
        // Act
        final startTime = DateTime.now();
        
        // Save all templates
        for (final template in manyTemplates) {
          await repository.saveTemplate(template);
        }
        
        // Get all templates
        final allTemplates = await repository.getAllTemplates();
        
        // Check some name existences
        final existenceChecks = await Future.wait([
          repository.templateNameExists('Bulk Template 0'),
          repository.templateNameExists('Bulk Template 50'),
          repository.templateNameExists('Bulk Template 99'),
          repository.templateNameExists('Non Existent Template'),
        ]);
        
        // Delete some templates
        for (int i = 0; i < 10; i++) {
          await repository.deleteTemplate(manyTemplates[i].id);
        }
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        // Assert
        expect(allTemplates.length, equals(102)); // 2 predefined + 100 custom
        expect(existenceChecks, equals([true, true, true, false]));
        
        // Performance check - should complete within reasonable time
        expect(duration.inSeconds, lessThan(30)); // Should complete in less than 30 seconds
        
        final finalTemplates = await repository.getAllTemplates();
        expect(finalTemplates.length, equals(92)); // 2 predefined + 90 remaining custom
      });
    });
  });
}