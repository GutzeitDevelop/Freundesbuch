// Add/Edit Friend page
// 
// Form for creating or editing friend entries
// Version 0.3.0 - Enhanced with centralized services and smart features

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../core/widgets/consistent_action_button.dart';
import 'dart:io';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_template.dart';
import '../providers/friends_provider.dart';
import '../../../friendbook/presentation/providers/friend_books_provider.dart';
import '../../../template/presentation/providers/template_provider.dart';

/// Page for adding or editing a friend
class AddFriendPage extends ConsumerStatefulWidget {
  final String? friendId;
  
  const AddFriendPage({super.key, this.friendId});

  @override
  ConsumerState<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends ConsumerState<AddFriendPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _homeLocationController = TextEditingController();
  final _workController = TextEditingController();
  final _likesController = TextEditingController();
  final _dislikesController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _favoriteColorController = TextEditingController();
  final _socialMediaController = TextEditingController();
  final _notesController = TextEditingController();
  final _firstMetLocationController = TextEditingController();
  
  DateTime _firstMetDate = DateTime.now();
  DateTime? _birthday;
  String? _photoPath;
  String? _resolvedPhotoPath;
  double? _latitude;
  double? _longitude;
  bool _isFavorite = false;
  late String _selectedTemplate;
  List<String> _selectedFriendBookIds = [];
  Friend? _existingFriend;
  bool _isLoadingLocation = false;
  final LocationService _locationService = LocationService();
  final PhotoService _photoService = PhotoService();
  bool _isLoadingPhoto = false;
  
  // Custom field controllers
  final Map<String, TextEditingController> _customFieldControllers = {};
  final Map<String, dynamic> _customFieldValues = {};
  
