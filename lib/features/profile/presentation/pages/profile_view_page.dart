// Profile View Page
// 
// Displays the user's profile with sharing options
// Version 0.3.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../core/widgets/consistent_action_button.dart';
import '../../../../core/widgets/field_display_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';
import 'profile_edit_page.dart';

/// Page for viewing user profile
class ProfileViewPage extends ConsumerWidget {
  const ProfileViewPage({super.key});
  
  Future<void> _shareProfile(BuildContext context, UserProfile profile) async {
    final shareableData = profile.toShareableMap();
    final StringBuffer shareText = StringBuffer();
    
    shareText.writeln('👤 ${profile.name}');
    if (profile.nickname != null) shareText.writeln('📛 "${profile.nickname}"');
    if (profile.phone != null) shareText.writeln('📱 ${profile.phone}');
    if (profile.email != null) shareText.writeln('📧 ${profile.email}');
    if (profile.homeLocation != null) shareText.writeln('🏠 ${profile.homeLocation}');
    if (profile.work != null) shareText.writeln('💼 ${profile.work}');
    if (profile.likes != null) shareText.writeln('❤️ Mag: ${profile.likes}');
    if (profile.hobbies != null) shareText.writeln('🎮 Hobbys: ${profile.hobbies}');
    
    await Share.share(
      shareText.toString(),
      subject: 'Mein Profil - ${profile.name}',
    );
  }
  
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(profileProvider);
    final navigationService = ref.read(navigationServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        navigationService.navigateBack(context);
      },
      child: Scaffold(
        appBar: StandardAppBar(
          title: 'Mein Profil',
          actions: [
            profileAsync.when(
              data: (profile) => profile != null
                  ? IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => navigationService.navigateTo(
                        context,
                        '/profile/edit',
                        extra: profile,
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        body: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 100,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Noch kein Profil erstellt',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Erstelle dein Profil um es mit neuen Freunden zu teilen',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ConsistentActionButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditPage(),
                        ),
                      ),
                      label: 'Profil erstellen',
                      icon: Icons.add,
                    ),
                  ],
                ),
              );
            }
            
            return ListView(
              children: [
                // Profile header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile photo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            width: 3,
                          ),
                          image: profile.photoPath != null
                              ? DecorationImage(
                                  image: FileImage(File(profile.photoPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: profile.photoPath == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Name and nickname
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (profile.nickname != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '"${profile.nickname}"',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                      
                      // Completion percentage
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${profile.completionPercentage.toStringAsFixed(0)}% vollständig',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Basic Information
                const FieldSectionHeader(title: 'Grundinformationen'),
                DateFieldDisplay(
                  icon: Icons.cake,
                  label: 'Geburtstag',
                  date: profile.birthday,
                ),
                
                // Contact Information
                if (profile.phone != null || profile.email != null || profile.homeLocation != null || profile.work != null)
                  const FieldSectionHeader(title: 'Kontakt'),
                FieldDisplayWidget(
                  icon: Icons.phone,
                  label: 'Telefon',
                  value: profile.phone,
                  copyable: true,
                ),
                FieldDisplayWidget(
                  icon: Icons.email,
                  label: 'E-Mail',
                  value: profile.email,
                  copyable: true,
                ),
                FieldDisplayWidget(
                  icon: Icons.home,
                  label: 'Wohnort',
                  value: profile.homeLocation,
                ),
                FieldDisplayWidget(
                  icon: Icons.work,
                  label: 'Beruf',
                  value: profile.work,
                ),
                
                // Personal Preferences
                if (profile.likes != null || profile.dislikes != null || profile.hobbies != null)
                  const FieldSectionHeader(title: 'Persönliches'),
                FieldDisplayWidget(
                  icon: Icons.favorite,
                  label: 'Ich mag',
                  value: profile.likes,
                ),
                FieldDisplayWidget(
                  icon: Icons.heart_broken,
                  label: 'Ich mag nicht',
                  value: profile.dislikes,
                ),
                FieldDisplayWidget(
                  icon: Icons.sports_soccer,
                  label: 'Hobbys',
                  value: profile.hobbies,
                ),
                
                // Favorites
                if (profile.favoriteMusic != null || 
                    profile.favoriteMovies != null || 
                    profile.favoriteBooks != null || 
                    profile.favoriteFood != null)
                  const FieldSectionHeader(title: 'Favoriten'),
                FieldDisplayWidget(
                  icon: Icons.music_note,
                  label: 'Lieblingsmusik',
                  value: profile.favoriteMusic,
                ),
                FieldDisplayWidget(
                  icon: Icons.movie,
                  label: 'Lieblingsfilme',
                  value: profile.favoriteMovies,
                ),
                FieldDisplayWidget(
                  icon: Icons.book,
                  label: 'Lieblingsbücher',
                  value: profile.favoriteBooks,
                ),
                FieldDisplayWidget(
                  icon: Icons.restaurant,
                  label: 'Lieblingsessen',
                  value: profile.favoriteFood,
                ),
                
                // Motto
                if (profile.motto != null) ...[
                  const FieldSectionHeader(title: 'Lebensmotto'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.format_quote,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                profile.motto!,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                
                // Actions
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ConsistentActionButton(
                    onPressed: () => _shareProfile(context, profile),
                    label: 'Profil teilen',
                    icon: Icons.share,
                  ),
                ),
                const SizedBox(height: 16),
              ],
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
                ConsistentActionButton(
                  onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
                  label: 'Erneut versuchen',
                  icon: Icons.refresh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}