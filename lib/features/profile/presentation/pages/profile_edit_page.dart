// Profile Edit Page
// 
// Allows users to create or edit their profile
// Version 0.3.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../core/widgets/consistent_action_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

/// Page for creating or editing user profile
class ProfileEditPage extends ConsumerStatefulWidget {
  final UserProfile? existingProfile;
  
  const ProfileEditPage({super.key, this.existingProfile});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
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
  final _favoriteMusicController = TextEditingController();
  final _favoriteMoviesController = TextEditingController();
  final _favoriteBooksController = TextEditingController();
  final _favoriteFoodController = TextEditingController();
  final _mottoController = TextEditingController();
  
  DateTime? _selectedBirthday;
  String? _photoPath;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }
  
  void _initializeForm() {
    final profile = widget.existingProfile ?? ref.read(profileProvider).value;
    if (profile != null) {
      _nameController.text = profile.name;
      _nicknameController.text = profile.nickname ?? '';
      _phoneController.text = profile.phone ?? '';
      _emailController.text = profile.email ?? '';
      _homeLocationController.text = profile.homeLocation ?? '';
      _workController.text = profile.work ?? '';
      _likesController.text = profile.likes ?? '';
      _dislikesController.text = profile.dislikes ?? '';
      _hobbiesController.text = profile.hobbies ?? '';
      _favoriteMusicController.text = profile.favoriteMusic ?? '';
      _favoriteMoviesController.text = profile.favoriteMovies ?? '';
      _favoriteBooksController.text = profile.favoriteBooks ?? '';
      _favoriteFoodController.text = profile.favoriteFood ?? '';
      _mottoController.text = profile.motto ?? '';
      _selectedBirthday = profile.birthday;
      _photoPath = profile.photoPath;
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
    _favoriteMusicController.dispose();
    _favoriteMoviesController.dispose();
    _favoriteBooksController.dispose();
    _favoriteFoodController.dispose();
    _mottoController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (source != null) {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _photoPath = pickedFile.path;
        });
      }
    }
  }
  
  Future<void> _selectBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final notificationService = ref.read(notificationServiceProvider);
    
    try {
      final existingProfile = widget.existingProfile ?? ref.read(profileProvider).value;
      
      final profile = UserProfile(
        id: existingProfile?.id ?? '',
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim().isNotEmpty ? _nicknameController.text.trim() : null,
        photoPath: _photoPath,
        birthday: _selectedBirthday,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        homeLocation: _homeLocationController.text.trim().isNotEmpty ? _homeLocationController.text.trim() : null,
        work: _workController.text.trim().isNotEmpty ? _workController.text.trim() : null,
        likes: _likesController.text.trim().isNotEmpty ? _likesController.text.trim() : null,
        dislikes: _dislikesController.text.trim().isNotEmpty ? _dislikesController.text.trim() : null,
        hobbies: _hobbiesController.text.trim().isNotEmpty ? _hobbiesController.text.trim() : null,
        favoriteMusic: _favoriteMusicController.text.trim().isNotEmpty ? _favoriteMusicController.text.trim() : null,
        favoriteMovies: _favoriteMoviesController.text.trim().isNotEmpty ? _favoriteMoviesController.text.trim() : null,
        favoriteBooks: _favoriteBooksController.text.trim().isNotEmpty ? _favoriteBooksController.text.trim() : null,
        favoriteFood: _favoriteFoodController.text.trim().isNotEmpty ? _favoriteFoodController.text.trim() : null,
        motto: _mottoController.text.trim().isNotEmpty ? _mottoController.text.trim() : null,
        socialMedia: null, // TODO: Add social media fields
        customFields: null, // TODO: Add custom fields
        createdAt: existingProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (existingProfile != null) {
        await ref.read(profileProvider.notifier).updateProfile(profile);
        notificationService.showSuccess('Profil aktualisiert');
      } else {
        await ref.read(profileProvider.notifier).createProfile(profile);
        notificationService.showSuccess('Profil erstellt');
      }
      
      if (mounted) {
        ref.read(navigationServiceProvider).navigateBack(context);
      }
    } catch (e) {
      notificationService.showError('Fehler beim Speichern: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navigationService = ref.read(navigationServiceProvider);
    final isNewProfile = widget.existingProfile == null && ref.read(profileProvider).value == null;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        navigationService.navigateBack(context);
      },
      child: Scaffold(
        appBar: StandardAppBar(
          title: isNewProfile ? 'Profil erstellen' : 'Profil bearbeiten',
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Photo section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      image: _photoPath != null
                          ? DecorationImage(
                              image: FileImage(File(_photoPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _photoPath == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: Text('Foto ${_photoPath != null ? 'ändern' : 'hinzufügen'}'),
                ),
              ),
              const SizedBox(height: 24),
              
              // Basic Information
              Text(
                'Grundinformationen',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte gib deinen Namen ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Spitzname',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 16),
              
              ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('Geburtstag'),
                subtitle: Text(
                  _selectedBirthday != null
                      ? DateFormat('dd.MM.yyyy').format(_selectedBirthday!)
                      : 'Nicht angegeben',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectBirthday,
              ),
              const SizedBox(height: 24),
              
              // Contact Information
              Text(
                'Kontaktinformationen',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefonnummer',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-Mail',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _homeLocationController,
                decoration: const InputDecoration(
                  labelText: 'Wohnort',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _workController,
                decoration: const InputDecoration(
                  labelText: 'Beruf/Arbeit',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 24),
              
              // Personal Preferences
              Text(
                'Persönliche Vorlieben',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _likesController,
                decoration: const InputDecoration(
                  labelText: 'Ich mag',
                  prefixIcon: Icon(Icons.favorite),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _dislikesController,
                decoration: const InputDecoration(
                  labelText: 'Ich mag nicht',
                  prefixIcon: Icon(Icons.heart_broken),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _hobbiesController,
                decoration: const InputDecoration(
                  labelText: 'Hobbys',
                  prefixIcon: Icon(Icons.sports_soccer),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              
              // Favorites
              Text(
                'Favoriten',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _favoriteMusicController,
                decoration: const InputDecoration(
                  labelText: 'Lieblingsmusik',
                  prefixIcon: Icon(Icons.music_note),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _favoriteMoviesController,
                decoration: const InputDecoration(
                  labelText: 'Lieblingsfilme',
                  prefixIcon: Icon(Icons.movie),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _favoriteBooksController,
                decoration: const InputDecoration(
                  labelText: 'Lieblingsbücher',
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _favoriteFoodController,
                decoration: const InputDecoration(
                  labelText: 'Lieblingsessen',
                  prefixIcon: Icon(Icons.restaurant),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _mottoController,
                decoration: const InputDecoration(
                  labelText: 'Lebensmotto',
                  prefixIcon: Icon(Icons.format_quote),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              
              // Save button
              ConsistentActionButton(
                onPressed: _isLoading ? null : _saveProfile,
                label: isNewProfile ? 'Profil erstellen' : 'Speichern',
                icon: Icons.save,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}