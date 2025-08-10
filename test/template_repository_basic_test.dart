// Basic Template Repository Tests
//
// Simplified version to test core functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:myfriends/features/template/data/repositories/template_repository_impl.dart';
import 'package:myfriends/features/friend/domain/entities/friend_template.dart';
import 'helpers/test_setup.dart';

void main() {
  group('Template Repository Basic Tests', () {
    late TemplateRepositoryImpl repository;
    
    setUp(() async {
      await setupHiveForTesting();
      repository = TemplateRepositoryImpl();
    });
    
    tearDown(() async {
      await clearHiveBox('templates');
      await cleanupHive();
    });
    
    test('should include predefined templates', () async {
      // Act
      final templates = await repository.getAllTemplates();
      
      // Assert
      expect(templates.length, greaterThanOrEqualTo(2));
      expect(templates.any((t) => t.id == 'classic'), isTrue);
      expect(templates.any((t) => t.id == 'modern'), isTrue);
      
      final classicTemplate = templates.firstWhere((t) => t.id == 'classic');
      expect(classicTemplate.isCustom, isFalse);
      expect(classicTemplate.type, equals(TemplateType.classic));
    });
    
    test('should save and retrieve custom template', () async {
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
    });
    
    test('should delete custom template', () async {
      // Arrange
      final template = createTestTemplate(name: 'To Delete');
      await repository.saveTemplate(template);
      
      // Act
      final deleted = await repository.deleteTemplate(template.id);
      final retrieved = await repository.getTemplateById(template.id);
      
      // Assert
      expect(deleted, isTrue);
      expect(retrieved, isNull);
    });
    
    test('should not delete predefined templates', () async {
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
    
    test('should check template name existence', () async {
      // Arrange
      final template = createTestTemplate(name: 'Unique Template');
      await repository.saveTemplate(template);
      
      // Act
      final exists = await repository.templateNameExists('Unique Template');
      final notExists = await repository.templateNameExists('Non Existent');
      final predefinedExists = await repository.templateNameExists('Klassisch');
      
      // Assert
      expect(exists, isTrue);
      expect(notExists, isFalse);
      expect(predefinedExists, isTrue);
    });
  });
}