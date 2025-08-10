// Home page of the application
// 
// Main landing page with navigation to key features

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/navigation/app_router.dart';

/// Home page widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
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
            
            // Action buttons
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add friend page using push to maintain navigation stack
                context.push(AppRouter.addFriend);
              },
              icon: const Icon(Icons.person_add),
              label: Text(l10n.addFriend),
            ),
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to friends list
                context.go(AppRouter.friendsList);
              },
              icon: const Icon(Icons.list),
              label: Text(l10n.myFriends),
            ),
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to friend books list
                context.go(AppRouter.friendBooksList);
              },
              icon: const Icon(Icons.book),
              label: Text(l10n.friendBooks),
            ),
          ],
        ),
      ),
      
      // Floating action button for quick add
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick add friend using push to maintain navigation stack
          context.push(AppRouter.addFriend);
        },
        tooltip: l10n.quickAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}