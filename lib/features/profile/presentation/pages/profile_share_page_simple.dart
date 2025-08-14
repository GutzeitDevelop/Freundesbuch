// Simplified Profile Share Page for debugging
// 
// Version 0.6.1

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/standard_app_bar.dart';
import '../providers/profile_provider.dart';

/// Simplified page for debugging profile sharing
class ProfileSharePageSimple extends ConsumerWidget {
  const ProfileSharePageSimple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('ProfileSharePageSimple: Building...');
    
    return Scaffold(
      appBar: StandardAppBar(
        title: 'Profil teilen (Debug)',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile Share Page - Debug Version'),
            const SizedBox(height: 20),
            
            // Show profile state
            Consumer(
              builder: (context, ref, child) {
                final profileAsync = ref.watch(profileProvider);
                
                return profileAsync.when(
                  data: (profile) {
                    if (profile == null) {
                      return Column(
                        children: [
                          const Text('Kein Profil vorhanden'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                            child: const Text('Profil erstellen'),
                          ),
                        ],
                      );
                    }
                    return Text('Profil: ${profile.name}');
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Fehler: $error'),
                );
              },
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Zurück'),
            ),
          ],
        ),
      ),
    );
  }
}