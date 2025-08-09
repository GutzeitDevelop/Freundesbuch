// App navigation configuration
// 
// Manages routing between screens using GoRouter

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/friend/presentation/pages/add_friend_page.dart';
import '../../features/friend/presentation/pages/friends_list_page.dart';
import '../../features/friend/presentation/pages/friend_detail_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// Provider for the app router
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

/// App navigation routes
class AppRouter {
  static const String home = '/';
  static const String friendsList = '/friends';
  static const String addFriend = '/friends/add';
  static const String friendDetail = '/friends/:id';
  static const String editFriend = '/friends/:id/edit';
  
  /// Main router configuration
  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // Home page
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      
      // Friends list
      GoRoute(
        path: friendsList,
        name: 'friendsList',
        builder: (context, state) => const FriendsListPage(),
        routes: [
          // Add friend
          GoRoute(
            path: 'add',
            name: 'addFriend',
            builder: (context, state) => const AddFriendPage(),
          ),
          
          // Friend detail
          GoRoute(
            path: ':id',
            name: 'friendDetail',
            builder: (context, state) {
              final friendId = state.pathParameters['id']!;
              return FriendDetailPage(friendId: friendId);
            },
            routes: [
              // Edit friend
              GoRoute(
                path: 'edit',
                name: 'editFriend',
                builder: (context, state) {
                  final friendId = state.pathParameters['id']!;
                  return AddFriendPage(friendId: friendId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}