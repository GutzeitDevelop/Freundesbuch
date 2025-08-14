// Template management page
// 
// Page for managing custom templates
// Version 0.3.0 - Enhanced with centralized services

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../friend/domain/entities/friend_template.dart';
import '../providers/template_provider.dart';
import '../widgets/create_template_dialog.dart';

/// Page for managing templates
class TemplateManagementPage extends ConsumerWidget {
  const TemplateManagementPage({super.key});

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateTemplateDialog(),
    );
  }
  
  void _showEditDialog(BuildContext context, FriendTemplate template) {
    if (!template.isCustom) {
      SnackbarUtils.showError(context, 'Vordefinierte Templates können nicht bearbeitet werden');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => CreateTemplateDialog(template: template),
    );
  }
  
  void _confirmDelete(BuildContext context, WidgetRef ref, FriendTemplate template) {
    if (!template.isCustom) {
      SnackbarUtils.showError(context, 'Vordefinierte Templates können nicht gelöscht werden');
      return;
    }
    
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text('Möchtest du das Template "${template.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(templateProvider.notifier).deleteTemplate(template.id);
              if (context.mounted) {
                SnackbarUtils.showSuccess(context, 'Template gelöscht');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemplateCard(BuildContext context, WidgetRef ref, FriendTemplate template) {
    final theme = Theme.of(context);
    final isPredefined = !template.isCustom;
    
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPredefined 
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer,
          child: Icon(
            isPredefined ? Icons.lock : Icons.dashboard_customize,
            color: isPredefined 
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          template.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              isPredefined ? 'Vordefiniertes Template' : 'Benutzerdefiniertes Template',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: [
                Chip(
                  label: Text(
                    '${template.visibleFields.length + template.customFields.length} Felder',
                    style: theme.textTheme.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(
                    '${template.requiredFields.length} erforderlich',
                    style: theme.textTheme.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        trailing: !isPredefined
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditDialog(context, template);
                      break;
                    case 'delete':
                      _confirmDelete(context, ref, template);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Bearbeiten'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Löschen', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(templateProvider);
    
    final navigationService = ref.read(navigationServiceProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        navigationService.navigateBack(context);
      },
      child: Scaffold(
        appBar: StandardAppBar(
          title: 'Template Verwaltung',
        ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard_customize,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keine Templates vorhanden',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Template erstellen'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                // Header with info
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Template Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Templates definieren, welche Felder beim Hinzufügen eines Freundes angezeigt werden. Du kannst eigene Templates erstellen oder die vordefinierten verwenden.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              return _buildTemplateCard(context, ref, templates[index - 1]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(templateProvider.notifier).loadTemplates(),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        tooltip: 'Neues Template',
        child: const Icon(Icons.add),
      ),
      ),
    );
  }
}