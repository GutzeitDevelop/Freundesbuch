// Home page of the application
// 
// Main landing page with navigation to key features
// Version 0.3.0 - Enhanced with centralized services

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../../../../core/widgets/consistent_action_button.dart';

/// Home page widget with back button handling
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  DateTime? _lastBackPressTime;
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navigationService = ref.read(navigationServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // Handle double tap to exit
        final now = DateTime.now();
        if (_lastBackPressTime == null || 
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          notificationService.showInfo('Drücke erneut, um die App zu beenden');
          return;
        }
        
        // Exit the app
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: StandardAppBar(
          title: l10n.appTitle,
          showBackButton: false,
        ),
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo placeholder
            Icon(
              Icons.people_outline,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            
            // Welcome text
            Text(
              l10n.welcomeTitle,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              l10n.welcomeSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Action buttons with consistent styling
            ConsistentActionButton(
              label: l10n.addFriend,
              icon: Icons.person_add,
              onPressed: () {
                // Navigate to add friend page using navigation service
                navigationService.navigateTo(context, AppRouter.addFriend);
              },
              style: ActionButtonStyle.primary,
              size: ActionButtonSize.large,
            ),
            const SizedBox(height: 16),
            
            ConsistentActionButton(
              label: l10n.myFriends,
              icon: Icons.list,
              onPressed: () {
                // Navigate to friends list
                navigationService.navigateTo(context, AppRouter.friendsList);
              },
              style: ActionButtonStyle.secondary,
              size: ActionButtonSize.large,
            ),
            const SizedBox(height: 16),
            
            ConsistentActionButton(
              label: l10n.friendBooks,
              icon: Icons.book,
              onPressed: () {
                // Navigate to friend books list
                navigationService.navigateTo(context, AppRouter.friendBooksList);
              },
              style: ActionButtonStyle.secondary,
              size: ActionButtonSize.large,
            ),
            const SizedBox(height: 16),
            
            ConsistentActionButton(
              label: 'Templates verwalten',
              icon: Icons.dashboard_customize,
              onPressed: () {
                // Navigate to template management
                navigationService.navigateTo(context, AppRouter.templateManagement);
              },
              style: ActionButtonStyle.secondary,
              size: ActionButtonSize.large,
            ),
            const SizedBox(height: 32),
            
            // Profile button
            ConsistentActionButton(
              label: 'Mein Profil',
              icon: Icons.account_circle,
              onPressed: () {
                // Navigate to profile page
                navigationService.navigateTo(context, AppRouter.profileView);
              },
              style: ActionButtonStyle.text,
              size: ActionButtonSize.medium,
            ),
          ],
        ),
      ),
      
        // Floating action button for quick add
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Quick add friend using navigation service
            navigationService.navigateTo(context, AppRouter.addFriend);
          },
          tooltip: l10n.quickAdd,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}