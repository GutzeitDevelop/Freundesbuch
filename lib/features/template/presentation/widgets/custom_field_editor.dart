// Custom Field Editor Widget
// 
// Widget for creating and editing custom fields in templates
// Version 0.3.1

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../friend/domain/entities/friend_template.dart';
import '../../../../core/utils/snackbar_utils.dart';

/// Dialog for creating/editing a custom field
class CustomFieldEditorDialog extends StatefulWidget {
  final CustomField? field;
  final Function(CustomField) onSave;
  
  const CustomFieldEditorDialog({
    super.key,
    this.field,
    required this.onSave,
  });

  @override
  State<CustomFieldEditorDialog> createState() => _CustomFieldEditorDialogState();
}

class _CustomFieldEditorDialogState extends State<CustomFieldEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _placeholderController = TextEditingController();
  final _optionsController = TextEditingController();
  
  late CustomFieldType _selectedType;
  bool _isRequired = false;
  
  bool get isEditing => widget.field != null;
  
  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final field = widget.field!;
      _labelController.text = field.label;
      _placeholderController.text = field.placeholder ?? '';
      _selectedType = field.type;
      _isRequired = field.isRequired;
      if (field.options != null) {
        _optionsController.text = field.options!.join('\n');
      }
    } else {
      _selectedType = CustomFieldType.text;
    }
  }
  
  @override
  void dispose() {
    _labelController.dispose();
    _placeholderController.dispose();
    _optionsController.dispose();
    super.dispose();
  }
  
  String _getFieldTypeLabel(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.text:
        return 'Text';
      case CustomFieldType.number:
        return 'Zahl';
      case CustomFieldType.date:
        return 'Datum';
      case CustomFieldType.boolean:
        return 'Ja/Nein';
      case CustomFieldType.select:
        return 'Auswahl (einzeln)';
      case CustomFieldType.multiSelect:
        return 'Auswahl (mehrfach)';
      case CustomFieldType.url:
        return 'Webseite';
      case CustomFieldType.email:
        return 'E-Mail';
    }
  }
  
  IconData _getFieldTypeIcon(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.text:
        return Icons.text_fields;
      case CustomFieldType.number:
        return Icons.numbers;
      case CustomFieldType.date:
        return Icons.calendar_today;
      case CustomFieldType.boolean:
        return Icons.check_box;
      case CustomFieldType.select:
        return Icons.radio_button_checked;
      case CustomFieldType.multiSelect:
        return Icons.checklist;
      case CustomFieldType.url:
        return Icons.link;
      case CustomFieldType.email:
        return Icons.email;
    }
  }
  
  void _saveField() {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      final label = _labelController.text.trim();
      final name = label.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');
      
      // Process options for select/multiselect fields
      List<String>? options;
      if (_selectedType == CustomFieldType.select || 
          _selectedType == CustomFieldType.multiSelect) {
        options = _optionsController.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
            
        // This should be caught by validator, but double-check
        if (options.isEmpty) {
          SnackbarUtils.showError(context, 'Bitte mindestens eine Option angeben');
          return;
        }
      }
      
      // Create the custom field
      final field = CustomField(
        id: widget.field?.id ?? const Uuid().v4(),
        name: widget.field?.name ?? 'custom_$name',
        label: label,
        type: _selectedType,
        isRequired: _isRequired,
        placeholder: _placeholderController.text.trim().isNotEmpty 
            ? _placeholderController.text.trim() 
            : null,
        options: options,
      );
      
      // Save and close
      widget.onSave(field);
      Navigator.pop(context);
    } catch (e) {
      // Show error if something goes wrong
      SnackbarUtils.showError(context, 'Fehler beim Speichern: ${e.toString()}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_box,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Feld bearbeiten' : 'Benutzerdefiniertes Feld',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onPrimaryContainer,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field label
                      TextFormField(
                        controller: _labelController,
                        decoration: const InputDecoration(
                          labelText: 'Feldbezeichnung *',
                          hintText: 'z.B. Lieblingssport',
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Bitte eine Bezeichnung eingeben';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Field type selection
                      Text(
                        'Feldtyp',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: CustomFieldType.values.map((type) {
                            return RadioListTile<CustomFieldType>(
                              value: type,
                              groupValue: _selectedType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                              title: Text(_getFieldTypeLabel(type)),
                              secondary: Icon(_getFieldTypeIcon(type)),
                              dense: true,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Placeholder text (not for boolean)
                      if (_selectedType != CustomFieldType.boolean) ...[
                        TextFormField(
                          controller: _placeholderController,
                          decoration: const InputDecoration(
                            labelText: 'Platzhaltertext (optional)',
                            hintText: 'z.B. Fußball, Tennis, ...',
                            prefixIcon: Icon(Icons.short_text),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Options for select/multiselect
                      if (_selectedType == CustomFieldType.select || 
                          _selectedType == CustomFieldType.multiSelect) ...[
                        Text(
                          'Optionen (eine pro Zeile) *',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _optionsController,
                          decoration: const InputDecoration(
                            hintText: 'Option 1\nOption 2\nOption 3',
                            border: OutlineInputBorder(),
                            helperText: 'Geben Sie jede Option in einer neuen Zeile ein',
                          ),
                          maxLines: 5,
                          validator: (_selectedType == CustomFieldType.select || 
                                      _selectedType == CustomFieldType.multiSelect)
                              ? (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Bitte mindestens eine Option angeben';
                                  }
                                  final options = value
                                      .split('\n')
                                      .map((e) => e.trim())
                                      .where((e) => e.isNotEmpty)
                                      .toList();
                                  if (options.isEmpty) {
                                    return 'Bitte mindestens eine Option angeben';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Required field checkbox
                      CheckboxListTile(
                        value: _isRequired,
                        onChanged: (value) {
                          setState(() {
                            _isRequired = value ?? false;
                          });
                        },
                        title: const Text('Pflichtfeld'),
                        subtitle: const Text('Dieses Feld muss ausgefüllt werden'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      
                      // Info box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Benutzerdefinierte Felder erweitern dein Template um individuelle Informationen, die in den Standard-Feldern nicht enthalten sind.',
                                style: theme.textTheme.bodySmall,
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
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _saveField,
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Speichern' : 'Hinzufügen'),
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

/// Widget to display a custom field in a list
class CustomFieldListTile extends StatelessWidget {
  final CustomField field;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const CustomFieldListTile({
    super.key,
    required this.field,
    required this.onEdit,
    required this.onDelete,
  });
  
  String _getFieldTypeLabel(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.text:
        return 'Text';
      case CustomFieldType.number:
        return 'Zahl';
      case CustomFieldType.date:
        return 'Datum';
      case CustomFieldType.boolean:
        return 'Ja/Nein';
      case CustomFieldType.select:
        return 'Auswahl';
      case CustomFieldType.multiSelect:
        return 'Mehrfachauswahl';
      case CustomFieldType.url:
        return 'URL';
      case CustomFieldType.email:
        return 'E-Mail';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.extension,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(field.label),
        subtitle: Text(
          '${_getFieldTypeLabel(field.type)}${field.isRequired ? ' • Pflichtfeld' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Bearbeiten',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Löschen',
            ),
          ],
        ),
      ),
    );
  }
}