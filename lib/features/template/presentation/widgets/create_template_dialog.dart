// Create/Edit Template dialog
// 
// Dialog for creating or editing custom templates

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../friend/domain/entities/friend_template.dart';
import '../providers/template_provider.dart';

/// Dialog for creating or editing custom templates
class CreateTemplateDialog extends ConsumerStatefulWidget {
  final FriendTemplate? template;
  
  const CreateTemplateDialog({super.key, this.template});

  @override
  ConsumerState<CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends ConsumerState<CreateTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  // Available fields that can be included in a template
  final Map<String, String> _availableFields = {
    'name': 'Name',
    'nickname': 'Spitzname',
    'photo': 'Foto',
    'homeLocation': 'Wohnort',
    'birthday': 'Geburtstag',
    'phone': 'Telefon',
    'email': 'E-Mail',
    'work': 'Beruf',
    'hobbies': 'Hobbys',
    'favoriteColor': 'Lieblingsfarbe',
    'socialMedia': 'Social Media',
    'likes': 'Ich mag',
    'dislikes': 'Ich mag nicht',
    'firstMet': 'Erstes Treffen',
    'notes': 'Notizen',
  };
  
  // Selected visible fields
  Set<String> _visibleFields = {'name'}; // Name is always visible
  
  // Selected required fields
  Set<String> _requiredFields = {'name'}; // Name is always required
  
  bool get isEditing => widget.template != null;
  
  @override
  void initState() {
    super.initState();
    if (isEditing && widget.template!.isCustom) {
      _nameController.text = widget.template!.name;
      _visibleFields = Set<String>.from(widget.template!.visibleFields);
      _requiredFields = Set<String>.from(widget.template!.requiredFields);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  void _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      if (_visibleFields.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wähle mindestens ein Feld aus')),
        );
        return;
      }
      
      try {
        if (isEditing) {
          final updatedTemplate = FriendTemplate(
            id: widget.template!.id,
            name: _nameController.text.trim(),
            type: TemplateType.custom,
            visibleFields: _visibleFields.toList(),
            requiredFields: _requiredFields.toList(),
            isCustom: true,
            createdAt: widget.template!.createdAt,
          );
          await ref.read(templateProvider.notifier).updateTemplate(updatedTemplate);
        } else {
          await ref.read(templateProvider.notifier).createTemplate(
            name: _nameController.text.trim(),
            visibleFields: _visibleFields.toList(),
            requiredFields: _requiredFields.toList(),
          );
        }
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Template aktualisiert' : 'Template erstellt'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.dashboard_customize,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Template bearbeiten' : 'Neues Template erstellen',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Template Name',
                          prefixIcon: Icon(Icons.label),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.requiredField;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Field selection header
                      Text(
                        'Felder auswählen',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Wähle die Felder aus, die in diesem Template angezeigt werden sollen',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // Field selection list
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _availableFields.entries.map((entry) {
                            final fieldKey = entry.key;
                            final fieldName = entry.value;
                            final isVisible = _visibleFields.contains(fieldKey);
                            final isRequired = _requiredFields.contains(fieldKey);
                            final isNameField = fieldKey == 'name';
                            
                            return ListTile(
                              leading: Checkbox(
                                value: isVisible,
                                onChanged: isNameField ? null : (value) {
                                  setState(() {
                                    if (value ?? false) {
                                      _visibleFields.add(fieldKey);
                                    } else {
                                      _visibleFields.remove(fieldKey);
                                      _requiredFields.remove(fieldKey);
                                    }
                                  });
                                },
                              ),
                              title: Text(fieldName),
                              subtitle: isNameField 
                                  ? const Text('Immer sichtbar und erforderlich')
                                  : null,
                              trailing: isVisible && !isNameField
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Erforderlich'),
                                        Switch(
                                          value: isRequired,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value) {
                                                _requiredFields.add(fieldKey);
                                              } else {
                                                _requiredFields.remove(fieldKey);
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                  : null,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Info text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Erforderliche Felder müssen beim Hinzufügen eines Freundes ausgefüllt werden',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveTemplate,
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}