  bool get isEditing => widget.friendId != null;
  
  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadFriend();
    } else {
      _loadLastUsedTemplate();
    }
  }
  
  void _loadLastUsedTemplate() async {
    // Load last used template from preferences
    final preferencesService = ref.read(preferencesServiceProvider);
    final lastTemplate = preferencesService.getLastUsedTemplate();
    if (mounted) {
      setState(() {
        _selectedTemplate = lastTemplate ?? 'classic';
      });
    }
  }
  
  void _loadFriend() async {
    final friend = await ref.read(friendsProvider.notifier).getFriendById(widget.friendId!);
    if (friend != null && mounted) {
      // Resolve photo path for display
      if (friend.photoPath != null) {
        final resolvedPath = await PhotoService.resolvePhotoPath(friend.photoPath);
        if (mounted) {
          setState(() {
            _resolvedPhotoPath = resolvedPath;
          });
        }
      }
      // Check if the template still exists
      String templateToUse = friend.templateType;
      final templatesAsync = ref.read(templateProvider);
      if (templatesAsync.hasValue) {
        final templates = templatesAsync.value!;
        final templateExists = templates.any((t) => t.id == friend.templateType);
        if (!templateExists) {
          // Template was deleted, fallback to classic
          templateToUse = 'classic';
          // Show a message to the user using notification service
          if (mounted) {
            final notificationService = ref.read(notificationServiceProvider);
            notificationService.showWarning(
              'Das ursprüngliche Template wurde gelöscht. Klassisches Template wird verwendet.'
            );
          }
        }
      }
      
      setState(() {
        _existingFriend = friend;
        _nameController.text = friend.name;
        _nicknameController.text = friend.nickname ?? '';
        _phoneController.text = friend.phone ?? '';
        _emailController.text = friend.email ?? '';
        _homeLocationController.text = friend.homeLocation ?? '';
        _workController.text = friend.work ?? '';
        _likesController.text = friend.likes ?? '';
        _dislikesController.text = friend.dislikes ?? '';
        _hobbiesController.text = friend.hobbies ?? '';
        _favoriteColorController.text = friend.favoriteColor ?? '';
        _socialMediaController.text = friend.socialMedia ?? '';
        _notesController.text = friend.notes ?? '';
        _firstMetLocationController.text = friend.firstMetLocation ?? '';
        _firstMetDate = friend.firstMetDate;
        _birthday = friend.birthday;
        _photoPath = friend.photoPath;
        _latitude = friend.firstMetLatitude;
        _longitude = friend.firstMetLongitude;
        _isFavorite = friend.isFavorite;
        _selectedTemplate = templateToUse;
        _selectedFriendBookIds = List<String>.from(friend.friendBookIds);
        
        // Load custom field values
        if (friend.customFieldValues != null) {
          _customFieldValues.clear();
          _customFieldValues.addAll(friend.customFieldValues!);
        }
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _homeLocationController.dispose();
    _workController.dispose();
    _likesController.dispose();
    _dislikesController.dispose();
    _hobbiesController.dispose();
    _favoriteColorController.dispose();
    _socialMediaController.dispose();
    _notesController.dispose();
    _firstMetLocationController.dispose();
    // Dispose custom field controllers
    for (final controller in _customFieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  Future<void> _saveFriend() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final friend = Friend(
        id: widget.friendId ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
        photoPath: _photoPath,
        firstMetLocation: _firstMetLocationController.text.trim().isEmpty 
            ? null : _firstMetLocationController.text.trim(),
        firstMetLatitude: _latitude,
        firstMetLongitude: _longitude,
        firstMetDate: _firstMetDate,
        birthday: _birthday,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        homeLocation: _homeLocationController.text.trim().isEmpty 
            ? null : _homeLocationController.text.trim(),
        work: _workController.text.trim().isEmpty ? null : _workController.text.trim(),
        likes: _likesController.text.trim().isEmpty ? null : _likesController.text.trim(),
        dislikes: _dislikesController.text.trim().isEmpty ? null : _dislikesController.text.trim(),
        hobbies: _hobbiesController.text.trim().isEmpty ? null : _hobbiesController.text.trim(),
        favoriteColor: _favoriteColorController.text.trim().isEmpty 
            ? null : _favoriteColorController.text.trim(),
        socialMedia: _socialMediaController.text.trim().isEmpty 
            ? null : _socialMediaController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        templateType: _selectedTemplate,
        friendBookIds: _selectedFriendBookIds,
        isFavorite: _isFavorite,
        createdAt: _existingFriend?.createdAt ?? now,
        updatedAt: now,
        customFieldValues: _customFieldValues.isNotEmpty ? _customFieldValues : null,
      );
      
      await ref.read(friendsProvider.notifier).saveFriend(friend);
      
      // Update the friend books to include this friend
      for (final bookId in _selectedFriendBookIds) {
        await ref.read(friendBooksProvider.notifier).addFriendToBook(bookId, friend.id);
      }
      
      // If editing, remove friend from books that were deselected
      if (_existingFriend != null) {
        final previousBookIds = _existingFriend!.friendBookIds;
        for (final bookId in previousBookIds) {
          if (!_selectedFriendBookIds.contains(bookId)) {
            await ref.read(friendBooksProvider.notifier).removeFriendFromBook(bookId, friend.id);
          }
        }
      }
      
      // Invalidate the friendBooks provider to refresh data
      ref.invalidate(friendBooksForFriendProvider(friend.id));
      
      // Invalidate friend count providers for all affected books
      for (final bookId in _selectedFriendBookIds) {
        ref.invalidate(friendCountInBookProvider(bookId));
      }
      
      // If editing, also invalidate count for books that were deselected
      if (_existingFriend != null) {
        final previousBookIds = _existingFriend!.friendBookIds;
        for (final bookId in previousBookIds) {
          if (!_selectedFriendBookIds.contains(bookId)) {
            ref.invalidate(friendCountInBookProvider(bookId));
          }
        }
      }
      
      if (mounted) {
        // Save last used template
        final preferencesService = ref.read(preferencesServiceProvider);
        await preferencesService.setLastUsedTemplate(_selectedTemplate);
        
        // Show success notification
        final notificationService = ref.read(notificationServiceProvider);
        final l10n = AppLocalizations.of(context)!;
        notificationService.setContext(context);
        notificationService.showSuccess(l10n.friendSaved);
        
        // Navigate appropriately
        final navigationService = ref.read(navigationServiceProvider);
        if (isEditing) {
          context.go('/friends/${friend.id}');
        } else {
          navigationService.navigateBack(context);
        }
      }
    }
  }
  
  /// Get current GPS location and update the form
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingLocation = true;
    });
    
    try {
      final locationData = await _locationService.getCurrentLocation(
        includeAddress: true,
        timeout: const Duration(seconds: 15),
      );
      
      if (!mounted) return;
      
      setState(() {
        _firstMetLocationController.text = locationData.address ?? 
            '${locationData.latitude.toStringAsFixed(6)}, ${locationData.longitude.toStringAsFixed(6)}';
        _latitude = locationData.latitude;
        _longitude = locationData.longitude;
      });
      
      final l10n = AppLocalizations.of(context)!;
      SnackbarUtils.showSuccess(context, '${l10n.locationCaptured}: ${locationData.address ?? "GPS coordinates"}');
      
    } on LocationPermissionDeniedException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showLocationError(l10n.permissionDenied, e.message);
    } on LocationServicesDisabledException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showLocationError(l10n.locationDisabled, e.message);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showLocationError(l10n.locationError, 'Failed to get location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }
  
  /// Show location error dialog with options
  void _showLocationError(String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
          if (title == l10n.permissionDenied || title == l10n.locationDisabled)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _locationService.openLocationSettings();
              },
              child: Text(l10n.openSettings),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTemplateSelector() {
    final l10n = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(templateProvider);
    
    return templatesAsync.when(
      data: (templates) {
        // If there are custom templates, show a dropdown instead of segmented button
        if (templates.length > 2) {
          // Ensure the selected template exists in the list
          final templateExists = templates.any((t) => t.id == _selectedTemplate);
          if (!templateExists && _selectedTemplate != 'classic') {
            // Update the state to use classic template
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedTemplate = 'classic';
                });
              }
            });
          }
          final valueToUse = templateExists ? _selectedTemplate : 'classic';
          
          return DropdownButtonFormField<String>(
            value: valueToUse,
            decoration: InputDecoration(
              labelText: l10n.selectTemplate,
              prefixIcon: const Icon(Icons.dashboard_customize),
              border: const OutlineInputBorder(),
            ),
            items: templates.map((template) {
              return DropdownMenuItem(
                value: template.id,
                child: Row(
                  children: [
                    Icon(
                      template.isCustom ? Icons.dashboard_customize : Icons.lock,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(template.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTemplate = value;
                });
              }
            },
          );
        }
        
        // If only predefined templates, show segmented button
        return SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'classic',
              label: Text(l10n.classicTemplate),
              icon: const Icon(Icons.book),
            ),
            ButtonSegment(
              value: 'modern',
              label: Text(l10n.modernTemplate),
              icon: const Icon(Icons.smartphone),
            ),
          ],
          selected: {_selectedTemplate},
          onSelectionChanged: (Set<String> selection) {
            setState(() {
              _selectedTemplate = selection.first;
            });
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => SegmentedButton<String>(
        segments: [
          ButtonSegment(
            value: 'classic',
            label: Text(l10n.classicTemplate),
            icon: const Icon(Icons.book),
          ),
          ButtonSegment(
            value: 'modern',
            label: Text(l10n.modernTemplate),
            icon: const Icon(Icons.smartphone),
          ),
        ],
        selected: {_selectedTemplate},
        onSelectionChanged: (Set<String> selection) {
          setState(() {
            _selectedTemplate = selection.first;
          });
        },
      ),
    );
  }
  
  Widget _buildFriendBooksSection() {
    final l10n = AppLocalizations.of(context)!;
    final friendBooksAsync = ref.watch(friendBooksProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.friendBooks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        friendBooksAsync.when(
          data: (friendBooks) {
            if (friendBooks.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Noch keine Freundebücher erstellt', // l10n.noFriendBooksYet,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: friendBooks.map((book) {
                final isSelected = _selectedFriendBookIds.contains(book.id);
                final bookColor = _getColorFromHex(book.colorHex);
                
                return FilterChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFriendBookIds.add(book.id);
                      } else {
                        _selectedFriendBookIds.remove(book.id);
                      }
                    });
                  },
                  avatar: Icon(
                    _getIconFromName(book.iconName),
                    size: 18,
                    color: isSelected ? Colors.white : bookColor,
                  ),
                  label: Text(book.name),
                  backgroundColor: bookColor.withOpacity(0.1),
                  selectedColor: bookColor,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
  
  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
  
  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'family':
        return Icons.family_restroom;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'sports':
        return Icons.sports_soccer;
      case 'music':
        return Icons.music_note;
      case 'travel':
        return Icons.flight;
      case 'gaming':
        return Icons.sports_esports;
      case 'food':
        return Icons.restaurant;
      case 'party':
        return Icons.celebration;
      case 'heart':
        return Icons.favorite;
      default:
        return Icons.group;
    }
  }
  
  Widget? _buildCustomFieldWidget(CustomField field) {
    // Get or create controller
    if (!_customFieldControllers.containsKey(field.id)) {
      _customFieldControllers[field.id] = TextEditingController(
        text: _customFieldValues[field.name]?.toString() ?? field.defaultValue?.toString() ?? '',
      );
    }
    
    final controller = _customFieldControllers[field.id]!;
    
    switch (field.type) {
      case CustomFieldType.text:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            prefixIcon: const Icon(Icons.edit),
          ),
          validator: field.isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return '${field.label} ist erforderlich';
            }
            return null;
          } : null,
          onChanged: (value) {
            _customFieldValues[field.name] = value;
          },
        );
        
      case CustomFieldType.number:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            prefixIcon: const Icon(Icons.numbers),
          ),
          keyboardType: TextInputType.number,
          validator: field.isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return '${field.label} ist erforderlich';
            }
            return null;
          } : null,
          onChanged: (value) {
            _customFieldValues[field.name] = value.isNotEmpty ? num.tryParse(value) : null;
          },
        );
        
      case CustomFieldType.email:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (field.isRequired && (value == null || value.trim().isEmpty)) {
              return '${field.label} ist erforderlich';
            }
            if (value != null && value.isNotEmpty && !value.contains('@')) {
              return 'Bitte gültige E-Mail-Adresse eingeben';
            }
            return null;
          },
          onChanged: (value) {
            _customFieldValues[field.name] = value;
          },
        );
        
      case CustomFieldType.url:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            prefixIcon: const Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          validator: field.isRequired ? (value) {
            if (value == null || value.trim().isEmpty) {
              return '${field.label} ist erforderlich';
            }
            return null;
          } : null,
          onChanged: (value) {
            _customFieldValues[field.name] = value;
          },
        );
        
      case CustomFieldType.boolean:
        return SwitchListTile(
          title: Text(field.label),
          subtitle: field.placeholder != null ? Text(field.placeholder!) : null,
          value: _customFieldValues[field.name] ?? field.defaultValue ?? false,
          onChanged: (value) {
            setState(() {
              _customFieldValues[field.name] = value;
            });
          },
        );
        
      case CustomFieldType.date:
        return InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _customFieldValues[field.name] ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _customFieldValues[field.name] = date;
                controller.text = '${date.day}.${date.month}.${date.year}';
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.placeholder,
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: Text(
              controller.text.isEmpty ? 'Datum auswählen' : controller.text,
            ),
          ),
        );
        
      case CustomFieldType.select:
        // Initialize with default or existing value
        final currentValue = _customFieldValues[field.name]?.toString() ?? 
                           field.defaultValue?.toString();
        // Only use value if it's in the options list
        final validValue = (field.options?.contains(currentValue) ?? false) ? currentValue : null;
        
        return DropdownButtonFormField<String>(
          value: validValue,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder ?? 'Bitte auswählen',
            prefixIcon: const Icon(Icons.list),
          ),
          items: field.options?.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList() ?? [],
          validator: field.isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return '${field.label} ist erforderlich';
            }
            return null;
          } : null,
          onChanged: (value) {
            setState(() {
              _customFieldValues[field.name] = value;
            });
          },
        );
        
      case CustomFieldType.multiSelect:
        // For multi-select, we'll use a simple chips approach
        // Create a new list to avoid modifying cast results
        final storedValue = _customFieldValues[field.name];
        final selectedItems = <String>[];
        if (storedValue is List) {
          selectedItems.addAll(storedValue.cast<String>());
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: field.label,
                hintText: field.placeholder,
                prefixIcon: const Icon(Icons.checklist),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: field.options?.map((option) {
                  final isSelected = selectedItems.contains(option);
                  return FilterChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        // Create new list for state update
                        final newList = List<String>.from(selectedItems);
                        if (selected) {
                          newList.add(option);
                        } else {
                          newList.remove(option);
                        }
                        _customFieldValues[field.name] = newList;
                      });
                    },
                  );
                }).toList() ?? [],
              ),
            ),
          ],
        );
    }
  }
  
  List<Widget> _buildFormFields() {
    final l10n = AppLocalizations.of(context)!;
    
    // Get the template from provider
    final templatesAsync = ref.watch(templateProvider);
    FriendTemplate? template;
    
    if (templatesAsync.hasValue) {
      template = templatesAsync.value!.firstWhere(
        (t) => t.id == _selectedTemplate,
        orElse: () => FriendTemplate.classic(),
      );
    } else {
      // Fallback to predefined templates
      template = _selectedTemplate == 'modern' 
          ? FriendTemplate.modern() 
          : FriendTemplate.classic();
    }
    
    final widgets = <Widget>[];
    
    // Always show name field (required)
    widgets.add(
      TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: l10n.name,
          prefixIcon: const Icon(Icons.person),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.requiredField;
          }
          return null;
        },
      ),
    );
    widgets.add(const SizedBox(height: 16));
    
    // Add fields based on template
    if (template.visibleFields.contains('nickname')) {
      widgets.add(
        TextFormField(
          controller: _nicknameController,
          decoration: InputDecoration(
            labelText: l10n.nickname,
            prefixIcon: const Icon(Icons.tag),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('phone')) {
      widgets.add(
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: l10n.phone,
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('email')) {
      widgets.add(
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: l10n.email,
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('homeLocation')) {
      widgets.add(
        TextFormField(
          controller: _homeLocationController,
          decoration: InputDecoration(
            labelText: l10n.homeLocation,
            prefixIcon: const Icon(Icons.home),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('work')) {
      widgets.add(
        TextFormField(
          controller: _workController,
          decoration: InputDecoration(
            labelText: l10n.work,
            prefixIcon: const Icon(Icons.work),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('hobbies')) {
      widgets.add(
        TextFormField(
          controller: _hobbiesController,
          decoration: InputDecoration(
            labelText: l10n.hobbies,
            prefixIcon: const Icon(Icons.sports_soccer),
          ),
          maxLines: 2,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('likes')) {
      widgets.add(
        TextFormField(
          controller: _likesController,
          decoration: InputDecoration(
            labelText: l10n.iLike,
            prefixIcon: const Icon(Icons.thumb_up),
          ),
          maxLines: 2,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('dislikes')) {
      widgets.add(
        TextFormField(
          controller: _dislikesController,
          decoration: InputDecoration(
            labelText: l10n.iDontLike,
            prefixIcon: const Icon(Icons.thumb_down),
          ),
          maxLines: 2,
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('favoriteColor')) {
      widgets.add(
        TextFormField(
          controller: _favoriteColorController,
          decoration: InputDecoration(
            labelText: l10n.favoriteColor,
            prefixIcon: const Icon(Icons.palette),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    if (template.visibleFields.contains('socialMedia')) {
      widgets.add(
        TextFormField(
          controller: _socialMediaController,
          decoration: InputDecoration(
            labelText: l10n.socialMedia,
            prefixIcon: const Icon(Icons.share),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 16));
    }
    
    // First met location
    widgets.add(
      TextFormField(
        controller: _firstMetLocationController,
        decoration: InputDecoration(
          labelText: l10n.firstMet,
          prefixIcon: const Icon(Icons.location_on),
          suffixIcon: _isLoadingLocation
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.my_location),
                  tooltip: l10n.currentLocation,
                  onPressed: _getCurrentLocation,
                ),
        ),
      ),
    );
    widgets.add(const SizedBox(height: 16));
    
    // Always show notes field
    widgets.add(
      TextFormField(
        controller: _notesController,
        decoration: InputDecoration(
          labelText: l10n.notes,
          prefixIcon: const Icon(Icons.note),
        ),
        maxLines: 3,
      ),
    );
    widgets.add(const SizedBox(height: 16));
    
    // Add custom fields if template has them
    if (template.customFields.isNotEmpty) {
      // Add section header
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.dashboard_customize, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Benutzerdefinierte Felder',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));
      
      // Add each custom field
      for (final field in template.customFields) {
        final widget = _buildCustomFieldWidget(field);
        if (widget != null) {
          widgets.add(widget);
          widgets.add(const SizedBox(height: 16));
        }
      }
    }
    
    // FriendBooks selection
    widgets.add(_buildFriendBooksSection());
    
    return widgets;
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.edit : l10n.addFriend),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // If editing, go back to friend detail
            // Otherwise go back to where we came from (home or friends list)
            if (isEditing) {
              context.go('/friends/${widget.friendId}');
            } else {
              // Check if we can pop, otherwise go home
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go(AppRouter.home);
              }
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    backgroundImage: (_resolvedPhotoPath ?? _photoPath) != null 
                        ? FileImage(File(_resolvedPhotoPath ?? _photoPath!)) as ImageProvider
                        : null,
                    child: (_resolvedPhotoPath ?? _photoPath) == null 
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        color: Theme.of(context).colorScheme.onPrimary,
                        onPressed: _showPhotoSourceDialog,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Template selector
            _buildTemplateSelector(),
            const SizedBox(height: 24),
            
            // Form fields
            ..._buildFormFields(),
            const SizedBox(height: 24),
            
            // Save button
            ElevatedButton.icon(
              onPressed: _saveFriend,
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            
            // Cancel button
            OutlinedButton(
              onPressed: () {
                // Same logic as back button
                if (isEditing) {
                  context.go('/friends/${widget.friendId}');
                } else {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    context.go(AppRouter.home);
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows dialog to choose photo source (camera or gallery)
  /// 
  /// Developer Notes:
  /// This method presents a bottom sheet with options for camera or gallery.
  /// It handles all permission checks and error states through the PhotoService.
  /// After successful photo selection, it updates the UI and stores the path.
  Future<void> _showPhotoSourceDialog() async {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.photoSourceDialog,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                
                // Camera option
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(l10n.takePhoto),
                  onTap: () {
                    Navigator.pop(context);
                    _captureFromCamera();
                  },
                ),
                
                // Gallery option
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(l10n.chooseFromGallery),
                  onTap: () {
                    Navigator.pop(context);
                    _selectFromGallery();
                  },
                ),
                
                // Remove photo option (only if photo exists)
                if (_photoPath != null)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: Text(l10n.removePhoto),
                    onTap: () {
                      Navigator.pop(context);
                      _removePhoto();
                    },
                  ),
                
                const SizedBox(height: 16),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Captures photo using device camera with comprehensive error handling
  /// 
  /// Security Features:
  /// - Permission validation before access
  /// - File size and format validation
  /// - Secure local storage
  /// - No sensitive data in error messages
  Future<void> _captureFromCamera() async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() {
      _isLoadingPhoto = true;
    });

    try {
      final photoData = await _photoService.captureFromCamera();
      
      // For new photos, we need to get the full path
      final fullPath = await PhotoService.resolvePhotoPath(photoData.filePath);
      
      setState(() {
        _photoPath = photoData.filePath;  // Store filename for persistence
        _resolvedPhotoPath = fullPath;    // Use full path for display
        _isLoadingPhoto = false;
      });

      // Show success message at top
      if (mounted) {
        SnackbarUtils.showSuccess(context, l10n.photoCaptured);
      }
    } on PhotoPermissionDeniedException catch (_) {
      setState(() {
        _isLoadingPhoto = false;
      });
      
      if (mounted) {
        _showErrorDialog(
          l10n.photoError,
          l10n.cameraPermissionDenied,
          showSettingsOption: true,
        );
      }
    } on CameraNotFoundException catch (_) {
      setState(() {
        _isLoadingPhoto = false;
      });
      
      if (mounted) {
        _showErrorDialog(l10n.photoError, l10n.cameraNotFound);
      }
    } on PhotoStorageException catch (e) {
      setState(() {
        _isLoadingPhoto = false;
      });
      
      if (mounted) {
        // Check specific error types for user-friendly messages
        String message = l10n.photoError;
        if (e.toString().contains('too large')) {
          message = l10n.photoTooLarge;
        } else if (e.toString().contains('format')) {
          message = l10n.unsupportedPhotoFormat;
        } else {
          message = 'Fehler beim Aufnehmen des Fotos';
        }
        
        _showErrorDialog(l10n.photoError, message);
      }
    } catch (e) {
      setState(() {
        _isLoadingPhoto = false;
      });
      
      if (mounted) {
        _showErrorDialog(l10n.photoError, 'Ein unerwarteter Fehler ist aufgetreten');
      }
    }
  }

  /// Selects photo from device gallery with security validation
  /// 
  /// Features:
  /// - Gallery permission handling
  /// - File format and size validation
  /// - Secure copying to app directory
  /// - User feedback for all states
  Future<void> _selectFromGallery() async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() {
      _isLoadingPhoto = true;
    });

    try {
      final photoData = await _photoService.selectFromGallery();
      
      // For new photos, we need to get the full path
      final fullPath = await PhotoService.resolvePhotoPath(photoData.filePath);
      
      setState(() {
        _photoPath = photoData.filePath;  // Store filename for persistence
        _resolvedPhotoPath = fullPath;    // Use full path for display
        _isLoadingPhoto = false;
      });

      // Show success message at top
      if (mounted) {
        SnackbarUtils.showSuccess(context, l10n.photoSelected);
      }
    } on PhotoPermissionDeniedException catch (_) {
      setState(() {
        _isLoadingPhoto = false;
      });
      
      if (mounted) {
        _showErrorDialog(
          l10n.photoError,
          l10n.galleryPermissionDenied,
          showSettingsOption: true,
        );
      }
    } on PhotoStorageException catch (e) {
      setState(() {
        _isLoadingPhoto = false;
      });
      
      if (mounted) {
        // Check specific error types for user-friendly messages
        String message = l10n.photoError;
        if (e.toString().contains('too large')) {
          message = l10n.photoTooLarge;
        } else if (e.toString().contains('format')) {
          message = l10n.unsupportedPhotoFormat;
        } else {
          message = 'Fehler beim Auswählen des Fotos';
        }
        
        _showErrorDialog(l10n.photoError, message);
      }
    } catch (e) {
      setState(() {
        _isLoadingPhoto = false;
      });
      
      if (mounted) {
        _showErrorDialog(l10n.photoError, 'Ein unerwarteter Fehler ist aufgetreten');
      }
    }
  }

  /// Removes the selected photo
  void _removePhoto() {
    setState(() {
      _photoPath = null;
    });
    
    SnackbarUtils.showInfo(context, AppLocalizations.of(context)!.removePhoto);
  }

  /// Shows error dialog with optional settings navigation
  /// 
  /// Developer Notes:
  /// This method provides a consistent error dialog interface across the app.
  /// It handles permission errors gracefully by offering settings navigation.
  void _showErrorDialog(String title, String message, {bool showSettingsOption = false}) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (showSettingsOption)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Open device settings - this would require additional permission handling
                  // For now, we just show the message
                },
                child: Text(l10n.openSettings),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }
}